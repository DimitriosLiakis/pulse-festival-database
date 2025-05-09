WITH ArtistGenres AS (
  -- For each performance, list the artist’s two genres
  SELECT 
    pa.performance_id_FK AS perf,
    a.music_genre        AS g1,
    a.sub_genre          AS g2
  FROM   Performance_Artist pa
  JOIN   Artist            a ON a.artist_id = pa.artist_id_FK
),
GenrePairs AS (
  -- Build unique ordered pairs (g1<g2) per performance, only when both exist
  SELECT DISTINCT
    perf,
    LEAST(g1, g2) AS genre1,
    GREATEST(g1, g2) AS genre2
  FROM   ArtistGenres
  WHERE  g2 IS NOT NULL
    AND  g1 <> g2
)
SELECT
  genre1,
  genre2,
  COUNT(DISTINCT perf) AS appearances
FROM   GenrePairs
GROUP  BY genre1, genre2
ORDER  BY appearances DESC
LIMIT  3;
