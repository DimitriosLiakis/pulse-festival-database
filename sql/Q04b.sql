EXPLAIN ANALYZE
SELECT
  AVG(r.rating_interpretation),
  AVG(r.rating_overall)
FROM   Performance_Artist pa FORCE INDEX (idx_artist_id)
JOIN   Rating               r  FORCE INDEX (idx_rating_perf_fk)
  ON r.performance_id_FK = pa.performance_id
WHERE  pa.artist_id = 5;
-- FORCE INDEX