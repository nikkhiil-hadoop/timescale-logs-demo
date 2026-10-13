CREATE EXTENSION IF NOT EXISTS timescaledb;

DROP MATERIALIZED VIEW IF EXISTS logs_hourly;
DROP TABLE IF EXISTS logs, logs_plain;

CREATE TABLE logs (
  time       timestamptz NOT NULL,
  service    text        NOT NULL,
  level      text        NOT NULL,
  status     int         NOT NULL,
  latency_ms double precision NOT NULL,
  message    text
);
SELECT create_hypertable('logs', 'time', chunk_time_interval => INTERVAL '1 day');
CREATE INDEX ON logs (service, time DESC);

-- identical plain Postgres table for comparison
CREATE TABLE logs_plain (LIKE logs);
CREATE INDEX ON logs_plain (service, time DESC);
CREATE INDEX ON logs_plain (time DESC);
