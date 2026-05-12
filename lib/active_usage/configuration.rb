# frozen_string_literal: true

module ActiveUsage
  # Holds configuration options for the ActiveUsage gem.
  class Configuration
    attr_accessor :adapter, :tags, :window_size

    def initialize
      @tags = {}
      @window_size = 300
    end
  end
end
