## [Unreleased]

## [0.1.0] - 2026-04-21

### Added

- Rails auto-instrumentation for requests (`process_action.action_controller`) and jobs (`ActiveJob`)
- Manual task tracking via `ActiveUsage.track`
- Thread-local tag management with per-request and per-job flush
- SQL query fingerprinting with normalization, aggregation by pattern, and top-N ranking (up to 20 per event)
- HTTP adapter with Bearer token auth and JSON batch delivery
- Custom adapter interface (`ActiveUsage::Adapters::Base`)
- Background worker with configurable flush interval and graceful shutdown
- Thread-safe event queue with batch flushing and dropped-event tracking
- Configurable logger, window size, global tags, and adapter via `ActiveUsage.configure`
- Railtie for zero-config Rails integration (middleware + ActiveJob hook)
