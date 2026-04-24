# frozen_string_literal: true

RSpec.describe ActiveUsage::Context do
  after { described_class.delete }

  describe ".current" do
    it "returns a hash" do
      expect(described_class.current).to be_a(Hash)
    end

    it "returns the same object on repeated calls" do
      expect(described_class.current).to equal(described_class.current)
    end
  end

  describe ".tags" do
    it "returns an empty hash when no tags have been set" do
      expect(described_class.tags).to eq({})
    end

    it "returns the tags set via .tag" do
      described_class.tag(env: "production")

      expect(described_class.tags).to eq(env: "production")
    end
  end

  describe ".tag" do
    it "stores tags with symbol keys" do
      described_class.tag("region" => "eu")

      expect(described_class.tags).to eq(region: "eu")
    end

    it "merges new tags with existing ones" do
      described_class.tag(env: "production")
      described_class.tag(region: "eu")

      expect(described_class.tags).to eq(env: "production", region: "eu")
    end

    it "overwrites an existing tag with the same key" do
      described_class.tag(env: "staging")
      described_class.tag(env: "production")

      expect(described_class.tags).to eq(env: "production")
    end
  end

  describe ".delete" do
    it "clears the context so tags return empty hash afterwards" do
      described_class.tag(env: "production")
      described_class.delete

      expect(described_class.tags).to eq({})
    end

    it "clears the context so current returns a fresh hash afterwards" do
      original = described_class.current
      described_class.delete

      expect(described_class.current).not_to equal(original)
    end
  end
end
