# frozen_string_literal: true

module ActiveUsage
  # Holds configuration options for the ActiveUsage gem.
  class Configuration
    attr_accessor :adapter, :tags, :window_size
    attr_writer :logger

    def initialize
      @tags = {}
      @window_size = 300
    end

    def logger
      @logger || (defined?(Rails.logger) && Rails.logger) || Logger.new($stderr)
    end
  end
end
