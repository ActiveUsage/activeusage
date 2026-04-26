# frozen_string_literal: true

module ActiveUsage
  class Tracker
    def initialize(name, tags)
      @name = name
      @tags = tags

      @started_at = Time.current
      @sql_duration_ms = 0.0
      @sql_calls = 0
    end

    def call(&)
      result = ActiveSupport::Notifications.subscribed(sql_listener, "sql.active_record", &)

      ActiveUsage.record(**attributes)

      result
    end

    private

    def sql_listener
      lambda do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        next if event.payload[:name].to_s.match?(/\ASCHEMA\z/i)

        @sql_duration_ms += event.duration
        @sql_calls += 1
      end
    end

    def attributes
      {
        type: :task,
        name: @name,
        started_at: @started_at,
        finished_at: finished_at,
        duration_ms: ActiveUsage::TimeHelpers.duration_ms(@started_at, finished_at),
        sql_duration_ms: @sql_duration_ms.round(3),
        sql_calls: @sql_calls,
        tags: Context.tags.merge(@tags)
      }
    end

    def finished_at
      @finished_at ||= Time.current
    end
  end
end
