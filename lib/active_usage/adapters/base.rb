# frozen_string_literal: true

module ActiveUsage
  module Adapters
    class Base
      def record(_events)
        raise NotImplementedError
      end

      def clear!
        raise NotImplementedError
      end

      def shutdown!
        raise NotImplementedError
      end
    end
  end
end
