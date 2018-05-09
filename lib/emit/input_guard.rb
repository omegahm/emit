module Emit
  class InputGuard
    attr_reader :guard_action

    def initialize(channel_end, action=nil)
      if ChannelEndRead === channel_end
        @guard_action = [channel_end, action]
      else
        fail "InputGuard must have a reading channel end."
      end
    end
  end
end
