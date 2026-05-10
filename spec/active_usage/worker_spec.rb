# frozen_string_literal: true

RSpec.describe ActiveUsage::Worker do
  describe "block invocation" do
    it "calls the block" do
      signal = Queue.new
      worker = described_class.new(0) { signal.push(:called) }

      expect(signal.pop).to eq(:called)

      worker.stop!
      worker.join(1)
    end

    it "calls the block repeatedly" do
      signal = Queue.new
      worker = described_class.new(0) { signal.push(:called) }
      results = Array.new(2) { signal.pop }
      worker.stop!
      worker.join(1)

      expect(results).to eq(%i[called called])
    end
  end

  describe "#stop!" do
    it "stops the worker from calling the block after join" do
      counter = 0
      mutex = Mutex.new
      worker = described_class.new(0) { mutex.synchronize { counter += 1 } }
      sleep 0.05
      worker.stop!
      worker.join(1)
      count_at_stop = mutex.synchronize { counter }
      sleep 0.05

      expect(mutex.synchronize { counter }).to eq(count_at_stop)
    end

    it "is idempotent" do
      worker = described_class.new(3600) { nil }

      expect { 3.times { worker.stop! } }.not_to raise_error

      worker.join(1)
    end
  end

  describe "#join" do
    it "returns after the thread finishes" do
      worker = described_class.new(0) { nil }
      worker.stop!
      result = worker.join(1)

      expect(result).not_to be_nil
    end
  end

  describe "error handling" do
    it "does not propagate StandardError from the block" do
      signal = Queue.new
      worker = described_class.new(0) do
        signal.push(:before_error)
        raise "boom"
      end
      signal.pop
      worker.stop!

      expect { worker.join(1) }.not_to raise_error
    end

    it "continues running after StandardError in the block" do
      calls = 0
      signal = Queue.new
      worker = described_class.new(0) do
        calls += 1
        raise "boom" if calls == 1

        signal.push(:recovered)
      end
      signal.pop
      worker.stop!
      worker.join(1)

      expect(calls).to be >= 2
    end
  end
end
