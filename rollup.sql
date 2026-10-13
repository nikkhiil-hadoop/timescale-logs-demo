CREATE MATERIALIZED VIEW logs_hourly
WITH (timescaledb.continuous) AS
SELECT time_bucket('1 hour', time) AS bucket, service,
       count(*) AS total,
       count(*) FILTER (WHERE level IN ('ERROR','FATAL')) AS errors,
       avg(latency_ms) AS avg_latency,
       max(latency_ms) AS max_latency
FROM logs GROUP BY bucket, service WITH NO DATA;

SELECT add_continuous_aggregate_policy('logs_hourly',
  start_offset => INTERVAL '15 days', end_offset => INTERVAL '1 hour', schedule_interval => INTERVAL '1 hour');
CALL refresh_continuous_aggregate('logs_hourly', NULL, NULL);

ALTER TABLE logs SET (timescaledb.compress, timescaledb.compress_segmentby = 'service', timescaledb.compress_orderby = 'time DESC');
SELECT add_compression_policy('logs', INTERVAL '2 days');
SELECT add_retention_policy('logs', INTERVAL '30 days');
SELECT compress_chunk(c, if_not_compressed => true) FROM show_chunks('logs', older_than => INTERVAL '2 days') c;
