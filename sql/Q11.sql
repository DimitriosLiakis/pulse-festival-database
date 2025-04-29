WITH ac AS (
  SELECT
    pa.artist_id,
    COUNT(DISTINCT e.festival_id_FK) AS fest_count
  FROM Performance_Artist pa
  JOIN Event e ON pa.performance_id = pa.performance_id
  GROUP BY pa.artist_id
),
mc AS (
  SELECT MAX(fest_count) AS top_count FROM ac
)
SELECT
  a.artist_id,
  a.name,
  ac.fest_count
FROM ac
JOIN mc
JOIN Artist a ON ac.artist_id = a.artist_id
WHERE ac.fest_count <= mc.top_count - 5
ORDER BY ac.fest_count DESC;
