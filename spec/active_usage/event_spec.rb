# frozen_string_literal: true

RSpec.describe ActiveUsage::Event do
  subject { described_class.new }

  describe "attributes" do
    it "defaults all attributes to nil" do
      expect(subject.type).to be_nil
      expect(subject.name).to be_nil
      expect(subject.started_at).to be_nil
      expect(subject.finished_at).to be_nil
      expect(subject.duration_ms).to be_nil
      expect(subject.sql_duration_ms).to be_nil
      expect(subject.sql_calls).to be_nil
      expect(subject.allocations).to be_nil
      expect(subject.external_calls).to be_nil
      expect(subject.retry_count).to be_nil
      expect(subject.cpu_time_ms).to be_nil
      expect(subject.memory_bytes).to be_nil
      expect(subject.tags).to be_nil
      expect(subject.metadata).to be_nil
      expect(subject.window_started_at).to be_nil
    end
  end

  describe "initialization" do
    it "accepts attributes as keyword arguments" do
      event = described_class.new(
        type: "request",
        name: "GET /users",
        duration_ms: 42.5,
        sql_calls: 3
      )

      expect(event.type).to eq("request")
      expect(event.name).to eq("GET /users")
      expect(event.duration_ms).to eq(42.5)
      expect(event.sql_calls).to eq(3)
    end
  end

  describe "type casting" do
    it "casts duration_ms to float" do
      subject.duration_ms = "12"

      expect(subject.duration_ms).to eq(12.0)
    end

    it "casts sql_calls to integer" do
      subject.sql_calls = "5"

      expect(subject.sql_calls).to eq(5)
    end

    it "casts started_at to time" do
      subject.started_at = "2026-01-01 10:00:00"

      expect(subject.started_at).to be_a(Time)
    end

    it "symbolizes tags keys" do
      subject.tags = { "env" => "production", "region" => "eu" }

      expect(subject.tags).to eq(env: "production", region: "eu")
    end

    it "symbolizes metadata keys" do
      subject.metadata = { "user_id" => 42 }

      expect(subject.metadata).to eq(user_id: 42)
    end

    it "rejects non-hash value for tags" do
      subject.tags = "invalid"

      expect(subject.tags).to be_nil
    end
  end
end
