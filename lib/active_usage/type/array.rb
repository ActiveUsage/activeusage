# frozen_string_literal: true

module ActiveUsage
  module Type
    # ActiveModel type that casts hash values by symbolizing all keys.
    class Array < ActiveModel::Type::Value
      def cast(value)
        return [] unless value.is_a?(::Array)

        value
      end
    end
  end
end

ActiveModel::Type.register(:array, ActiveUsage::Type::Array)
