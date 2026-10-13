-- 2M synthetic logs over the last 14 days, with an incident injected on checkout
CREATE TEMP TABLE gen AS
SELECT
  now() - (random() * INTERVAL '14 days') AS time,
  (ARRAY['api','auth','checkout','search','billing'])[1 + floor(random()*5)::int] AS service,
  random() AS r, random() AS r2
FROM generate_series(1, 2000000);

INSERT INTO logs
SELECT time, service,
  CASE WHEN r < 0.80 THEN 'INFO' WHEN r < 0.92 THEN 'WARN' WHEN r < 0.99 THEN 'ERROR' ELSE 'FATAL' END,
  CASE WHEN r < 0.92 THEN 200 WHEN r < 0.96 THEN 404 ELSE 500 END,
  round((20 + r2 * 180 + CASE WHEN service='checkout' AND time > now() - INTERVAL '6 hours' THEN 800*random() ELSE 0 END)::numeric, 2),
  'request handled by ' || service
FROM gen;
INSERT INTO logs_plain SELECT * FROM logs;
ANALYZE logs; ANALYZE logs_plain;
