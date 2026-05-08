# frozen_string_literal: true

module ActiveUsage
  class WindowStartedAt
    def initialize(finished_at, size)
      @finished_at = finished_at
      @size = size
    end

    def call
      Time.at(epoch - (epoch % @size))
    end

    private

    def epoch
      @epoch ||= @finished_at.to_i
    end
  end
end
