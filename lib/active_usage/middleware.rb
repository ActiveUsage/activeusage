# frozen_string_literal: true

module ActiveUsage
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      ActiveUsage.tags.flush
      @app.call(env)
    ensure
      ActiveUsage.tags.flush
    end
  end
end
