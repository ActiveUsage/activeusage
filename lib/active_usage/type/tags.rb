# frozen_string_literal: true

module ActiveUsage
  module Type
    class Tags < ActiveModel::Type::Value
      def cast(value)
        return nil unless value.is_a?(::Hash)

        value.transform_keys(&:to_sym)
      end
    end
  end
end

ActiveModel::Type.register(:tags, ActiveUsage::Type::Tags)
