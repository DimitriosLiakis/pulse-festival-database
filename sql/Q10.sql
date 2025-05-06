WITH genre_pairs AS (
  SELECT
    artist_id,
    CASE WHEN main_genre < sub_genre THEN main_genre ELSE sub_genre END AS genre1,
    CASE WHEN main_genre < sub_genre THEN sub_genre ELSE main_genre END AS genre2
  FROM Artist
  WHERE sub_genre IS NOT NULL
),
pair_festivals AS (
  SELECT DISTINCT
    gp.genre1,
    gp.genre2,
    f.festival_id
  FROM genre_pairs gp
  JOIN Performance_Artist pa
    ON gp.artist_id = pa.artist_id
  JOIN Performance p
    ON pa.performance_id = p.performance_id
  JOIN Event e
    ON p.event_id_FK = e.event_id
  JOIN Festival f
    ON e.festival_id_FK = f.festival_id
)
SELECT
  genre1,
  genre2,
  COUNT(*) AS festival_appearances
FROM pair_festivals
GROUP BY
  genre1,
  genre2
ORDER BY
  festival_appearances DESC
LIMIT 3;
