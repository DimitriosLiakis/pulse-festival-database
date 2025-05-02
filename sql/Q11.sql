WITH artist_counts AS (
  SELECT
    pa.artist_id,
    COUNT(DISTINCT e.festival_id_FK) AS cnt
  FROM   Performance_Artist pa
  JOIN   Performance        p ON p.performance_id = pa.performance_id
  JOIN   Event              e ON e.event_id       = p.event_id_FK
  GROUP BY pa.artist_id
),
max_count AS (
  SELECT MAX(cnt) AS maxcnt FROM artist_counts
)
SELECT
  ac.artist_id,
  a.name,
  ac.cnt
FROM   artist_counts ac
CROSS JOIN max_count mc
JOIN   Artist a ON a.artist_id = ac.artist_id
WHERE  ac.cnt <= mc.maxcnt - 5
ORDER BY ac.cnt DESC;
