# frozen_string_literal: true

RSpec.describe ActiveUsage::Tracker do
  subject(:tracker) { described_class.new("my_task", { env: "test" }) }

  before { allow(ActiveUsage).to receive(:record) }

  describe "#call" do
    it "yields the block" do
      expect { |b| tracker.call(&b) }.to yield_control
    end

    it "returns the block result" do
      expect(tracker.call { 42 }).to eq(42)
    end

    it "records a task event after the block" do
      tracker.call { nil }

      expect(ActiveUsage).to have_received(:record)
    end

    it "records type :task" do
      tracker.call { nil }

      expect(ActiveUsage).to have_received(:record).with(hash_including(type: :task))
    end

    it "records the given name" do
      tracker.call { nil }

      expect(ActiveUsage).to have_received(:record).with(hash_including(name: "my_task"))
    end

    it "records the given tags" do
      tracker.call { nil }

      expect(ActiveUsage).to have_received(:record).with(hash_including(tags: { env: "test" }))
    end

    it "captures sql_queries for events fired within the block" do
      tracker.call do
        ActiveSupport::Notifications.instrument("sql.active_record", sql: "SELECT 1", name: "Test") { nil }
      end

      expect(ActiveUsage).to have_received(:record).with(
        hash_including(sql_queries: [hash_including(fingerprint: "SELECT ?", calls: 1)])
      )
    end

    it "skips cached sql events" do
      tracker.call do
        ActiveSupport::Notifications.instrument("sql.active_record", sql: "SELECT 1", name: "Test", cached: true) { nil }
      end

      expect(ActiveUsage).to have_received(:record).with(hash_including(sql_queries: []))
    end
  end
end
