# frozen_string_literal: true

RSpec.describe ActiveUsage do
  it "has a version number" do
    expect(ActiveUsage::VERSION).not_to be nil
  end

  describe ".configuration" do
    it "returns a Configuration instance" do
      expect(described_class.configuration).to be_a(ActiveUsage::Configuration)
    end

    it "memoizes the configuration" do
      expect(described_class.configuration).to be(described_class.configuration)
    end
  end

  describe ".configure" do
    it "yields the configuration object" do
      expect { |b| described_class.configure(&b) }.to yield_with_args(ActiveUsage::Configuration)
    end

    it "allows setting configuration values" do
      adapter = instance_double(ActiveUsage::Adapters::Base, record: nil, clear!: nil, shutdown!: nil)
      described_class.configure { |c| c.adapter = adapter }

      expect(described_class.configuration.adapter).to eq(adapter)
    end
  end

  describe ".tags" do
    it "returns a Tags instance" do
      expect(described_class.tags).to be_a(ActiveUsage::Tags)
    end

    it "memoizes the Tags instance" do
      expect(described_class.tags).to be(described_class.tags)
    end
  end

  describe ".record" do
    let(:store) { instance_double(ActiveUsage::Store, record: nil) }
    let(:started_at) { Time.now }
    let(:finished_at) { started_at + 1 }

    before { allow(described_class).to receive(:store).and_return(store) }
    after { described_class.tags.flush }

    it "returns an Event" do
      event = described_class.record(type: :request, name: "GET /", started_at: started_at, finished_at: finished_at)

      expect(event).to be_a(ActiveUsage::Event)
    end

    it "sets type and name on the event" do
      event = described_class.record(type: :request, name: "GET /", started_at: started_at, finished_at: finished_at)

      expect(event.type).to eq("request")
      expect(event.name).to eq("GET /")
    end

    it "sends the event to the store" do
      described_class.record(type: :request, name: "GET /", started_at: started_at, finished_at: finished_at)

      expect(store).to have_received(:record)
    end

    it "merges current tags into the event" do
      described_class.tags.tag(env: "test")
      event = described_class.record(type: :request, name: "GET /", started_at: started_at, finished_at: finished_at)

      expect(event.tags).to include(env: "test")
    end
  end

  describe ".track" do
    let(:store) { instance_double(ActiveUsage::Store, record: nil) }

    before { allow(described_class).to receive(:store).and_return(store) }

    it "yields the block" do
      expect { |b| described_class.track("task", &b) }.to yield_control
    end

    it "returns the block result" do
      expect(described_class.track("task") { 42 }).to eq(42)
    end

    it "records a task event" do
      described_class.track("my_task") { nil }

      expect(store).to have_received(:record).with(an_instance_of(ActiveUsage::Event))
    end
  end
end
