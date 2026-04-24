# frozen_string_literal: true

module ActiveUsage
  module Store
    class Base
      def record(_events)
        NotImplementedError
      end
    end
  end
end
