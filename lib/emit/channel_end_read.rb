module Emit
  class ChannelEndRead < ChannelEnd
    def_delegators :@channel, :post_read
    def_delegators :@channel, :remove_read

    def call
      @channel.read
    end
    alias :read :call
    alias :>> :call

    def retire
      return if @retired

      @retired = true
      @channel.leave_reader
      [:call, :read, :post_read].each do |sym|
        define_singleton_method(sym) { raise ChannelRetiredException }
      end
    end

    def reader?
      true
    end
  end
end
