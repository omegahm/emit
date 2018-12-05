module Emit
  class InputGuard
    attr_reader :channel_end, :action

    def initialize(argument, action=->(msg) {msg})
      case argument
      when InputGuard
        @channel_end, @action = argument.channel_end, argument.action
      when ChannelEndRead
        @channel_end, @action = argument, action
      when Array
        fail "Wrong number of arguments" unless argument.size == 2
        @channel_end, @action = argument
      else
        fail "Unknown input guard type"
      end

      fail "InputGuard must have a reading channel end." unless ChannelEndRead === @channel_end
      fail "InputGuard action cannot be nil" if @action.nil?
    end
  end
end
