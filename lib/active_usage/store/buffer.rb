# frozen_string_literal: true

module ActiveUsage
  module Store
    class Buffer
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

      def initialize(store)
        @store = store
        @batch_size = 100
        @flush_interval = 1.0
        @max_queue_size = 10_000
        @queue = Queue.new
        @queue_mutex = Mutex.new
        @flush_mutex = Mutex.new
        @state_mutex = Mutex.new
        @running = true
        @dropped_events_count = 0
        start_worker!
        self.class.track(self)
      end

      def record(events)
        queue_mutex.synchronize do
          if queue.size >= max_queue_size
            increment_dropped_events!
            return events
          end

          events.each do |event|
            queue << event
          end
        end

        flush! if queue.size >= batch_size
        events
      end

      def clear!
        flush!
        store.clear!
      end

      def flush!
        flush_mutex.synchronize do
          batch = drain_queue
          persist_batch(batch)
        end
      end

      def shutdown!
        worker_to_join = nil

        state_mutex.synchronize do
          return unless @running

          @running = false
          worker_to_join = @worker
          @worker = nil
        end

        flush!
        worker_to_join&.join(0.5)
        flush!
        store.shutdown!
        self.class.untrack(self)
      end

      private

      attr_reader :store,
                  :batch_size,
                  :flush_interval,
                  :max_queue_size,
                  :queue,
                  :queue_mutex,
                  :flush_mutex,
                  :state_mutex

      def running?
        state_mutex.synchronize { @running }
      end

      def dropped_events_count
        state_mutex.synchronize { @dropped_events_count }
      end

      def queue_size
        queue_mutex.synchronize { queue.size }
      end

      def increment_dropped_events!
        state_mutex.synchronize { @dropped_events_count += 1 }
      end

      def start_worker!
        @worker = Thread.new do
          Thread.current.name = "activeusage.buffer" if Thread.current.respond_to?(:name=)
          while running?
            sleep flush_interval
            flush!
          end
        rescue StandardError => e
          puts e
        end
      end

      def drain_queue
        items = []

        queue_mutex.synchronize do
          while items.size < batch_size && !queue.empty?
            items << queue.pop(true)
          end
        rescue ThreadError
          nil
        end

        items
      end

      def persist_batch(batch)
        return if batch.empty?

        store.record(batch)
      end
    end
  end
end
