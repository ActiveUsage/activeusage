# frozen_string_literal: true

RSpec.describe ActiveUsage::Instrumentation::RuntimeState do
  before { described_class.clear_sql_state }
  after { described_class.clear_sql_state }

  let(:payload) { { sql: "SELECT * FROM users WHERE id = 1", name: "User Load" } }

  describe ".sql_calls" do
    it "returns 0 initially" do
      expect(described_class.sql_calls).to eq(0)
    end
  end

  describe ".add_sql_event" do
    it "increments sql_calls" do
      described_class.add_sql_event(payload, duration_ms: 5.5)

      expect(described_class.sql_calls).to eq(1)
    end

    it "accumulates across multiple calls" do
      described_class.add_sql_event(payload, duration_ms: 5.0)
      described_class.add_sql_event(payload, duration_ms: 3.0)

      expect(described_class.sql_calls).to eq(2)
    end
  end

  describe ".consume_calls" do
    it "returns the accumulated call count" do
      described_class.add_sql_event(payload, duration_ms: 1.0)

      expect(described_class.consume_calls).to eq(1)
    end

    it "resets the call count to 0 after consuming" do
      described_class.add_sql_event(payload, duration_ms: 1.0)
      described_class.consume_calls

      expect(described_class.sql_calls).to eq(0)
    end
  end

  describe ".clear_sql_state" do
    it "resets sql_calls to 0" do
      described_class.add_sql_event(payload, duration_ms: 5.0)
      described_class.clear_sql_state

      expect(described_class.sql_calls).to eq(0)
    end

    it "resets sql_fingerprints to empty hash" do
      described_class.add_sql_event(payload, duration_ms: 5.0)
      described_class.clear_sql_state

      expect(described_class.sql_fingerprints).to eq({})
    end
  end

  describe ".consume_sql_queries" do
    it "returns an empty array when no queries were recorded" do
      expect(described_class.consume_sql_queries).to eq([])
    end

    it "returns query hashes with the expected keys" do
      described_class.add_sql_event(payload, duration_ms: 5.0)

      query = described_class.consume_sql_queries.first

      expect(query.keys).to contain_exactly(:fingerprint, :total_duration_ms, :calls, :adapter_name)
    end

    it "sorts queries by total_duration_ms descending" do
      described_class.add_sql_event({ sql: "SELECT 1", name: "Fast" }, duration_ms: 2.0)
      described_class.add_sql_event({ sql: "SELECT * FROM orders", name: "Slow" }, duration_ms: 10.0)

      queries = described_class.consume_sql_queries

      expect(queries.first[:total_duration_ms]).to be > queries.last[:total_duration_ms]
    end

    it "limits results to MAX_SQL_QUERIES_PER_EVENT" do
      21.times do |i|
        described_class.add_sql_event({ sql: "SELECT #{i} FROM table#{i}", name: "Load" }, duration_ms: i.to_f)
      end

      expect(described_class.consume_sql_queries.size).to eq(described_class::MAX_SQL_QUERIES_PER_EVENT)
    end

    it "resets fingerprints after consuming" do
      described_class.add_sql_event(payload, duration_ms: 1.0)
      described_class.consume_sql_queries

      expect(described_class.sql_fingerprints).to eq({})
    end

    it "aggregates repeated identical queries" do
      2.times { described_class.add_sql_event(payload, duration_ms: 5.0) }

      queries = described_class.consume_sql_queries

      expect(queries.size).to eq(1)
      expect(queries.first[:calls]).to eq(2)
      expect(queries.first[:total_duration_ms]).to eq(10.0)
    end
  end

  describe ".normalize_sql" do
    it "replaces string literals with ?" do
      expect(described_class.normalize_sql("SELECT * FROM users WHERE name = 'Alice'"))
        .to eq("SELECT * FROM users WHERE name = ?")
    end

    it "replaces integer literals with ?" do
      expect(described_class.normalize_sql("SELECT * FROM users WHERE id = 42"))
        .to eq("SELECT * FROM users WHERE id = ?")
    end

    it "replaces $N placeholders with ?" do
      expect(described_class.normalize_sql("SELECT * FROM users WHERE id = $1"))
        .to eq("SELECT * FROM users WHERE id = ?")
    end

    it "collapses IN clause lists into a single ?" do
      expect(described_class.normalize_sql("SELECT * FROM users WHERE id IN (1, 2, 3)"))
        .to eq("SELECT * FROM users WHERE id IN (?)")
    end

    it "normalizes multiple spaces into one" do
      expect(described_class.normalize_sql("SELECT  *  FROM   users"))
        .to eq("SELECT * FROM users")
    end

    it "strips leading and trailing whitespace" do
      expect(described_class.normalize_sql("  SELECT 1  ")).to eq("SELECT ?")
    end

    it "returns empty string for blank input" do
      expect(described_class.normalize_sql("   ")).to eq("")
    end
  end
end
