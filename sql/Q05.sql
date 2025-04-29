SELECT
  a.artist_id,
  a.name,
  FLOOR(DATEDIFF(CURDATE(), a.birth_date)/365.25) AS age,
  COUNT(DISTINCT e.festival_id_FK)               AS festival_count
FROM Artist a
JOIN Performance_Artist pa ON a.artist_id = pa.artist_id
JOIN Performance p        ON pa.performance_id = p.performance_id
JOIN Event e              ON p.event_id_FK     = e.event_id
WHERE FLOOR(DATEDIFF(CURDATE(), a.birth_date)/365.25) < 30
GROUP BY
  a.artist_id,
  a.name
ORDER BY festival_count DESC
LIMIT 5;
