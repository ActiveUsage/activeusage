# frozen_string_literal: true

module ActiveUsage
  module TimeHelpers
    module_function

    def duration_ms(started, finished)
      ((finished - started) * 1000.0).round(3)
    end
  end
end
