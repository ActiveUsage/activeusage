# frozen_string_literal: true

module ActiveUsage
  class Collector
    def initialize(configuration)
      @configuration = configuration
      @pipeline = Pipeline.new(configuration)
    end

    def record(type:, name:, started_at:, finished_at:, **attributes)
      event = Event.new(
        type: type,
        name: name,
        started_at: started_at,
        finished_at: finished_at,
        tags: @configuration.tags.merge(Context.tags).merge(attributes.delete(:tags) || {}),
        **attributes
      )

      @pipeline.call(event)
    end
  end
end
