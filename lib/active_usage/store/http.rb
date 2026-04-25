# frozen_string_literal: true

module ActiveUsage
  module Store
    class Http < Base
      class Client
        def initialize(application_name, url, api_key, events)
          @application_name = application_name
          @uri = URI(url)
          @api_key = api_key
          @events = events
        end

        def call
          Net::HTTP.start(@uri.host, @uri.port, options) do |http|
            http.request(request).is_a?(Net::HTTPSuccess)
          end
        rescue StandardError
          false
        end

        private

        def request
          request = Net::HTTP::Post.new(@uri)
          request["Content-Type"] = "application/json"
          request["Authorization"] = "Bearer #{@api_key}"
          request.body = JSON.generate(
            application_name: @application_name,
            events: @events.map(&:attributes)
          )
          request
        end

        def options
          {
            use_ssl: @uri.scheme == "https",
            read_timeout: 2.0,
            open_timeout: 2.0
          }
        end
      end

      def initialize(application_name, url, api_key)
        @application_name = application_name
        @url = url
        @api_key = api_key
      end

      def record(events)
        return true if events.empty?

        Client.new(@application_name, @url, @api_key, events).call
      end
    end
  end
end
