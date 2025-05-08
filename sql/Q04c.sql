-- ############################################
-- 3. Optimizer Trace (MySQL 8+)
-- ############################################

-- 3.1 Enable the optimizer trace
SET optimizer_trace = 'enabled=on',
    optimizer_trace_max_mem_size = 10485760;

-- 3.2 Re-run EXPLAIN to capture the trace
EXPLAIN FORMAT=JSON
SELECT
  a.artist_id,
  a.name                     AS artist_name,
  AVG(r.rating_interpretation) AS avg_interpretation,
  AVG(r.rating_overall)        AS avg_overall
FROM Rating            AS r
JOIN Performance_Artist AS pa
  ON r.performance_id_FK = pa.performance_id
JOIN Artist            AS a
  ON pa.artist_id       = a.artist_id
WHERE a.artist_id = 5   
GROUP BY
  a.artist_id,
  a.name;

-- 3.3 Retrieve the trace output
SELECT * 
  FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE\G

-- 3.4 Disable the optimizer trace
SET optimizer_trace = 'enabled=off';

