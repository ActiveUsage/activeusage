# frozen_string_literal: true

RSpec.describe ActiveUsage::Store do
  subject(:store) { described_class.new(adapter, batch_size: 3, flush_interval: 3600, max_queue_size: 5) }

  let(:adapter) { instance_double(ActiveUsage::Adapters::Base, record: nil, clear!: nil, shutdown!: nil) }

  after { store.shutdown! }

  describe "#record" do
    it "returns the event" do
      event = double("event")

      expect(store.record(event)).to eq(event)
    end

    it "does not flush before batch_size is reached" do
      2.times { store.record(double("event")) }

      expect(adapter).not_to have_received(:record)
    end

    it "flushes automatically when batch_size is reached" do
      3.times { store.record(double("event")) }

      expect(adapter).to have_received(:record).once
    end
  end

  describe "#flush!" do
    it "sends queued events to the adapter" do
      e1 = double("e1")
      e2 = double("e2")
      store.record(e1)
      store.record(e2)
      store.flush!

      expect(adapter).to have_received(:record).with([e1, e2])
    end

    it "does not call adapter when queue is empty" do
      store.flush!

      expect(adapter).not_to have_received(:record)
    end

    it "is safe to call multiple times" do
      store.record(double("event"))
      store.flush!

      expect { store.flush! }.not_to raise_error
    end
  end

  describe "#clear!" do
    it "flushes pending events before clearing" do
      store.record(double("event"))
      store.clear!

      expect(adapter).to have_received(:record)
    end

    it "delegates to the adapter" do
      store.clear!

      expect(adapter).to have_received(:clear!)
    end
  end

  describe "#shutdown!" do
    it "flushes remaining events before shutting down" do
      store.record(double("event"))
      store.shutdown!

      expect(adapter).to have_received(:record)
    end

    it "delegates shutdown to the adapter" do
      store.shutdown!

      expect(adapter).to have_received(:shutdown!)
    end

    it "is idempotent" do
      store.shutdown!
      store.shutdown!

      expect(adapter).to have_received(:shutdown!).once
    end
  end

  describe "instance tracking" do
    it "registers itself on initialization" do
      expect(described_class.instance_variable_get(:@instances)).to include(store)
    end

    it "unregisters itself after shutdown!" do
      store.shutdown!

      expect(described_class.instance_variable_get(:@instances)).not_to include(store)
    end
  end
end
