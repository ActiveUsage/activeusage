# frozen_string_literal: true

module ActiveUsage
  module Adapters
    class Initializer
      def initialize(configuration)
        @configuration = configuration
      end

      def call
        ActiveUsage::Buffer.new(adapter)
      end

      private

      def adapter
        case @configuration.adapter
        when :http
          Http.new(
            @configuration.url,
            @configuration.api_key
          )
        end
      end
    end
  end
end
