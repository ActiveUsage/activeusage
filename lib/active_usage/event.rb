# frozen_string_literal: true

module ActiveUsage
  # Represents a single tracked usage event with timing, resource.
  class Event
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :type, :string
    attribute :name, :string
    attribute :started_at, :datetime
    attribute :finished_at, :datetime
    attribute :allocations, :integer
    attribute :external_calls, :integer
    attribute :retry_count, :integer
    attribute :cpu_time_ms, :float
    attribute :memory_bytes, :integer
    attribute :tags, :hash
    attribute :window_started_at, :datetime
    attribute :sql_queries, :array
  end
end
