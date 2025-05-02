SELECT
  G.g1,
  G.g2,
  COUNT(DISTINCT f.festival_id) AS festival_count
FROM (
  -- build normalized genre‐pairs per artist
  SELECT
    artist_id,
    CASE
      WHEN main_genre < sub_genre THEN main_genre
      ELSE sub_genre
    END AS g1,
    CASE
      WHEN main_genre < sub_genre THEN sub_genre
      ELSE main_genre
    END AS g2
  FROM Artist
  WHERE sub_genre IS NOT NULL
    AND sub_genre <> ''
) AS G
JOIN Performance_Artist pa  ON pa.artist_id       = G.artist_id
JOIN Performance        p   ON p.performance_id   = pa.performance_id
JOIN Event              e   ON e.event_id         = p.event_id_FK
JOIN Festival           f   ON f.festival_id      = e.festival_id_FK
GROUP BY
  G.g1, G.g2
ORDER BY
  festival_count DESC
LIMIT 3;
