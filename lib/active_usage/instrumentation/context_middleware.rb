# frozen_string_literal: true

module ActiveUsage
  module Instrumentation
    class ContextMiddleware
      def initialize(app)
        @app = app
      end

      def call(env)
        ActiveUsage::Context.delete
        @app.call(env)
      ensure
        ActiveUsage::Context.delete
      end
    end
  end
end
