# frozen_string_literal: true

RSpec.describe ActiveUsage::Configuration do
  subject(:configuration) { described_class.new }

  describe "#adapter" do
    it "defaults to nil" do
      expect(configuration.adapter).to be_nil
    end
  end

  describe "#tags" do
    it "defaults to empty hash" do
      expect(configuration.tags).to eq({})
    end
  end

  describe "#window_size" do
    it "defaults to 300" do
      expect(configuration.window_size).to eq(300)
    end

    it "can be changed" do
      configuration.window_size = 60

      expect(configuration.window_size).to eq(60)
    end
  end
end
