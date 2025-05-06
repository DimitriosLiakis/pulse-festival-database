SELECT
  a.artist_id,
  a.name                     AS artist_name,
  COUNT(DISTINCT l.continent) AS continent_count
FROM Artist               AS a
JOIN Performance_Artist   AS pa ON a.artist_id = pa.artist_id
JOIN Performance          AS p  ON pa.performance_id = p.performance_id
JOIN Event                AS e  ON p.event_id_FK    = e.event_id
JOIN Festival             AS f  ON e.festival_id_FK = f.festival_id
JOIN Location             AS l  ON f.location_id_FK = l.location_id
GROUP BY
  a.artist_id,
  a.name
HAVING
  COUNT(DISTINCT l.continent) >= 3
ORDER BY
  continent_count DESC,
  a.name;
