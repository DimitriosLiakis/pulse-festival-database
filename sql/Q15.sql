WITH visitor_artist_scores AS (
  SELECT
    r.visitor_id_FK     AS visitor_id,
    pa.artist_id        AS artist_id,
    SUM(r.rating_overall) AS total_score
  FROM Rating            AS r
  JOIN Performance_Artist AS pa
    ON r.performance_id_FK = pa.performance_id
  GROUP BY
    r.visitor_id_FK,
    pa.artist_id
)
SELECT
  v.visitor_id,
  CONCAT(v.first_name, ' ', v.last_name) AS visitor_name,
  a.artist_id,
  a.name                 AS artist_name,
  vas.total_score
FROM visitor_artist_scores AS vas
JOIN Visitor AS v
  ON vas.visitor_id = v.visitor_id
JOIN Artist  AS a
  ON vas.artist_id  = a.artist_id
ORDER BY
  vas.total_score DESC
LIMIT 5;
