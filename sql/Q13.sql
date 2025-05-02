SELECT
  a.artist_id,
  a.name
FROM   Artist              a
JOIN   Performance_Artist pa ON pa.artist_id      = a.artist_id
JOIN   Performance        p  ON p.performance_id  = pa.performance_id
JOIN   Event              e  ON e.event_id        = p.event_id_FK
JOIN   Festival           f  ON f.festival_id     = e.festival_id_FK
JOIN   Location           l  ON l.location_id     = f.location_id_FK
GROUP BY
  a.artist_id, a.name
HAVING
  COUNT(DISTINCT l.continent) >= 3;
