# frozen_string_literal: true

RSpec.describe ActiveUsage::Middleware do
  let(:app_response) { [200, {}, ["OK"]] }
  let(:app) { ->(_env) { app_response } }

  subject(:middleware) { described_class.new(app) }

  before { allow(ActiveUsage.tags).to receive(:flush).and_call_original }

  describe "#call" do
    it "delegates to the inner app" do
      expect(middleware.call({})).to eq(app_response)
    end

    it "flushes tags before calling the app" do
      called_order = []
      allow(ActiveUsage.tags).to receive(:flush) { called_order << :flush }
      allow(app).to receive(:call) do
        called_order << :app
        app_response
      end

      middleware.call({})

      expect(called_order.first).to eq(:flush)
    end

    it "flushes tags after calling the app" do
      middleware.call({})

      expect(ActiveUsage.tags).to have_received(:flush).twice
    end

    it "flushes tags even when the app raises" do
      raising_app = ->(_env) { raise "boom" }
      middleware = described_class.new(raising_app)

      expect { middleware.call({}) }.to raise_error("boom")
      expect(ActiveUsage.tags).to have_received(:flush).at_least(:once)
    end
  end
end
