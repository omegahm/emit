module Emit
  class ChannelRequest
    attr_accessor :message, :result, :process

    def initialize(process, message=nil)
      @message = message
      @process = process
      @result  = :fail
    end

    def poison
      return if success?
      @result = :poison
      @process.poison
    end

    def retire
      return if success?
      @result = :retire
      @process.retire
    end

    def offer(recipient)
      return false unless @process.active? && recipient.process.active?
      recipient.message = @message

      @result = :success
      recipient.result = :success

      @process.finish
      recipient.process.finish

      true
    end

    def active?
      @process.active?
    end

    def success?
      @result == :success
    end

    def poisoned?
      @result == :poison
    end

    def retired?
      @result == :retired
    end
  end
end
