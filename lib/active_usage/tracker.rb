# frozen_string_literal: true

module ActiveUsage
  class Tracker
    def initialize(name, tags)
      @name = name
      @tags = tags
      @started_at = Time.current
    end

    def call
      result = yield

      ActiveUsage.record(**attributes)

      result
    end

    private

    def attributes
      {
        type: :task,
        name: @name,
        started_at: @started_at,
        finished_at: finished_at,
        tags: @tags
      }
    end

    def finished_at
      @finished_at ||= Time.current
    end
  end
end
