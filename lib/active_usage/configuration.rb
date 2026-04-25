# frozen_string_literal: true

module ActiveUsage
  # Holds configuration options for the ActiveUsage gem.
  class Configuration
    attr_accessor :store, :tags, :window_size, :application_name, :api_key, :url

    def initialize
      @store = :active_usage
      @tags = {}
      @window_size = 300
      @application_name = "ActiveUsage"
    end
  end
end
