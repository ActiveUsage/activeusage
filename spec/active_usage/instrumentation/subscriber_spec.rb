# frozen_string_literal: true

RSpec.describe ActiveUsage::Instrumentation::Subscriber do
  subject(:subscriber) { described_class.new }

  before { allow(ActiveSupport::Notifications).to receive(:subscribe) }

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
  end
end
