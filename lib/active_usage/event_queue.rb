# frozen_string_literal: true

module ActiveUsage
  class EventQueue
    def initialize(max_size, batch_size)
      @max_size = max_size
      @batch_size = batch_size
      @queue = Queue.new
      @mutex = Mutex.new
      @dropped_count = 0
    end

    def push(event)
      @mutex.synchronize do
        if @queue.size >= @max_size
          @dropped_count += 1
          return
        end
        @queue << event
      end
    end

    def drain
      items = []
      @mutex.synchronize do
        while items.size < @batch_size && !@queue.empty?
          items << @queue.pop(true)
        end
      rescue ThreadError
        nil
      end
      items
    end

    def size
      @mutex.synchronize { @queue.size }
    end

    def flush_ready?
      size >= @batch_size
    end

    def dropped_count
      @mutex.synchronize { @dropped_count }
    end
  end
end
