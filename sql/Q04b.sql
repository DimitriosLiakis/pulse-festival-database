SET optimizer_trace = 'enabled=on', end_markers_in_json = off;
SET @p_artist_id = 5;

SELECT
    a.artist_id,
    COALESCE(a.pseudonym, a.real_name)        AS artist_name,
    ROUND(AVG(r.rating_interpretation), 2)     AS avg_interpretation,
    ROUND(AVG(r.rating_overall), 2)            AS avg_overall
FROM   Rating             AS r
JOIN   Performance        AS p   ON p.performance_id     = r.performance_id_FK
JOIN   Performance_Artist AS pa  ON pa.performance_id_FK = p.performance_id
JOIN   Artist             AS a   ON a.artist_id          = pa.artist_id_FK
WHERE  a.artist_id = @p_artist_id
GROUP  BY a.artist_id, artist_name;

SELECT JSON_PRETTY(trace) AS optimizer_trace
FROM   INFORMATION_SCHEMA.OPTIMIZER_TRACE
LIMIT  1\G

SET optimizer_trace = 'enabled=off';
