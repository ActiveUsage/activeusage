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
require_relative "active_usage/recorder"
require_relative "active_usage/tags"
require_relative "active_usage/window_started_at"
require_relative "active_usage/event_queue"
require_relative "active_usage/worker"
require_relative "active_usage/store"
require_relative "active_usage/adapters/base"
require_relative "active_usage/adapters/http"
require_relative "active_usage/time_helpers"
require_relative "active_usage/tracker"
require_relative "active_usage/middleware"
require_relative "active_usage/instrumentation/active_job_hook"
require_relative "active_usage/instrumentation/runtime_state"
require_relative "active_usage/instrumentation/subscriber"

# Top-level namespace for the ActiveUsage gem.
module ActiveUsage
  @configuration_mutex = Mutex.new
  @store_mutex = Mutex.new
  @tags_mutex = Mutex.new

  class << self
    def configuration
      @configuration || @configuration_mutex.synchronize { @configuration ||= Configuration.new }
    end

    def configure
      yield configuration
    end

    def record(type:, name:, started_at:, finished_at:, **attributes)
      Recorder.new(
        type: type,
        name: name,
        started_at: started_at,
        finished_at: finished_at,
        tags: tags.current.merge(attributes.delete(:tags) || {}),
        window_started_at: WindowStartedAt.new(finished_at, configuration.window_size).call,
        **attributes
      ).call(store)
    end

    def track(name, tags: {}, &)
      Tracker.new(name, tags).call(&)
    end

    def tags
      @tags || @tags_mutex.synchronize { @tags ||= Tags.new(configuration.tags) }
    end

    def store
      @store || @store_mutex.synchronize { @store ||= Store.new(configuration.adapter) }
    end
  end
end

require "active_usage/railtie" if defined?(Rails::Railtie)
