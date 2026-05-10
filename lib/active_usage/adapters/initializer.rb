# frozen_string_literal: true

module ActiveUsage
  module Adapters
    class Initializer
      def initialize(configuration)
        @configuration = configuration
      end

      def call
        ActiveUsage::Buffer.new(store)
      end

      private

      def store
        case @configuration.store
        when :active_usage
          Http.new(
            @configuration.url,
            @configuration.api_key
          )
        end
      end
    end
  end
end
