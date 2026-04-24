# frozen_string_literal: true

module ActiveUsage
  module Store
    class Http < Base
      def initialize(application_name, api_key)
        super

        @application_name = application_name
        @api_key = api_key
      end

      def record(_events); end
    end
  end
end
