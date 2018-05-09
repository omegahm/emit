module Emit
  class ChannelEnd
    extend Forwardable

    def initialize(channel)
      @channel = channel
      @retired = false
    end
    def_delegators :@channel, :poison

    def reader?
      false
    end

    def writer?
      false
    end
  end
end
