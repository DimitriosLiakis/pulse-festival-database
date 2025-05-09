-- 13. Καλλιτέχνες που έχουν συμμετάσχει σε φεστιβάλ σε ≥ 3 διαφορετικές ηπείρους

SELECT
    a.artist_id,
    COALESCE(a.real_name, a.real_name)   AS artist_name,
    COUNT(DISTINCT l.continent)            AS continent_count
FROM   Artist              AS a
JOIN   Performance_Artist  AS pa  ON pa.artist_id_FK    = a.artist_id
JOIN   Performance         AS p   ON p.performance_id   = pa.performance_id_FK
JOIN   Event               AS e   ON e.event_id         = p.event_id_FK
JOIN   Festival            AS f   ON f.festival_id      = e.festival_id_FK
JOIN   Location            AS l   ON l.location_id      = f.location_id_FK
GROUP  BY a.artist_id, artist_name
HAVING COUNT(DISTINCT l.continent) >= 3
ORDER  BY artist_name;
