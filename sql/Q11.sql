WITH artist_counts AS (
  -- Count distinct festivals per artist
  SELECT
    pa.artist_id,
    COUNT(DISTINCT e.festival_id_FK) AS fest_count
  FROM Performance_Artist pa
  JOIN Performance p
    ON pa.performance_id = p.performance_id
  JOIN Event e
    ON p.event_id_FK = e.event_id
  GROUP BY pa.artist_id
),
max_and_min AS (
  -- Compute the maximum and minimum festival counts
  SELECT
    MAX(fest_count) AS max_count,
    MIN(fest_count) AS min_count
  FROM artist_counts
)
SELECT
  ac.artist_id,
  a.name,
  ac.fest_count
FROM artist_counts ac
CROSS JOIN max_and_min mm
JOIN Artist a
  ON ac.artist_id = a.artist_id
WHERE ac.fest_count <= mm.max_count - 5
ORDER BY ac.fest_count DESC;