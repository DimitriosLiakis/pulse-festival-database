SELECT
    CONCAT(v.first_name, ' ', v.last_name)   AS visitor_name,
    a.real_name                             AS artist_name,   
    SUM(
        r.rating_interpretation
      + r.rating_sound_light
      + r.rating_stage_presence
      + r.rating_organization
      + r.rating_overall
    )                                         AS total_score
FROM   Rating              AS r
JOIN   Visitor             AS v  ON v.visitor_id           = r.visitor_id_FK
JOIN   Performance         AS p  ON p.performance_id       = r.performance_id_FK
JOIN   Performance_Artist  AS pa ON pa.performance_id_FK   = p.performance_id
JOIN   Artist              AS a  ON a.artist_id            = pa.artist_id_FK
GROUP  BY v.visitor_id, a.artist_id, visitor_name, artist_name
ORDER  BY total_score DESC
LIMIT  5;
