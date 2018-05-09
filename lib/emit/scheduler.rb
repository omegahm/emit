require "singleton"
require_relative "process"

module Emit
  class MainProcess < Process
    include Singleton

    def initialize
      @fiber = Fiber.current
    end
  end

  class Scheduler
    include Singleton

    attr_reader :current

    def initialize
      reset!
    end

    def reset!
      @root       = MainProcess.instance
      @current    = @root
      @new_queue  = []
      @next_queue = []
      @fiber      = Fiber.new { start_mainloop }
      @done       = false
    end

    def enqueue(process)
      @new_queue << process
    end
    alias :<< :enqueue

    def join(processes)
      tmp = @current
      @done = false

      processes.each do |process|
        until process.executed?
          raise DeadlockException if @done
          get_next.transfer
        end
      end

      @current = tmp
    end

    def activate(process)
      @next_queue << process
    end

    def get_next
      if !@new_queue.empty?
        @fiber
      elsif !@next_queue.empty?
        @current = @next_queue.shift
        @current
      else
        @fiber
      end
    end

    private

    def start_mainloop
      loop do
        if !@new_queue.empty?
          @current = @new_queue.pop
          @current.transfer
        elsif !@next_queue.empty?
          @current = @next_queue.pop
          @current.transfer
        end

        if @new_queue.empty? && @next_queue.empty?
          @done = true
          @root.fiber.transfer
        end
      end
    end
  end

  # Need to create the singleton instance in main fiber.
  Scheduler = Scheduler.instance.tap do
    # We remove the class and replace it with the instance.
    remove_const("Scheduler")
  end
end
