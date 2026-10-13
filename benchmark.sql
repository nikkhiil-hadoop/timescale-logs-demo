\timing off
\echo '== Sizes (MB)'
SELECT 'plain' AS t, round(pg_total_relation_size('logs_plain')/1e6,1) AS mb
UNION ALL SELECT 'hypertable_compressed', round(hypertable_size('logs')/1e6,1);
\echo '== Q: hourly error count + p-latency per service, last 24h'
EXPLAIN (ANALYZE, SUMMARY) SELECT date_trunc('hour', time) b, service, count(*) FILTER (WHERE level IN ('ERROR','FATAL')), avg(latency_ms) FROM logs_plain WHERE time > now() - INTERVAL '24 hours' GROUP BY 1,2;
EXPLAIN (ANALYZE, SUMMARY) SELECT time_bucket('1 hour', time) b, service, count(*) FILTER (WHERE level IN ('ERROR','FATAL')), avg(latency_ms) FROM logs WHERE time > now() - INTERVAL '24 hours' GROUP BY 1,2;
EXPLAIN (ANALYZE, SUMMARY) SELECT bucket, service, errors, avg_latency FROM logs_hourly WHERE bucket > now() - INTERVAL '24 hours';
\echo '== Q: full 14-day scan'
EXPLAIN (ANALYZE, SUMMARY) SELECT date_trunc('hour', time) b, service, count(*), avg(latency_ms) FROM logs_plain GROUP BY 1,2;
EXPLAIN (ANALYZE, SUMMARY) SELECT time_bucket('1 hour', time) b, service, count(*), avg(latency_ms) FROM logs GROUP BY 1,2;
EXPLAIN (ANALYZE, SUMMARY) SELECT bucket, service, total, avg_latency FROM logs_hourly;
