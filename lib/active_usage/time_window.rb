# frozen_string_literal: true

module ActiveUsage
  class TimeWindow
    def initialize(event, size)
      @event = event
      @size = size
    end

    def call
      epoch - (epoch % @size)
    end

    private

    def epoch
      @epoch ||= @event.finished_at.to_i
    end
  end
end
