SELECT
  CONCAT(v.first_name,' ',v.last_name) AS visitor_name,
  a.name                                AS artist_name,
  SUM(
    r.rating_interpretation
  + r.rating_sound_light
  + r.rating_stage_presence
  + r.rating_organization
  + r.rating_overall
  )                                     AS total_score
FROM Rating r
JOIN Performance p       ON r.performance_id_FK = p.performance_id
JOIN Performance_Artist pa ON p.performance_id    = pa.performance_id
JOIN Artist a            ON pa.artist_id         = a.artist_id
JOIN Visitor v           ON r.visitor_id_FK      = v.visitor_id
GROUP BY v.visitor_id, a.artist_id
ORDER BY total_score DESC
LIMIT 5;
