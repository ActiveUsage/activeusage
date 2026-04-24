# frozen_string_literal: true

RSpec.describe ActiveUsage::Configuration do
  subject(:configuration) { described_class.new }

  describe "#store" do
    it "defaults to :active_usage" do
      expect(configuration.store).to eq(:active_usage)
    end

    it "can be changed" do
      configuration.store = :active_record

      expect(configuration.store).to eq(:active_record)
    end
  end

  describe "#tags" do
    it "defaults to empty hash" do
      expect(configuration.tags).to eq({})
    end
  end
end
