-- 1) (Optional) enlarge the trace buffer so it won’t truncate
SET optimizer_trace_max_mem_size = 1000000;

-- 2) enable tracing with strict JSON
SET optimizer_trace = 'enabled=on', end_markers_in_json = off;

-- 3) set the artist ID you want to inspect
SET @p_artist_id = 5;

-- 4) run your aggregation query
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

-- 5) fetch the one-and-only trace
SELECT JSON_PRETTY(trace) AS optimizer_trace
FROM   INFORMATION_SCHEMA.OPTIMIZER_TRACE
LIMIT  1\G

-- 6) turn tracing off
SET optimizer_trace = 'enabled=off';
