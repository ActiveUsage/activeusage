# frozen_string_literal: true

require "active_model"

require_relative "active_usage/version"
require_relative "active_usage/configuration"
require_relative "active_usage/type/hash"
require_relative "active_usage/event"

# Top-level namespace for the ActiveUsage gem.
module ActiveUsage
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end
  end
end
