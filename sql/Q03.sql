SELECT  a.artist_id,
        COALESCE(a.pseudonym, a.real_name) AS artist_name,
        f.festival_id,
        f.festival_name,
        f.festival_year,
        COUNT(DISTINCT p.performance_id) AS warmup_cnt              
FROM        Artist              AS a
JOIN        Performance_Artist  AS pa ON pa.artist_id_FK   = a.artist_id
JOIN        Performance         AS p  ON p.performance_id  = pa.performance_id_FK
JOIN        Event               AS e  ON e.event_id        = p.event_id_FK
JOIN        Festival            AS f  ON f.festival_id     = e.festival_id_FK
WHERE       p.performance_type = 'warm up'
GROUP BY    a.artist_id, f.festival_id                           
HAVING      warmup_cnt >= 3                                      
ORDER BY    warmup_cnt DESC, artist_name;
