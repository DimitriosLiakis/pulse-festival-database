SELECT
  v.visitor_id,
  v.first_name,
  v.last_name,
  a.artist_id,
  a.name            AS artist_name,
  SUM(r.rating_overall) AS total_score
FROM   Rating             r
JOIN   Performance_Artist pa ON pa.performance_id = r.performance_id_FK
JOIN   Artist            a  ON a.artist_id       = pa.artist_id
JOIN   Visitor           v  ON v.visitor_id      = r.visitor_id_FK
GROUP BY
  v.visitor_id, v.first_name, v.last_name,
  a.artist_id, a.name
ORDER BY
  total_score DESC
LIMIT 5;
