# frozen_string_literal: true

module ActiveUsage
  # Holds configuration options for the ActiveUsage gem.
  class Configuration
    attr_reader :adapter
    attr_accessor :tags, :window_size

    REQUIRED_ADAPTER_METHODS = %i[record clear! shutdown!].freeze

    def initialize
      @tags = {}
      @window_size = 300
    end

    def adapter=(value)
      missing = REQUIRED_ADAPTER_METHODS.reject { |m| value.respond_to?(m) }

      unless missing.empty?
        raise ArgumentError,
              "adapter must respond to #{missing.join(", ")} (got #{value.inspect})"
      end

      @adapter = value
    end
  end
end
