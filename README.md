# Log Pulse: log analytics on TimescaleDB

A small demo that loads 2M synthetic service logs (14 days, 5 services, one injected checkout latency incident) into a TimescaleDB hypertable and compares it with plain Postgres.

It uses a hypertable with 1-day chunks, a continuous aggregate (`logs_hourly`), compression (segmented by service), and compression and retention policies.

## Run it

```bash
docker run -d --name tsdb -e POSTGRES_PASSWORD=demo -p 5433:5432 timescale/timescaledb:latest-pg16
for f in schema load rollup; do docker exec -i tsdb psql -U postgres -v ON_ERROR_STOP=1 -q < $f.sql; done
docker exec -i tsdb psql -U postgres -q < benchmark.sql
```

`index.html` is the dashboard. It has the 3-hour rollup data embedded and opens directly in a browser.

## Results (laptop, Docker, single run)

| Query | Plain Postgres | Hypertable | Continuous aggregate |
|---|---|---|---|
| Hourly errors and latency, last 24h | 69.9 ms | 117.1 ms | 0.44 ms |
| Hourly rollup, full 14 days | 533.6 ms | 424.4 ms | 0.72 ms |
| Table size | 332 MB | 92 MB (compressed) | n/a |

On raw scans at this size the hypertable is not automatically faster, and the 24h query was slower. The wins here are compression (3.6x) and continuous aggregates.
