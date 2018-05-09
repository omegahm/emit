module Emit
  class GuardGuard
    attr_reader :guard_action

    def initialize(channel_end, message, action=nil)
      if ChannelEndWrite === channel_end
        @guard_action = [channel_end, message, action]
      else
        fail "OutputGuard must have a writing channel end."
      end
    end
  end
end
