WITH af AS (
  SELECT DISTINCT
    a.artist_id,
    a.music_genres AS genre,
    e.festival_id_FK AS festival_id
  FROM Artist a
  JOIN Performance_Artist pa ON a.artist_id = pa.artist_id
  JOIN Performance p        ON pa.performance_id = p.performance_id
  JOIN Event e              ON p.event_id_FK = e.event_id
),
pairs AS (
  SELECT
    LEAST(g1.genre,g2.genre)   AS genre_a,
    GREATEST(g1.genre,g2.genre) AS genre_b,
    g1.festival_id
  FROM af g1
  JOIN af g2
    ON g1.festival_id = g2.festival_id
   AND g1.genre < g2.genre
),
cnts AS (
  SELECT
    genre_a, genre_b,
    COUNT(DISTINCT festival_id) AS festival_count
  FROM pairs
  GROUP BY genre_a, genre_b
)
SELECT genre_a, genre_b, festival_count
FROM cnts
ORDER BY festival_count DESC
LIMIT 3;
