# frozen_string_literal: true

module ActiveUsage
  module Instrumentation
    class Subscriber
      ACTION_CONTROLLER_EVENT = "process_action.action_controller"

      def call
        subscribe_to_sql
        subscribe_to_actions
      end

      private

      def subscribe_to_sql
        ActiveSupport::Notifications.subscribe("sql.active_record") do |_name, started, finished, _id, payload|
          next if payload[:cached]

          ActiveUsage::Instrumentation::RuntimeState.add_sql_event(
            payload,
            duration_ms: duration_ms(started, finished)
          )
        end
      end

      def subscribe_to_actions
        ActiveSupport::Notifications.subscribe(ACTION_CONTROLLER_EVENT) do |_name, started, finished, _id, payload|
          handle_action(started, finished, payload)
        end
      end

      def handle_action(started, finished, payload)
        if activeusage_controller?(payload)
          ActiveUsage::Instrumentation::RuntimeState.clear_sql_state
          return
        end

        ActiveUsage.record(**action_event_attributes(started, finished, payload))
      end

      def action_event_attributes(started, finished, payload)
        {
          type: :request,
          name: controller_action_name(payload),
          started_at: started,
          finished_at: finished,
          allocations: payload[:allocations].to_i,
          tags: { controller: payload[:controller], action: payload[:action] }
        }.merge(sql_event_attributes)
      end

      def sql_event_attributes
        {
          sql_calls: ActiveUsage::Instrumentation::RuntimeState.consume_calls,
          sql_queries: ActiveUsage::Instrumentation::RuntimeState.consume_sql_queries
        }
      end

      def controller_action_name(payload)
        [payload[:controller], payload[:action]].compact.join("#")
      end

      def duration_ms(started, finished)
        ((finished - started) * 1000.0).round(3)
      end

      def activeusage_controller?(payload)
        payload[:controller].to_s.start_with?("ActiveUsage::")
      end
    end
  end
end
