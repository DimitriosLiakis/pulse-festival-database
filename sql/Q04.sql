SET @p_artist_id   = 5;    


SELECT  a.artist_id,
        COALESCE(a.pseudonym, a.real_name)               AS artist_name,
        ROUND(AVG(r.rating_interpretation), 2)            AS avg_interpretation,
        ROUND(AVG(r.rating_overall),        2)            AS avg_overall
FROM        Rating              r
JOIN        Performance         p   ON p.performance_id      = r.performance_id_FK
JOIN        Performance_Artist  pa  ON pa.performance_id_FK  = p.performance_id
JOIN        Artist              a   ON a.artist_id           = pa.artist_id_FK
WHERE       a.artist_id = @p_artist_id        
-- WHERE    (a.stage_name = @p_artist_name OR a.real_name = @p_artist_name)
GROUP BY    a.artist_id, artist_name;


EXPLAIN FORMAT=JSON

SELECT  a.artist_id,
        COALESCE(a.pseudonym, a.real_name)               AS artist_name,
        ROUND(AVG(r.rating_interpretation), 2)            AS avg_interpretation,
        ROUND(AVG(r.rating_overall),        2)            AS avg_overall
FROM        Rating              r
JOIN        Performance         p   ON p.performance_id      = r.performance_id_FK
JOIN        Performance_Artist  pa  ON pa.performance_id_FK  = p.performance_id
JOIN        Artist              a   ON a.artist_id           = pa.artist_id_FK
WHERE       a.artist_id = @p_artist_id        
-- WHERE    (a.stage_name = @p_artist_name OR a.real_name = @p_artist_name)
GROUP BY    a.artist_id, artist_name;