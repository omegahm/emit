module Emit
  class ChannelEndWrite < ChannelEnd
    def_delegators :@channel, :post_write
    def_delegators :@channel, :remove_write

    def call(message)
      @channel.write(message)
    end
    alias :<< :call

    def retire
      return if @retired

      @retired = true
      @channel.leave_writer
      [:call, :<<, :post_write].each do |sym|
        define_singleton_method(sym) { raise ChannelRetiredException }
      end
    end

    def writer?
      true
    end
  end
end
