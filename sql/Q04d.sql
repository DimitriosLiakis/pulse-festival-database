SET SESSION optimizer_switch='batched_key_access=off,block_nested_loop=off';
EXPLAIN ANALYZE
SELECT
  AVG(r.rating_interpretation),
  AVG(r.rating_overall)
FROM   Performance_Artist pa
JOIN   Rating               r  ON r.performance_id_FK = pa.performance_id
WHERE  pa.artist_id = 5;