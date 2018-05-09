require "securerandom"

module Emit
  class Channel
    def initialize(name=nil)
      @name        = name || SecureRandom.uuid
      @read_queue  = []
      @readers     = 0
      @write_queue = []
      @writers     = 0
      @state       = :alive
    end

    def read
      check_termination!

      process = Scheduler.current

      fast_read(process).tap do |msg|
        return msg unless msg.nil?
      end

      process.state = :active
      request = ChannelRequest.new(process)
      post_read(request)
      request.process.wait
      remove_read(request)

      return request.message if request.success?

      check_termination!
      abort "Should not get here..."
    end

    def write(message)
      check_termination!

      process = Scheduler.current

      fast_write(process, message).tap do |written|
        return true unless written.nil?
      end

      process.state = :active
      request = ChannelRequest.new(process, message)
      post_write(request)
      request.process.wait
      remove_write(request)

      return true if request.success?

      check_termination!
      abort "Should not get here..."
    end

    def poison
      return if poisoned?
      @state = :poisoned
      @read_queue.each(&:poison)
      @write_queue.each(&:poison)
    end

    def reader
      @readers += 1
      ChannelEndRead.new(self)
    end
    alias :+@ :reader

    def writer
      @writers += 1
      ChannelEndWrite.new(self)
    end
    alias :-@ :writer

    def poisoned?
      @state == :poisoned
    end

    def retired?
      @state == :retired
    end

    def leave_reader
      return if retired?
      @readers -= 1
      if @readers.zero?
        @state = :retired
        @write_queue.each(&:retire)
      end
    end

    def leave_writer
      return if retired?
      @writers -= 1
      if @writers.zero?
        @state = :retired
        @read_queue.each(&:retire)
      end
    end

    # private

    def post_read(request)
      check_termination!
      @read_queue << request
      match
    end

    def post_write(request)
      check_termination!
      @write_queue << request
      match
    end

    def remove_read(request)
      @read_queue.delete(request)
    end

    def remove_write(request)
      @write_queue.delete(request)
    end

    private

    def fast_read(process)
      writer = @write_queue.shuffle.find(&:active?)
      return nil if writer.nil?

      writer.result = :success
      writer.process.state = :done
      Scheduler.activate(writer.process) unless process == writer.process

      writer.message
    end

    def fast_write(process, message)
      reader = @read_queue.shuffle.find(&:active?)
      return nil if reader.nil?

      reader.message = message
      reader.result = :success
      reader.process.state = :done
      Scheduler.activate(reader.process) unless process == reader.process

      true
    end

    def check_termination!
      case @state
      when :poisoned
        raise ChannelPoisonedException
      when :retired
        raise ChannelRetiredException
      end
    end

    def match
      @write_queue.shuffle.each do |writer|
        @read_queue.shuffle.each do |reader|
          return true if writer.offer(reader)
        end
      end

      false
    end
  end
end
