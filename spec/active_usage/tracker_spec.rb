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
  end
end
