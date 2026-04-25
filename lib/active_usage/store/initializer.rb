# frozen_string_literal: true

module ActiveUsage
  module Store
    class Initializer
      def initialize(configuration)
        @configuration = configuration
      end

      def call
        Buffer.new(store)
      end

      private

      def store
        case @configuration.store
        when :active_usage
          Http.new(
            @configuration.application_name,
            @configuration.api_key
          )
        end
      end
    end
  end
end
