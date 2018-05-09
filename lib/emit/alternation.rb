module Emit
  class Alternation
    def initialize(guards)
      @guards = guards
    end

    def execute
      idx, request, channel, operation = choose

      if @guards[idx]
        action = @guards[idx].last[:action]

        case action
        when Choice
          case operation
          when :write then action.invoke_on_output
          when :read  then action.invoke_on_input(request.message)
          end
        when Proc, Method
          case operation
          when :write then action.()
          when :read  then action.(message: request.message)
          end
        when nil
          # no-op
        else
          fail "Failed executing action: #{action}."
        end
      end

      [channel, request.message]
    end

    private

    def choose
      requests  = {}
      act       = nil
      poison    = false
      retire    = false

      Scheduler.current.state = :active

      begin
        idx = 0
        @guards.each do |guard|
          if guard.size == 3 # write
            operation = :write
            channel, message, action = guard
            request = ChannelRequest.new(Scheduler.current, message)
            channel.send(:post_write, request)
          elsif guard.size == 2 # read
            operation = :read
            channel, action = guard
            request = ChannelRequest.new(Scheduler.current)
            channel.send(:post_read, request)
          else
            fail "Guard was neither write or read."
          end

          requests[request] = [idx, channel, operation]
          idx += 1
        end
      rescue ChannelPoisonedException, ChannelRetiredException
        act = result(requests).first
        raise unless act
      end

      Scheduler.current.wait unless act

      unless act
        act, poisoned, retired = result(requests)
        unless act
          raise ChannelPoisonedException if poisoned
          raise ChannelRetiredException if retired
          abort "We should not get here in choice."
        end
      end

      idx, channel, operation = requests[act]
      [idx, act, channel, operation]
    end

    def result(requests)
      act      = nil
      poisoned = false
      retired  = false

      requests.each do |request, value|
        _, channel, operation = value

        if operation == :read
          channel.send(:remove_read, request)
        else
          channel.send(:remove_write, request)
        end

        act = request if request.success?
        poisoned ||= request.poisoned?
        retired  ||= request.retired?
      end

      [act, poisoned, retired]
    end
  end
end
