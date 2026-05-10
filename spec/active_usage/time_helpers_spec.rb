# frozen_string_literal: true

RSpec.describe ActiveUsage::TimeHelpers do
  describe ".duration_ms" do
    it "returns the duration between two times in milliseconds" do
      started = Time.at(0)
      finished = Time.at(1.5)

      expect(described_class.duration_ms(started, finished)).to eq(1500.0)
    end

    it "rounds to 3 decimal places" do
      started = Time.at(0)
      finished = Time.at(0.0001234)

      expect(described_class.duration_ms(started, finished)).to eq(0.123)
    end

    it "returns 0.0 for equal times" do
      t = Time.now

      expect(described_class.duration_ms(t, t)).to eq(0.0)
    end
  end
end
