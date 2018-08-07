module Emit
  class OutputGuard
    attr_reader :channel_end, :message, :action

    def initialize(channel_end, message, action=nil)
      case argument
      when OutputGuard
        @channel_end, @message, @action = argument.channel_end, argument.message, argument.action
      when ChannelEndWrite
        @channel_end, @message, @action = argument, message, action
      when Array
        fail "Wrong number of arguments" unless argument.size == 3
        @channel_end, @message, @action = argument
      else
        fail "Unknown output guard type"
      end

      fail "OutputGuard must have a writing channel end." unless ChannelEndWrite === channel_end
      fail "OutputGuard action cannot be nil" if @action.nil?
    end
  end
end
