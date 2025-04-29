WITH gy AS (
  SELECT
    a.music_genres AS genre,
    f.festival_year AS year,
    COUNT(*)         AS perf_count
  FROM Artist a
  JOIN Performance_Artist pa ON a.artist_id = pa.artist_id
  JOIN Performance p        ON pa.performance_id = p.performance_id
  JOIN Event e              ON p.event_id_FK = e.event_id
  JOIN Festival f           ON e.festival_id_FK = f.festival_id
  GROUP BY a.music_genres, f.festival_year
),
ce AS (
  SELECT
    g1.genre, g1.year AS y1, g2.year AS y2, g1.perf_count
  FROM gy g1
  JOIN gy g2
    ON g1.genre = g2.genre
   AND g2.year = g1.year + 1
   AND g1.perf_count = g2.perf_count
  WHERE g1.perf_count >= 3
)
SELECT DISTINCT genre, perf_count AS count_per_year, y1 AS year1, y2 AS year2
FROM ce
ORDER BY genre;
