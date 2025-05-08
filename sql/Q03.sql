SELECT
  f.festival_id,
  f.festival_name,
  a.artist_id,
  a.name            AS artist_name,
  COUNT(*)          AS warmup_count
FROM Performance p
JOIN Performance_Artist pa
  ON p.performance_id = pa.performance_id
JOIN Event e
  ON p.event_id_FK = e.event_id
JOIN Festival f
  ON e.festival_id_FK = f.festival_id
JOIN Artist a
  ON pa.artist_id = a.artist_id
WHERE p.performance_type = 'warm up'
GROUP BY
  f.festival_id,
  f.festival_name,
  a.artist_id,
  a.name
HAVING
  COUNT(*) > 2;
