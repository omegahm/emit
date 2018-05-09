require "forwardable"

module Emit
  class Process
    attr_accessor :state
    attr_reader :return_value, :fiber

    def initialize(*args, **kwargs, &block)
      fail ArgumentError.new("Must have a block as argument for Emit::Process.") unless block_given?
      @block        = block
      @args         = args
      @kwargs       = kwargs

      @state        = nil
      @executed     = false
      @return_value = nil

      @fiber        = nil
    end

    def wait
      Scheduler.get_next.transfer while active?
    end

    def notify(new_state)
      @state = new_state
      Scheduler.activate(self) unless Scheduler.current == self
    end

    def start
      @fiber = Fiber.new { run }
    end

    def transfer
      @fiber.transfer
    end

    def run
      @executed = false

      begin
        if @block.arity.negative?
          @return_value = @block.call(*@args, **@kwargs)
        elsif @block.arity > 0
          @return_value = @block.call(*@args)
        else
          @return_value = @block.call
        end
      rescue ::Emit::ChannelPoisonedException => e
        propagate_poison
        raise e
      rescue ::Emit::ChannelRetiredException => e
        propagate_retire
        raise e
      end

      @executed = true
    end

    def active?
      @state == :active
    end

    def executed?
      @executed
    end

    def *(number)
      [*number.times.map { self.dup }]
    end

    private

    def propagate_poison
      @args.each do |arg|
        arg.poison if arg.methods.include?(:poison)
      end
    end

    def propagate_retire
      @args.each do |arg|
        arg.retire if arg.methods.include?(:retire)
      end
    end
  end
end
