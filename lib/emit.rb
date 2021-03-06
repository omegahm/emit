require "fiber"

require "emit/version"
require "emit/exceptions"

require "emit/scheduler"
require "emit/process"
require "emit/channel_request"
require "emit/channel"

require "emit/channel_end"
require "emit/channel_end_read"
require "emit/channel_end_write"

require "emit/input_guard"
require "emit/output_guard"

require "emit/alternation"

module Emit
  class << self
    def parallel(*processes, run: true)
      processes.flatten!

      processes.each do |process|
        process.start
        Scheduler.enqueue(process)
      end

      if run
        Scheduler.join(processes)
        processes.map(&:return_value)
      end
    end

    def sequence(*processes)
      processes.flatten.each(&:run)
    end

    def channel
      Channel.new
    end

    def process(*args, **kwargs, &block)
      Process.new(*args, **kwargs, &block)
    end

    def poison(*channel_ends)
      channel_ends.each(&:poison)
    end

    def retire(*channel_ends)
      channel_ends.each(&:retire)
    end

    def choice(*guards)
      Alternation.new(guards).execute
    end

    def method_missing(name, *args, **kwargs)
      Emit.process(*args, **kwargs, &method(name.to_sym))
    end
  end

  private_constant :ChannelEnd
  private_constant :ChannelEndRead
  private_constant :ChannelEndWrite
  private_constant :ChannelRequest
end

class Integer
  alias :old_mult :*
  def *(other)
    return other * self if Emit::Process === other
    old_mult(other)
  end
end
