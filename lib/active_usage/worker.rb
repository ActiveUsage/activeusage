# frozen_string_literal: true

module ActiveUsage
  class Worker
    def initialize(interval, &block)
      @interval = interval
      @block = block
      @mutex = Mutex.new
      @running = true
      start!
    end

    def stop!
      @mutex.synchronize { @running = false }
    end

    def join(timeout)
      @thread&.join(timeout)
    end

    private

    def running?
      @mutex.synchronize { @running }
    end

    def start!
      @thread = Thread.new do
        Thread.current.name = "activeusage.worker" if Thread.current.respond_to?(:name=)
        while running?
          sleep @interval
          @block.call
        end
      rescue StandardError => e
        puts e
      end
    end
  end
end
