WITH artist_counts AS (
  SELECT
    a.artist_id,
    a.name                          AS artist_name,
    COUNT(DISTINCT f.festival_id)   AS festival_count
  FROM Artist           AS a
  JOIN Performance_Artist AS pa   ON a.artist_id = pa.artist_id
  JOIN Performance       AS p     ON pa.performance_id = p.performance_id
  JOIN Event             AS e     ON p.event_id_FK = e.event_id
  JOIN Festival          AS f     ON e.festival_id_FK = f.festival_id
  GROUP BY
    a.artist_id,
    a.name
),
max_count AS (
  SELECT
    MAX(festival_count) AS top_count
  FROM artist_counts
)
SELECT
  ac.artist_id,
  ac.artist_name,
  ac.festival_count
FROM artist_counts AS ac
CROSS JOIN max_count    AS mc
WHERE
  ac.festival_count <= mc.top_count - 5
ORDER BY
  ac.festival_count DESC,
  ac.artist_name;
