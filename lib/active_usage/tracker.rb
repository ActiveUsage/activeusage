# frozen_string_literal: true

module ActiveUsage
  class Tracker
    def initialize(name, tags)
      @name = name
      @tags = tags

      @started_at = Time.current
      @sql_calls = 0
    end

    def call(&)
      result = ActiveSupport::Notifications.subscribed(sql_listener, "sql.active_record", &)

      ActiveUsage.record(**attributes)

      result
    end

    private

    def sql_listener
      ->(*_args) { @sql_calls += 1 }
    end

    def attributes
      {
        type: :task,
        name: @name,
        started_at: @started_at,
        finished_at: finished_at,
        sql_calls: @sql_calls,
        tags: @tags
      }
    end

    def finished_at
      @finished_at ||= Time.current
    end
  end
end
