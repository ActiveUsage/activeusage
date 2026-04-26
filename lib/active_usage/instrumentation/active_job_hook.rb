# frozen_string_literal: true

module ActiveUsage
  module Instrumentation
    module ActiveJobHooks
      extend ActiveSupport::Concern

      included do
        around_perform do |job, block|
          ActiveUsage::Context.delete
          ActiveUsage::Instrumentation::RuntimeState.clear_sql_state
          started_at = Time.current

          block.call
        ensure
          finished_at = Time.current
          ActiveUsage.record(
            type: :job,
            name: job.class.name,
            started_at: started_at,
            finished_at: finished_at,
            duration_ms: ActiveUsage::TimeHelpers.duration_ms(started_at, finished_at),
            sql_duration_ms: ActiveUsage::Instrumentation::RuntimeState.consume_runtime,
            sql_calls: ActiveUsage::Instrumentation::RuntimeState.consume_calls,
            retry_count: job.respond_to?(:executions) ? job.executions.to_i - 1 : 0,
            tags: { queue: job.queue_name },
            sql_queries: ActiveUsage::Instrumentation::RuntimeState.consume_sql_queries
          )
          ActiveUsage.store.flush!
          ActiveUsage::Instrumentation::RuntimeState.clear_sql_state
          ActiveUsage::Context.delete
        end
      end
    end
  end
end
