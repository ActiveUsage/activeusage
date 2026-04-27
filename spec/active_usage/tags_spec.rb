# frozen_string_literal: true

RSpec.describe ActiveUsage::Tags do
  subject(:tags) { described_class.new(tag: "test") }

  after { tags.flush }

  describe "#current" do
    it "returns a hash" do
      expect(tags.current).to be_a(Hash)
    end

    it "returns an empty hash when nothing has been set" do
      expect(tags.current).to eq({ tag: "test" })
    end
  end

  describe "#tag" do
    it "stores the provided tags" do
      tags.tag(env: "production")

      expect(tags.current).to eq(tag: "test", env: "production")
    end

    it "tags new tags with existing ones" do
      tags.tag(env: "production")
      tags.tag(region: "eu")

      expect(tags.current).to eq(tag: "test", env: "production", region: "eu")
    end

    it "new tags take precedence over existing ones with the same key" do
      tags.tag(env: "staging")
      tags.tag(env: "production")

      expect(tags.current).to eq(tag: "test", env: "production")
    end

    it "returns the updated tags hash" do
      result = tags.tag(env: "production")

      expect(result).to eq(tag: "test", env: "production")
    end
  end

  describe "#flush" do
    it "resets tags to an empty hash" do
      tags.tag(env: "production")
      tags.flush

      expect(tags.current).to eq({ tag: "test" })
    end
  end
end
