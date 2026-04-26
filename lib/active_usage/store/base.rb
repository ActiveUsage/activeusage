# frozen_string_literal: true

module ActiveUsage
  module Store
    class Base
      def record(_events)
        NotImplementedError
      end

      def clear!
        raise NotImplementedError
      end

      def flush!
        raise NotImplementedError
      end

      def shutdown!
        raise NotImplementedError
      end
    end
  end
end
