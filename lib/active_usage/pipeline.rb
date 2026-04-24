# frozen_string_literal: true

module ActiveUsage
  class Pipeline
    def initialize(configuration)
      @configuration = configuration
    end

    def call(event)
      event.window_started_at = TimeWindow.new(event, @configuration.window_size)

      ActiveUsage.store.record([event])
      ActiveSupport::Notifications.instrument("activeusage.event_recorded", event: event)

      event
    end
  end
end
