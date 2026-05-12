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
end
