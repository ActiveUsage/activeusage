# frozen_string_literal: true

RSpec.describe ActiveUsage::Configuration do
  subject(:configuration) { described_class.new }

  describe "#adapter" do
    it "defaults to nil" do
      expect(configuration.adapter).to be_nil
    end

    it "accepts an object that responds to the required interface" do
      adapter = instance_double(ActiveUsage::Adapters::Base, record: nil, clear!: nil, shutdown!: nil)

      expect { configuration.adapter = adapter }.not_to raise_error
      expect(configuration.adapter).to eq(adapter)
    end

    it "raises ArgumentError for an object missing required methods" do
      expect { configuration.adapter = :active_record }
        .to raise_error(ArgumentError, /adapter must respond to/)
    end

    it "raises ArgumentError listing the missing methods" do
      expect { configuration.adapter = Object.new }
        .to raise_error(ArgumentError, /record, clear!, shutdown!/)
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
