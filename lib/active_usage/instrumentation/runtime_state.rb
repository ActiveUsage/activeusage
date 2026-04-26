# frozen_string_literal: true

module ActiveUsage
  module Instrumentation
    module RuntimeState
      SQL_RUNTIME_KEY = :activeusage_sql_runtime
      SQL_CALLS_KEY = :activeusage_sql_calls
      SQL_FINGERPRINTS_KEY = :activeusage_sql_fingerprints
      MAX_SQL_QUERIES_PER_EVENT = 5

      module_function

      def sql_runtime
        ActiveSupport::IsolatedExecutionState[SQL_RUNTIME_KEY].to_f
      end

      def sql_calls
        ActiveSupport::IsolatedExecutionState[SQL_CALLS_KEY].to_i
      end

      def sql_fingerprints
        ActiveSupport::IsolatedExecutionState[SQL_FINGERPRINTS_KEY] || {}
      end

      def add_sql_event(payload, duration_ms:)
        ActiveSupport::IsolatedExecutionState[SQL_RUNTIME_KEY] = sql_runtime + duration_ms.to_f
        ActiveSupport::IsolatedExecutionState[SQL_CALLS_KEY] = sql_calls + 1
        ActiveSupport::IsolatedExecutionState[SQL_FINGERPRINTS_KEY] = accumulate_sql_fingerprint(
          sql_fingerprints,
          payload: payload,
          duration_ms: duration_ms
        )
      end

      def consume_runtime
        consume_numeric(SQL_RUNTIME_KEY)
      end

      def consume_calls
        consume_numeric(SQL_CALLS_KEY).to_i
      end

      def clear_sql_state
        ActiveSupport::IsolatedExecutionState[SQL_RUNTIME_KEY] = 0.0
        ActiveSupport::IsolatedExecutionState[SQL_CALLS_KEY] = 0
        ActiveSupport::IsolatedExecutionState[SQL_FINGERPRINTS_KEY] = {}
      end

      def consume_sql_queries
        queries = sql_fingerprints
        ActiveSupport::IsolatedExecutionState[SQL_FINGERPRINTS_KEY] = {}

        queries.values
               .sort_by { |query| -query[:total_duration_ms].to_f }
               .first(MAX_SQL_QUERIES_PER_EVENT)
               .map do |query|
          {
            fingerprint: query[:fingerprint],
            total_duration_ms: query[:total_duration_ms].to_f.round(3),
            calls: query[:calls].to_i,
            adapter_name: query[:adapter_name]
          }
        end
      end

      def accumulate_sql_fingerprint(fingerprints, payload:, duration_ms:)
        sql = payload[:sql].to_s
        fingerprint = normalize_sql(sql)
        return fingerprints if fingerprint.empty?

        entry = fingerprints[fingerprint] || {
          fingerprint: fingerprint,
          total_duration_ms: 0.0,
          calls: 0,
          adapter_name: payload[:name].to_s
        }

        entry[:total_duration_ms] += duration_ms.to_f
        entry[:calls] += 1
        entry[:adapter_name] = payload[:name].to_s if entry[:adapter_name].to_s.empty?
        fingerprints.merge(fingerprint => entry)
      end

      def normalize_sql(sql)
        normalized = sql.dup
        normalized.gsub!(/'(?:[^']|'')*'/, "?") # 'string values' → ?
        normalized.gsub!(/"([^"]*)"/, '\1') # "identifier" → identifier
        normalized.gsub!(/\b\d+(?:\.\d+)?\b/, "?") # numbers → ?
        normalized.gsub!(/\$\d+/, "?") # $1 $2 placeholders → ?
        normalized.gsub!(/\(\s*\?(?:\s*,\s*\?)+\s*\)/, "(?)") # (?,?,?) → (?)
        normalized.gsub!(/\s+/, " ")
        normalized.strip!
        normalized
      end

      def consume_numeric(key)
        value = ActiveSupport::IsolatedExecutionState[key]
        ActiveSupport::IsolatedExecutionState[key] = 0
        value.to_f
      end
      private_class_method :consume_numeric
    end
  end
end
