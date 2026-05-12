# frozen_string_literal: true

RSpec.describe ActiveUsage::Adapters::Base do
  subject(:adapter) { described_class.new }

  it "raises NotImplementedError for #record" do
    expect { adapter.record([]) }.to raise_error(NotImplementedError)
  end

  it "raises NotImplementedError for #clear!" do
    expect { adapter.clear! }.to raise_error(NotImplementedError)
  end

  it "raises NotImplementedError for #shutdown!" do
    expect { adapter.shutdown! }.to raise_error(NotImplementedError)
  end
end
