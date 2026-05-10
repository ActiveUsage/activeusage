# frozen_string_literal: true

module ActiveUsage
  class Recorder
    def initialize(attributes)
      @attributes = attributes
    end

    def call(store)
      store.record(event)
      ActiveSupport::Notifications.instrument("activeusage.event_recorded", event: event)

      event
    end

    private

    def event
      @event ||= Event.new(@attributes)
    end
  end
end
