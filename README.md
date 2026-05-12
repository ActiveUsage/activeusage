# ActiveUsage

Cost observability core for Ruby and Rails workloads. ActiveUsage turns runtime signals — request timing, SQL queries, job execution — into structured events you can ship to any backend for cost analysis.

## Installation

Add to your Gemfile:

```ruby
gem "activeusage"
```

## Configuration

```ruby
ActiveUsage.configure do |config|
  config.adapter     = ActiveUsage::Adapters::Http.new("https://your-backend.example.com/events", "your-api-key")
  config.tags        = { env: Rails.env }
  config.logger      = Rails.logger
end
```

## Rails integration

With Rails, ActiveUsage auto-instruments requests and jobs via a Railtie — no extra setup needed.

**Requests** — every `process_action.action_controller` notification produces a `:request` event with timing, allocations, controller/action tags, and SQL query breakdown.

**Jobs** — every `ActiveJob` execution produces a `:job` event with timing, retry count, queue name, and SQL query breakdown.

**Middleware** — `ActiveUsage::Middleware` is inserted automatically to flush per-request tags.

## Manual tracking

Use `ActiveUsage.track` to instrument arbitrary blocks:

```ruby
result = ActiveUsage.track("reports.generate", tags: { user_id: current_user.id }) do
  ReportGenerator.call(params)
end
```

This produces a `:task` event with timing and SQL queries captured within the block.

## Tags

Tags are thread-local and merged into every event recorded on the current thread:

```ruby
ActiveUsage.tags.tag(user_id: current_user.id, tenant: current_tenant.slug)
```

Tags set on the thread are flushed automatically at the end of each request by the middleware and at the start/end of each job by the hook.

## Event payload

Every event includes:

| Field | Description |
|---|---|
| `type` | `:request`, `:job`, or `:task` |
| `name` | controller action, job class name, or task name |
| `started_at` | start timestamp |
| `finished_at` | end timestamp |
| `allocations` | object allocations (requests only) |
| `retry_count` | retry count (jobs only) |
| `tags` | merged thread-local and per-event tags |
| `window_started_at` | start of the aggregation window bucket |
| `sql_queries` | top SQL query fingerprints with timing and call counts |
