SELECT
  pa.artist_id,
  a.name,
  e.festival_id_FK AS festival_id,
  COUNT(*) AS warmup_count
FROM Performance_Artist pa
JOIN Performance p ON pa.performance_id = p.performance_id
JOIN Event e       ON p.event_id_FK = e.event_id
JOIN Artist a      ON pa.artist_id = a.artist_id
WHERE p.performance_type = 'warm up'
GROUP BY pa.artist_id, e.festival_id_FK
HAVING COUNT(*) > 2;
