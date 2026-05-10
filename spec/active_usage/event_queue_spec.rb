# frozen_string_literal: true

RSpec.describe ActiveUsage::EventQueue do
  subject(:queue) { described_class.new(max_size, batch_size) }

  let(:max_size) { 5 }
  let(:batch_size) { 3 }

  describe "#push" do
    it "adds an event to the queue" do
      queue.push("event")

      expect(queue.size).to eq(1)
    end

    it "accepts multiple events up to max_size" do
      max_size.times { queue.push("event") }

      expect(queue.size).to eq(max_size)
    end

    it "drops events when full" do
      max_size.times { queue.push("event") }
      queue.push("overflow")

      expect(queue.size).to eq(max_size)
    end

    it "increments dropped_count when full" do
      max_size.times { queue.push("event") }
      3.times { queue.push("overflow") }

      expect(queue.dropped_count).to eq(3)
    end
  end

  describe "#drain" do
    it "returns an empty array when queue is empty" do
      expect(queue.drain).to eq([])
    end

    it "returns all events when fewer than batch_size" do
      2.times { |i| queue.push("event_#{i}") }

      expect(queue.drain.size).to eq(2)
    end

    it "returns at most batch_size events" do
      max_size.times { |i| queue.push("event_#{i}") }

      expect(queue.drain.size).to eq(batch_size)
    end

    it "removes drained events from the queue" do
      batch_size.times { queue.push("event") }
      queue.drain

      expect(queue.size).to eq(0)
    end

    it "preserves event order" do
      events = %w[a b c]
      events.each { |e| queue.push(e) }

      expect(queue.drain).to eq(events)
    end
  end

  describe "#size" do
    it "returns 0 for an empty queue" do
      expect(queue.size).to eq(0)
    end

    it "reflects current queue length" do
      2.times { queue.push("event") }

      expect(queue.size).to eq(2)
    end
  end

  describe "#flush_ready?" do
    it "returns false when below batch_size" do
      (batch_size - 1).times { queue.push("event") }

      expect(queue.flush_ready?).to be(false)
    end

    it "returns true when at batch_size" do
      batch_size.times { queue.push("event") }

      expect(queue.flush_ready?).to be(true)
    end

    it "returns true when above batch_size" do
      (batch_size + 1).times { queue.push("event") }

      expect(queue.flush_ready?).to be(true)
    end
  end

  describe "#dropped_count" do
    it "returns 0 initially" do
      expect(queue.dropped_count).to eq(0)
    end

    it "does not increment for successful pushes" do
      queue.push("event")

      expect(queue.dropped_count).to eq(0)
    end
  end
end
