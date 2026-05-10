# frozen_string_literal: true

RSpec.describe ActiveUsage::Type::Array do
  subject { described_class.new }

  describe "#cast" do
    it "returns an array as-is" do
      expect(subject.cast([1, 2, 3])).to eq([1, 2, 3])
    end

    it "returns an empty array for an empty array" do
      expect(subject.cast([])).to eq([])
    end

    it "returns an empty array for a string" do
      expect(subject.cast("string")).to eq([])
    end

    it "returns an empty array for nil" do
      expect(subject.cast(nil)).to eq([])
    end

    it "returns an empty array for a hash" do
      expect(subject.cast({ foo: 1 })).to eq([])
    end

    it "returns an empty array for an integer" do
      expect(subject.cast(42)).to eq([])
    end
  end

  describe "registration" do
    it "is registered as :array type in ActiveModel" do
      expect(ActiveModel::Type.lookup(:array)).to be_a(described_class)
    end
  end
end
