# frozen_string_literal: true

RSpec.describe ActiveUsage::Adapters::Http do
  subject(:adapter) { described_class.new("https://api.example.com/events", "secret-key") }

  let(:event) { instance_double(ActiveUsage::Event, attributes: { type: "request", name: "GET /" }) }

  describe "#record" do
    context "when events list is empty" do
      it "returns true without making an HTTP request" do
        expect(Net::HTTP).not_to receive(:start)

        expect(adapter.record([])).to be(true)
      end
    end

    context "with events" do
      let(:http) { instance_double(Net::HTTP) }
      let(:response) { instance_double(Net::HTTPSuccess) }

      before do
        allow(Net::HTTP).to receive(:start).and_yield(http)
        allow(http).to receive(:request).and_return(response)
        allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
      end

      it "returns true on success" do
        expect(adapter.record([event])).to be(true)
      end

      it "sends a POST request" do
        adapter.record([event])

        expect(http).to have_received(:request) do |req|
          expect(req).to be_a(Net::HTTP::Post)
        end
      end

      it "sets Content-Type to application/json" do
        adapter.record([event])

        expect(http).to have_received(:request) do |req|
          expect(req["Content-Type"]).to eq("application/json")
        end
      end

      it "sets Authorization header with Bearer token" do
        adapter.record([event])

        expect(http).to have_received(:request) do |req|
          expect(req["Authorization"]).to eq("Bearer secret-key")
        end
      end

      it "returns false when the response is not a success" do
        allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(false)

        expect(adapter.record([event])).to be(false)
      end
    end

    context "on network error" do
      it "returns false" do
        allow(Net::HTTP).to receive(:start).and_raise(StandardError)

        expect(adapter.record([event])).to be(false)
      end
    end
  end

  describe "#clear!" do
    it "returns 0" do
      expect(adapter.clear!).to eq(0)
    end
  end

  describe "#shutdown!" do
    it "does not raise" do
      expect { adapter.shutdown! }.not_to raise_error
    end
  end
end
