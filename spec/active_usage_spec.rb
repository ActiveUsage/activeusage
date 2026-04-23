# frozen_string_literal: true

RSpec.describe ActiveUsage do
  it "has a version number" do
    expect(ActiveUsage::VERSION).not_to be nil
  end

  describe ".configuration" do
    it "returns a Configuration instance" do
      expect(described_class.configuration).to be_a(ActiveUsage::Configuration)
    end

    it "memoizes the configuration" do
      expect(described_class.configuration).to be(described_class.configuration)
    end
  end

  describe ".configure" do
    it "yields the configuration object" do
      expect { |b| described_class.configure(&b) }.to yield_with_args(ActiveUsage::Configuration)
    end

    it "allows setting configuration values" do
      described_class.configure { |c| c.store = :active_record }

      expect(described_class.configuration.store).to eq(:active_record)
    end
  end
end
