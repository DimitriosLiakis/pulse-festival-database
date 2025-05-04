SELECT
  a.artist_id,
  a.name,
  CASE
    WHEN EXISTS (
      SELECT 1
      FROM   Performance_Artist pa
      JOIN   Performance        p  ON p.performance_id = pa.performance_id
      JOIN   Event              e  ON e.event_id       = p.event_id_FK
      JOIN   Festival           f  ON f.festival_id    = e.festival_id_FK
      WHERE  pa.artist_id   = a.artist_id
        AND  f.festival_year = 2024
    )
    THEN 'Y'
    ELSE 'N'
  END   AS appeared_in_year
FROM   Artist a
WHERE  (a.main_genre = 'rock'
        OR a.sub_genre  = 'rock')
ORDER BY a.name;
