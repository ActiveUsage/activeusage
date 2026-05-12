# frozen_string_literal: true

module ActiveUsage
  class Store
    @instances_mutex = Mutex.new
    @instances = []
    @exit_hook_installed = false

    class << self
      def track(instance)
        @instances_mutex.synchronize do
          unless @exit_hook_installed
            at_exit do
              live = @instances_mutex.synchronize { @instances.dup }
              live.each(&:shutdown!)
            end
            @exit_hook_installed = true
          end
          @instances << instance
        end
      end

      def untrack(instance)
        @instances_mutex.synchronize { @instances.delete(instance) }
      end
    end

    def initialize(adapter, batch_size: 100, flush_interval: 1.0, max_queue_size: 10_000)
      @adapter = adapter
      @queue = EventQueue.new(max_queue_size, batch_size)
      @flush_mutex = Mutex.new
      @shutdown_mutex = Mutex.new
      @shutdown = false
      @worker = Worker.new(flush_interval) { flush! }
      self.class.track(self)
    end

    def record(event)
      @queue.push(event)
      flush! if @queue.flush_ready?
      event
    end

    def clear!
      flush!
      @adapter.clear!
    end

    def flush!
      @flush_mutex.synchronize do
        batch = @queue.drain
        return if batch.empty?

        begin
          @adapter.record(batch)
        rescue StandardError
          batch.each { |event| @queue.push(event) }
          raise
        end
      end
    end

    def shutdown!
      @shutdown_mutex.synchronize do
        return if @shutdown

        @shutdown = true
      end

      @worker.stop!
      @worker.join(0.5)
      flush!
      @adapter.shutdown!
      self.class.untrack(self)
    end
  end
end
