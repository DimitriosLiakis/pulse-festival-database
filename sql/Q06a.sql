-- ############################################
-- 1. Base Query + EXPLAIN (JSON)
-- ############################################

-- Show the JSON plan for “performances attended by visitor #10 with avg rating”
EXPLAIN FORMAT=JSON
SELECT
  p.performance_id,
  p.performance_type,
  AVG(r.rating_interpretation) AS avg_interpretation,
  AVG(r.rating_overall)       AS avg_overall
FROM Rating      AS r
JOIN Performance AS p
  ON r.performance_id_FK = p.performance_id
JOIN Visitor     AS v
  ON r.visitor_id_FK     = v.visitor_id
WHERE v.visitor_id = 10
GROUP BY
  p.performance_id,
  p.performance_type;

-- (Optionally run to see results)
SELECT
  p.performance_id,
  p.performance_type,
  AVG(r.rating_interpretation) AS avg_interpretation,
  AVG(r.rating_overall)       AS avg_overall
FROM Rating      AS r
JOIN Performance AS p
  ON r.performance_id_FK = p.performance_id
JOIN Visitor     AS v
  ON r.visitor_id_FK     = v.visitor_id
WHERE v.visitor_id = 10
GROUP BY
  p.performance_id,
  p.performance_type;


-- ############################################
-- 2. FORCE INDEX Version + EXPLAIN
-- ############################################

-- Force use of FK indexes if needed
EXPLAIN FORMAT=JSON
SELECT
  p.performance_id,
  p.performance_type,
  AVG(r.rating_interpretation) AS avg_interpretation,
  AVG(r.rating_overall)       AS avg_overall
FROM Rating      AS r
  FORCE INDEX (performance_id_fk)
JOIN Performance AS p
  FORCE INDEX (PRIMARY)
  ON r.performance_id_FK = p.performance_id
JOIN Visitor     AS v
  FORCE INDEX (PRIMARY)
  ON r.visitor_id_FK     = v.visitor_id
WHERE v.visitor_id = 10
GROUP BY
  p.performance_id,
  p.performance_type;


-- ############################################
-- 3. Optimizer Trace (MySQL 8+)
-- ############################################

-- 3.1 Enable the optimizer trace
SET optimizer_trace = 'enabled=on',
    optimizer_trace_max_mem_size = 10485760;

-- 3.2 Capture the JSON plan
EXPLAIN FORMAT=JSON
SELECT
  p.performance_id,
  p.performance_type,
  AVG(r.rating_interpretation) AS avg_interpretation,
  AVG(r.rating_overall)       AS avg_overall
FROM Rating      AS r
JOIN Performance AS p
  ON r.performance_id_FK = p.performance_id
JOIN Visitor     AS v
  ON r.visitor_id_FK     = v.visitor_id
WHERE v.visitor_id = 10
GROUP BY
  p.performance_id,
  p.performance_type;

-- 3.3 Retrieve the trace output
SELECT *
  FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE\G

-- 3.4 Disable the optimizer trace
SET optimizer_trace = 'enabled=off';


-- ############################################
-- 4. Testing Different Join Strategies
-- ############################################

-- 4.1 Nested-Loop Join only (default; disable hash join)
SET SESSION optimizer_switch = 'hash_join=off';

EXPLAIN FORMAT=JSON
SELECT
  p.performance_id,
  p.performance_type,
  AVG(r.rating_interpretation) AS avg_interpretation,
  AVG(r.rating_overall)       AS avg_overall
FROM Rating      AS r
JOIN Performance AS p
  ON r.performance_id_FK = p.performance_id
JOIN Visitor     AS v
  ON r.visitor_id_FK     = v.visitor_id
WHERE v.visitor_id = 10
GROUP BY
  p.performance_id,
  p.performance_type;

-- 4.2 Enable Hash Join
SET SESSION optimizer_switch = 'hash_join=on';

EXPLAIN FORMAT=JSON
SELECT
  p.performance_id,
  p.performance_type,
  AVG(r.rating_interpretation) AS avg_interpretation,
  AVG(r.rating_overall)       AS avg_overall
FROM Rating      AS r
JOIN Performance AS p
  ON r.performance_id_FK = p.performance_id
JOIN Visitor     AS v
  ON r.visitor_id_FK     = v.visitor_id
WHERE v.visitor_id = 10
GROUP BY
  p.performance_id,
  p.performance_type;

-- 4.3 Enable Index-Merge Intersection
SET SESSION optimizer_switch = 'index_merge_intersection=on';

EXPLAIN FORMAT=JSON
SELECT
  p.performance_id,
  p.performance_type,
  AVG(r.rating_interpretation) AS avg_interpretation,
  AVG(r.rating_overall)       AS avg_overall
FROM Rating      AS r
JOIN Performance AS p
  ON r.performance_id_FK = p.performance_id
JOIN Visitor     AS v
  ON r.visitor_id_FK     = v.visitor_id
WHERE v.visitor_id = 10
GROUP BY
  p.performance_id,
  p.performance_type;

-- 4.4 Reset optimizer_switch to defaults
SET SESSION optimizer_switch = DEFAULT;
