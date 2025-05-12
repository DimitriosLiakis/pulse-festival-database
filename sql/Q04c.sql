/* 4.3 Forced Nested Loop Join (updated for revised schema) */
SELECT
    a.artist_id,
    COALESCE(a.pseudonym, a.real_name)   AS artist_name,
    AVG(r.rating_interpretation)          AS avg_interpretation,
    AVG(r.rating_overall)                 AS avg_overall
FROM Rating             AS r
    FORCE INDEX (`performance_id_FK`)    
JOIN Performance_Artist AS pa
    FORCE INDEX (PRIMARY)                
    /*+ LOOP_JOIN(r pa) */               
    ON r.performance_id_FK = pa.performance_id_FK
JOIN Artist             AS a
    FORCE INDEX (PRIMARY)                
    ON pa.artist_id_FK = a.artist_id
WHERE a.artist_id = 5
GROUP BY a.artist_id, artist_name;

EXPLAIN FORMAT=JSON
SELECT
    a.artist_id,
    COALESCE(a.pseudonym, a.real_name)   AS artist_name,
    AVG(r.rating_interpretation)          AS avg_interpretation,
    AVG(r.rating_overall)                 AS avg_overall
FROM Rating             AS r
    FORCE INDEX (`performance_id_FK`)
JOIN Performance_Artist AS pa
    FORCE INDEX (PRIMARY)
    /*+ LOOP_JOIN(r pa) */
    ON r.performance_id_FK = pa.performance_id_FK
JOIN Artist             AS a
    FORCE INDEX (PRIMARY)
    ON pa.artist_id_FK = a.artist_id
WHERE a.artist_id = 5
GROUP BY a.artist_id, artist_name;
