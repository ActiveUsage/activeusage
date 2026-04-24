# frozen_string_literal: true

RSpec.describe ActiveUsage::TimeWindow do
  subject { described_class.new(event, size) }

  let(:event) do
    instance_double(ActiveUsage::Event, finished_at: finished_at)
  end

  describe "#call" do
    context "when finished_at falls on the boundary" do
      let(:finished_at) { Time.at(1_020) }
      let(:size) { 60 }

      it "returns the start of the bucket" do
        expect(subject.call).to eq(1_020)
      end
    end

    context "when finished_at is over the boundary" do
      let(:finished_at) { Time.at(1_045) }
      let(:size) { 60 }

      it "truncates to the nearest lower multiple of size" do
        expect(subject.call).to eq(1_020)
      end
    end

    context "when finished_at is exactly at the end of a bucket" do
      let(:finished_at) { Time.at(1_200) }
      let(:size) { 600 }

      it "just works" do
        expect(subject.call).to eq(1_200)
      end
    end

    context "when window size is about 5-minutes" do
      let(:finished_at) { Time.at(1_700_000_123) }
      let(:size) { 300 }

      it "just works" do
        expect(subject.call).to eq(1_700_000_123 - (1_700_000_123 % 300))
      end
    end
  end
end
