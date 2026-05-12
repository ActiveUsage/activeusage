# frozen_string_literal: true

module ActiveUsage
  module Instrumentation
    module RuntimeState
      SQL_CALLS_KEY = :activeusage_sql_calls
      SQL_FINGERPRINTS_KEY = :activeusage_sql_fingerprints
      MAX_SQL_QUERIES_PER_EVENT = 20

      module_function

      def sql_calls
        ActiveSupport::IsolatedExecutionState[SQL_CALLS_KEY].to_i
      end

      def sql_fingerprints
        ActiveSupport::IsolatedExecutionState[SQL_FINGERPRINTS_KEY] || {}
      end

      def add_sql_event(payload, duration_ms:)
        ActiveSupport::IsolatedExecutionState[SQL_CALLS_KEY] = sql_calls + 1
        ActiveSupport::IsolatedExecutionState[SQL_FINGERPRINTS_KEY] = accumulate_sql_fingerprint(
          sql_fingerprints,
          payload: payload,
          duration_ms: duration_ms
        )
      end

      def consume_calls
        consume_numeric(SQL_CALLS_KEY).to_i
      end

      def clear_sql_state
        ActiveSupport::IsolatedExecutionState[SQL_CALLS_KEY] = 0
        ActiveSupport::IsolatedExecutionState[SQL_FINGERPRINTS_KEY] = {}
      end

      def consume_sql_queries
        queries = sql_fingerprints
        ActiveSupport::IsolatedExecutionState[SQL_FINGERPRINTS_KEY] = {}
        queries.values
               .sort_by { |query| -query[:total_duration_ms].to_f }
               .first(MAX_SQL_QUERIES_PER_EVENT)
               .map { |query| format_sql_query(query) }
      end

      def accumulate_sql_fingerprint(fingerprints, payload:, duration_ms:)
        fingerprint = normalize_sql(payload[:sql].to_s)
        return fingerprints if fingerprint.empty?

        entry = find_or_build_entry(fingerprints, fingerprint, payload)
        update_entry(entry, duration_ms, payload)
        fingerprints.merge(fingerprint => entry)
      end

      def normalize_sql(sql)
        normalized = sql.dup
        normalized.gsub!(/'(?:[^']|'')*'/, "?")
        normalized.gsub!(/"([^"]*)"/, '\1')
        normalized.gsub!(/\$\d+/, "?")
        normalized.gsub!(/\b\d+(?:\.\d+)?\b/, "?")
        normalized.gsub!(/\(\s*\?(?:\s*,\s*\?)+\s*\)/, "(?)")
        normalized.gsub!(/\s+/, " ")
        normalized.strip!
        normalized
      end

      def format_sql_query(query)
        {
          fingerprint: query[:fingerprint],
          total_duration_ms: query[:total_duration_ms].to_f.round(3),
          calls: query[:calls].to_i,
          adapter_name: query[:adapter_name]
        }
      end

      def find_or_build_entry(fingerprints, fingerprint, payload)
        fingerprints[fingerprint] || {
          fingerprint: fingerprint,
          total_duration_ms: 0.0,
          calls: 0,
          adapter_name: payload[:name].to_s
        }
      end

      def update_entry(entry, duration_ms, payload)
        entry[:total_duration_ms] += duration_ms.to_f
        entry[:calls] += 1
        entry[:adapter_name] = payload[:name].to_s if entry[:adapter_name].to_s.empty?
      end

      def consume_numeric(key)
        value = ActiveSupport::IsolatedExecutionState[key]
        ActiveSupport::IsolatedExecutionState[key] = 0
        value.to_f
      end

      private_class_method :consume_numeric, :format_sql_query, :find_or_build_entry, :update_entry
    end
  end
end
