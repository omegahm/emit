module Emit
  class DeadlockException        < StandardError; end
  class ChannelRetiredException  < StandardError; end
  class ChannelPoisonedException < StandardError; end
end
