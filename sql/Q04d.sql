-- ############################################
-- 4. Testing Different Join Strategies
-- ############################################

-- 4.1 Nested-Loop only (default; ensure hash_join=off)
SET SESSION optimizer_switch = 'hash_join=off';

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


-- 4.2 Enable Hash Join
SET SESSION optimizer_switch = 'hash_join=on';

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


-- 4.3 Enable Index-Merge Intersection
SET SESSION optimizer_switch = 'index_merge_intersection=on';

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


-- 4.4 Reset optimizer_switch to defaults
SET SESSION optimizer_switch = DEFAULT;