# frozen_string_literal: true

require "active_model"
require "active_support"

require_relative "active_usage/version"
require_relative "active_usage/configuration"
require_relative "active_usage/type/hash"
require_relative "active_usage/event"
require_relative "active_usage/context"
require_relative "active_usage/time_window"
require_relative "active_usage/pipeline"
require_relative "active_usage/store/base"
require_relative "active_usage/store/buffer"
require_relative "active_usage/store/http"
require_relative "active_usage/store/initializer"

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
      @store ||= Store::Initializer.new(configuration)
    end
  end
end
