# frozen_string_literal: true

RSpec.describe ActiveUsage::Instrumentation::Subscriber do
  subject(:subscriber) { described_class.new }

  before do
    described_class.unsubscribe_all
    allow(ActiveSupport::Notifications).to receive(:subscribe).and_return(double("subscription"))
    allow(ActiveSupport::Notifications).to receive(:unsubscribe)
  end

  describe "#call" do
    it "subscribes to sql.active_record" do
      subscriber.call

      expect(ActiveSupport::Notifications).to have_received(:subscribe).with("sql.active_record")
    end

    it "subscribes to process_action.action_controller" do
      subscriber.call

      expect(ActiveSupport::Notifications)
        .to have_received(:subscribe)
        .with(described_class::ACTION_CONTROLLER_EVENT)
    end

    it "unsubscribes existing subscriptions before re-subscribing" do
      existing = double("subscription")
      described_class.track([existing])

      subscriber.call

      expect(ActiveSupport::Notifications).to have_received(:unsubscribe).with(existing)
    end
  end

  describe "action tracking" do
    before do
      allow(ActiveSupport::Notifications).to receive(:subscribe).and_call_original
      allow(ActiveSupport::Notifications).to receive(:unsubscribe).and_call_original
      allow(ActiveUsage).to receive(:record)
      described_class.new.call
    end

    after { described_class.unsubscribe_all }

    it "records a request event when process_action fires" do
      ActiveSupport::Notifications.instrument(
        "process_action.action_controller",
        controller: "UsersController",
        action: "index",
        allocations: 42
      ) { nil }

      expect(ActiveUsage).to have_received(:record).with(
        hash_including(type: :request, name: "UsersController#index", allocations: 42)
      )
    end

    it "includes sql_queries in the recorded event" do
      ActiveSupport::Notifications.instrument(
        "process_action.action_controller",
        controller: "UsersController",
        action: "index",
        allocations: 0
      ) { nil }

      expect(ActiveUsage).to have_received(:record).with(hash_including(sql_queries: []))
    end
  end

  describe "sql tracking" do
    before do
      allow(ActiveSupport::Notifications).to receive(:subscribe).and_call_original
      allow(ActiveSupport::Notifications).to receive(:unsubscribe).and_call_original
      described_class.new.call
    end

    after { described_class.unsubscribe_all }

    it "skips cached sql events" do
      ActiveSupport::Notifications.instrument(
        "sql.active_record", sql: "SELECT 1", name: "Test", cached: true
      ) { nil }

      expect(ActiveUsage::Instrumentation::RuntimeState.sql_fingerprints).to eq({})
    end
  end
end
