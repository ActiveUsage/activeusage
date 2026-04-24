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

  describe "#window_size" do
    it "defaults to 300" do
      expect(configuration.window_size).to eq(300)
    end

    it "can be changed" do
      configuration.window_size = 60

      expect(configuration.window_size).to eq(60)
    end
  end

  describe "#application_name" do
    it "defaults to 'ActiveUsage'" do
      expect(configuration.application_name).to eq("ActiveUsage")
    end

    it "can be changed" do
      configuration.application_name = "MyApp"

      expect(configuration.application_name).to eq("MyApp")
    end
  end

  describe "#api_key" do
    it "defaults to nil" do
      expect(configuration.api_key).to be_nil
    end

    it "can be changed" do
      configuration.api_key = "secret"

      expect(configuration.api_key).to eq("secret")
    end
  end
end
