# frozen_string_literal: true

module ActiveUsage
  class Tags
    KEY = :activeusage_tags

    def initialize(tags)
      @tags = tags
    end

    def tag(**tags)
      ActiveSupport::IsolatedExecutionState[KEY] = current.merge(tags)
    end

    def current
      ActiveSupport::IsolatedExecutionState[KEY] || @tags
    end

    def flush
      ActiveSupport::IsolatedExecutionState[KEY] = @tags
    end
  end
end
