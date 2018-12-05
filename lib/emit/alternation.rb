module Emit
  class Alternation
    def initialize(guards)
      @guards = guards.map do |guard|
        case guard
        when InputGuard, OutputGuard then guard
        else
          InputGuard.new(guard)
        end
      end
    end

    def execute
      idx, request, channel, operation = choose

      if @guards[idx]
        action = @guards[idx].action
        fail "Failed executing action in alternation." unless [Proc, Method].include?(action.class)

        case operation
        when :write then action.()
        when :read  then action.(request.message)
        end
      end

      [channel, request.message]
    end

    private

    def choose
      requests  = {}
      act       = nil

      Scheduler.current.state = :active

      begin
        idx = 0
        @guards.each do |guard|
          if OutputGuard === guard
            operation = :write
            request = ChannelRequest.new(Scheduler.current, guard.message)
            guard.channel_end.send(:post_write, request)
          elsif InputGuard === guard
            operation = :read
            request = ChannelRequest.new(Scheduler.current)
            guard.channel_end.send(:post_read, request)
          else
            fail "Guard was neither write or read."
          end

          requests[request] = [idx, guard.channel_end, operation]
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
