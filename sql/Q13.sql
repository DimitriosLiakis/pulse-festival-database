SELECT
  a.artist_id,
  a.name,
  COUNT(DISTINCT l.continent) AS continent_count
FROM Artist a
JOIN Performance_Artist pa ON a.artist_id = pa.artist_id
JOIN Performance p        ON pa.performance_id = p.performance_id
JOIN Event e              ON p.event_id_FK = e.event_id
JOIN Festival f           ON e.festival_id_FK = f.festival_id
JOIN Location l           ON f.location_id_FK = l.location_id
GROUP BY a.artist_id, a.name
HAVING COUNT(DISTINCT l.continent) >= 3
ORDER BY a.artist_id;