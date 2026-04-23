# frozen_string_literal: true

module ActiveUsage
  # Holds configuration options for the ActiveUsage gem.
  class Configuration
    attr_accessor :store

    def initialize
      @store = :active_usage
    end
  end
end
