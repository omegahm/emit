module Emit
  class Choice
    def initialize(*args, **kwargs, &block)
      @block  = block
      @args   = args
      @kwargs = kwargs
    end

    def invoke_on_output
      @block.call(*@args, **@kwargs)
    end

    def invoke_on_input(message)
      @kwargs[:message] = message
      @block.call(*@args, **@kwargs)
    end
  end
end
