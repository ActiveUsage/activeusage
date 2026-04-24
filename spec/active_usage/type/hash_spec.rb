# frozen_string_literal: true

RSpec.describe ActiveUsage::Type::Hash do
  subject { described_class.new }

  describe "#cast" do
    it "symbolizes string keys" do
      expect(subject.cast("foo" => 1, "bar" => 2)).to eq(foo: 1, bar: 2)
    end

    it "leaves symbol keys unchanged" do
      expect(subject.cast(foo: 1, bar: 2)).to eq(foo: 1, bar: 2)
    end

    it "returns nil for non-hash values" do
      expect(subject.cast("string")).to be_nil
      expect(subject.cast(42)).to be_nil
      expect(subject.cast([1, 2])).to be_nil
    end

    it "returns nil for nil" do
      expect(subject.cast(nil)).to be_nil
    end

    it "handles an empty hash" do
      expect(subject.cast({})).to eq({})
    end

    it "handles mixed string and symbol keys" do
      expect(subject.cast("foo" => 1, bar: 2)).to eq(foo: 1, bar: 2)
    end
  end

  describe "registration" do
    it "is registered as :hash type in ActiveModel" do
      expect(ActiveModel::Type.lookup(:hash)).to be_a(described_class)
    end
  end
end
