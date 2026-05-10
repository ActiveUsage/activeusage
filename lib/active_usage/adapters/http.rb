# frozen_string_literal: true

module ActiveUsage
  module Adapters
    class Http < Base
      class Client
        def initialize(url, api_key, events)
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

      def initialize(url, api_key)
        @url = url
        @api_key = api_key
      end

      def record(events)
        return true if events.empty?

        Client.new(@url, @api_key, events).call
      end

      def clear!
        0
      end

      def shutdown!; end
    end
  end
end
