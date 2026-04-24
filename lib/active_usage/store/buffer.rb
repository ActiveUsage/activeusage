# frozen_string_literal: true

module ActiveUsage
  module Store
    class Buffer
      def initialize(store)
        @store = store
      end

      def record(_events); end
    end
  end
end
