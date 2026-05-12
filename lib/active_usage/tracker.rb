# frozen_string_literal: true

module ActiveUsage
  class Tracker
    def initialize(name, tags)
      @name = name
      @tags = tags
      @started_at = Time.current
    end

    def call(&)
      Instrumentation::RuntimeState.clear_sql_state
      result = ActiveSupport::Notifications.subscribed(sql_listener, "sql.active_record", &)
      ActiveUsage.record(**attributes)
      result
    ensure
      Instrumentation::RuntimeState.clear_sql_state
    end

    private

    def sql_listener
      lambda do |_name, started, finished, _id, payload|
        next if payload[:cached]

        Instrumentation::RuntimeState.add_sql_event(
          payload,
          duration_ms: ((finished - started) * 1000.0).round(3)
        )
      end
    end

    def attributes
      {
        type: :task,
        name: @name,
        started_at: @started_at,
        finished_at: Time.current,
        tags: @tags,
        sql_queries: Instrumentation::RuntimeState.consume_sql_queries
      }
    end
  end
end
