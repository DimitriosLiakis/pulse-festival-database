SELECT
  a.artist_id,
  a.name,
  COUNT(DISTINCT e.festival_id_FK) AS fest_count
FROM   Artist             a
JOIN   Performance_Artist pa ON pa.artist_id    = a.artist_id
JOIN   Performance        p  ON p.performance_id = pa.performance_id
JOIN   Event              e  ON e.event_id       = p.event_id_FK
WHERE  TIMESTAMPDIFF(
           YEAR,
           a.birth_date,
           DATE '2025-05-02'
       ) < 30
GROUP BY
  a.artist_id, a.name
ORDER BY
  fest_count DESC
LIMIT 1;
