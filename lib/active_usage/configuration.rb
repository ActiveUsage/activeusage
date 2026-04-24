# frozen_string_literal: true

module ActiveUsage
  # Holds configuration options for the ActiveUsage gem.
  class Configuration
    attr_accessor :store, :tags

    def initialize
      @store = :active_usage
      @tags = {}
    end
  end
end
