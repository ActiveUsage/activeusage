# frozen_string_literal: true

module ActiveUsage
  module Instrumentation
    class Subscriber
      def initialize(config:)
        @config = config
      end

      def attach!
        subscribe_to_sql
        subscribe_to_actions
      end

      private

      attr_reader :config

      def subscribe_to_sql
        ActiveSupport::Notifications.subscribe("sql.active_record") do |_name, started, finished, _id, payload|
          next if payload[:cached] || payload[:name] == "SCHEMA"

          ActiveUsage::Instrumentation::RuntimeState.add_sql_event(
            payload,
            duration_ms: duration_ms(started, finished)
          )
        end
      end

      def subscribe_to_actions
        ActiveSupport::Notifications.subscribe("process_action.action_controller") do |_name, started, finished, _id, payload|
          if activeusage_controller?(payload)
            ActiveUsage::Instrumentation::RuntimeState.clear_sql_state
            next
          end

          ActiveUsage.record(
            type: :request,
            name: controller_action_name(payload),
            started_at: started,
            finished_at: finished,
            duration_ms: duration_ms(started, finished),
            sql_duration_ms: ActiveUsage::Instrumentation::RuntimeState.consume_runtime,
            sql_calls: ActiveUsage::Instrumentation::RuntimeState.consume_calls,
            allocations: payload[:allocations].to_i,
            tags: { controller: payload[:controller], action: payload[:action] },
            sql_queries: ActiveUsage::Instrumentation::RuntimeState.consume_sql_queries
          )
        end
      end

      def controller_action_name(payload)
        [payload[:controller], payload[:action]].compact.join("#")
      end

      def duration_ms(started, finished)
        ActiveUsage::TimeHelpers.duration_ms(started, finished)
      end

      def activeusage_controller?(payload)
        payload[:controller].to_s.start_with?("ActiveUsage::")
      end
    end
  end
end
