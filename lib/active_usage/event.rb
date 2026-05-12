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
    attribute :retry_count, :integer
    attribute :tags, :tags
    attribute :window_started_at, :datetime
    attribute :sql_queries, :sql_queries
  end
end
