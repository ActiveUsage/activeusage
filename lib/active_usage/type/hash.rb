# frozen_string_literal: true

module ActiveUsage
  module Type
    # ActiveModel type that casts hash values by symbolizing all keys.
    class Hash < ActiveModel::Type::Value
      def cast(value)
        return nil unless value.is_a?(::Hash)

        value.transform_keys(&:to_sym)
      end
    end
  end
end

ActiveModel::Type.register(:hash, ActiveUsage::Type::Hash)
