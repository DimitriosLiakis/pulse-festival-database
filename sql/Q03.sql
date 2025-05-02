SELECT
  a.artist_id,
  a.name,
  f.festival_year,
  COUNT(*) AS warmup_count
FROM    Performance            p
JOIN    Performance_type       pt  ON pt.performance_type_id = p.performance_type_id
                                   AND pt.description = 'warm up'
JOIN    Performance_Artist     pa  ON pa.performance_id     = p.performance_id
JOIN    Artist                 a   ON a.artist_id           = pa.artist_id
JOIN    Event                  e   ON e.event_id            = p.event_id_FK
JOIN    Festival               f   ON f.festival_id         = e.festival_id_FK
GROUP BY
  a.artist_id,
  a.name,
  f.festival_id,
  f.festival_year
HAVING
  COUNT(*) > 2
ORDER BY
  warmup_count DESC;

--    list warm-up counts per artist per festival
-- SELECT
--   a.artist_id,
--   a.name,
--   f.festival_year,
--   COUNT(*) AS warmup_count
-- FROM    Performance            p
-- JOIN    Performance_type       pt ON pt.performance_type_id = p.performance_type_id
--                                   AND pt.description = 'warm up'
-- JOIN    Performance_Artist     pa ON pa.performance_id     = p.performance_id
-- JOIN    Artist                 a  ON a.artist_id           = pa.artist_id
-- JOIN    Event                  e  ON e.event_id            = p.event_id_FK
-- JOIN    Festival               f  ON f.festival_id         = e.festival_id_FK
-- GROUP BY
--   a.artist_id,
--   a.name,
--   f.festival_year
-- ORDER BY
--   warmup_count DESC
-- LIMIT 10;

