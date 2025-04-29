SELECT
  a.artist_id,
  a.name,
  CASE
    WHEN EXISTS (
      SELECT 1
      FROM Performance_Artist pa
      JOIN Performance p ON pa.performance_id = p.performance_id
      JOIN Event e ON p.event_id_FK = e.event_id
      JOIN Festival f ON e.festival_id_FK = f.festival_id
      WHERE pa.artist_id = a.artist_id
        AND LOWER(a.music_genres) = 'pop'
        AND f.festival_year = 2024
    ) THEN 'Yes' ELSE 'No'
  END AS participated
FROM Artist a
WHERE LOWER(a.music_genres) = 'pop'
ORDER BY a.name;
