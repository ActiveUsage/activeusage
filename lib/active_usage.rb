# frozen_string_literal: true

require "active_model"
require "active_support"

require "json"
require "net/http"
require "uri"

require_relative "active_usage/version"
require_relative "active_usage/configuration"
require_relative "active_usage/type/hash"
require_relative "active_usage/type/array"
require_relative "active_usage/event"
require_relative "active_usage/context"
require_relative "active_usage/time_window"
require_relative "active_usage/collector"
require_relative "active_usage/pipeline"
require_relative "active_usage/store/base"
require_relative "active_usage/store/buffer"
require_relative "active_usage/store/http"
require_relative "active_usage/store/initializer"
require_relative "active_usage/time_helpers"
require_relative "active_usage/tracker"
require_relative "active_usage/instrumentation/active_job_hook"
require_relative "active_usage/instrumentation/context_middleware"
require_relative "active_usage/instrumentation/runtime_state"
require_relative "active_usage/instrumentation/subscriber"

# Top-level namespace for the ActiveUsage gem.
module ActiveUsage
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end

    def store
      @store ||= Store::Initializer.new(configuration).call
    end

    def collector
      @collector ||= Collector.new(configuration)
    end

    def record(**attributes)
      collector.record(**attributes)
    end

    def attach_subscribers!
      return if @subscribers_attached

      ActiveUsage::Instrumentation::Subscriber.new(config: configuration).attach!
      @subscribers_attached = true
    end

    def track(name, tags: {}, &)
      Tracker.new(name, tags).call(&)
    end
  end
end

require "active_usage/railtie" if defined?(Rails::Railtie)
