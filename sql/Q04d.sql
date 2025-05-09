/* Example: Forced Hash Join with pseudonym */

SET optimizer_switch = 'hash_join=on';

SELECT
    a.artist_id,
    COALESCE(a.pseudonym, a.real_name)   AS artist_name,  -- ← use pseudonym
    AVG(r.rating_interpretation)          AS avg_interpretation,
    AVG(r.rating_overall)                 AS avg_overall
FROM   Rating             AS r
    FORCE INDEX (`performance_id_FK`)
JOIN   Performance_Artist AS pa
    FORCE INDEX (PRIMARY)
    /*+ HASH_JOIN(r pa) */
    ON r.performance_id_FK = pa.performance_id_FK
JOIN   Artist             AS a
    FORCE INDEX (PRIMARY)
    ON pa.artist_id_FK = a.artist_id
WHERE  a.artist_id = 5
GROUP  BY a.artist_id, artist_name;

EXPLAIN FORMAT=JSON
SELECT
    a.artist_id,
    COALESCE(a.pseudonym, a.real_name)   AS artist_name,  -- ← corrected here too
    AVG(r.rating_interpretation)          AS avg_interpretation,
    AVG(r.rating_overall)                 AS avg_overall
FROM   Rating             AS r
    FORCE INDEX (`performance_id_FK`)
JOIN   Performance_Artist AS pa
    FORCE INDEX (PRIMARY)
    /*+ HASH_JOIN(r pa) */
    ON r.performance_id_FK = pa.performance_id_FK
JOIN   Artist             AS a
    FORCE INDEX (PRIMARY)
    ON pa.artist_id_FK = a.artist_id
WHERE  a.artist_id = 5
GROUP  BY a.artist_id, artist_name;
