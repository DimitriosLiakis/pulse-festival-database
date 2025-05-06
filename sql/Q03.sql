SELECT
  f.festival_id,
  f.festival_name,
  f.festival_year,
  a.artist_id,
  a.name AS artist_name,
  COUNT(*) AS warmup_count
FROM Performance       p
JOIN Performance_Artist pa ON p.performance_id = pa.performance_id
JOIN Artist           a  ON pa.artist_id      = a.artist_id
JOIN Event            e  ON p.event_id_FK      = e.event_id
JOIN Festival         f  ON e.festival_id_FK   = f.festival_id
WHERE
  p.performance_type = 'warm up'
GROUP BY
  f.festival_id,
  a.artist_id
HAVING
  COUNT(*) > 2
ORDER BY
  f.festival_year,
  f.festival_name,
  warmup_count DESC;
