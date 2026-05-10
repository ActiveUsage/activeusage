# frozen_string_literal: true

require "logger"

module ActiveUsage
  class Worker
    def initialize(interval, logger: nil, &block)
      @interval = interval
      @block = block
      @logger = logger || default_logger
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

    def default_logger
      (defined?(Rails.logger) && Rails.logger) || Logger.new($stderr)
    end

    def start!
      @thread = Thread.new do
        Thread.current.name = "activeusage.worker" if Thread.current.respond_to?(:name=)
        tick while running?
      end
    end

    def tick
      sleep @interval
      @block.call
    rescue StandardError => e
      @logger.error("[ActiveUsage::Worker] #{e.class}: #{e.message}")
    end
  end
end
