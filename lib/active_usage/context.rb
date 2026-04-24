# frozen_string_literal: true

module ActiveUsage
  # Holds per request / thread metadata that is automatically
  # attached to every event emitted within that execution context.
  module Context
    KEY = :"activeusage.context"

    class << self
      def current
        ActiveSupport::IsolatedExecutionState[KEY] ||= {}
      end

      def tags
        current[:tags] || {}
      end

      def tag(**other_tags)
        current[:tags] = tags.merge(other_tags.transform_keys(&:to_sym))
      end

      def delete
        ActiveSupport::IsolatedExecutionState.delete(KEY)
      end
    end
  end
end
