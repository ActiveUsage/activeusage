# frozen_string_literal: true

module ActiveUsage
  module Type
    class SqlQueries < ActiveModel::Type::Value
      def cast(value)
        return [] unless value.is_a?(::Array)

        value
      end
    end
  end
end

ActiveModel::Type.register(:sql_queries, ActiveUsage::Type::SqlQueries)
