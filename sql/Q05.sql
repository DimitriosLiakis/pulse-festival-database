SELECT
    a.artist_id,
    a.real_name                           AS artist_name,
    TIMESTAMPDIFF(YEAR, a.birth_date, CURDATE()) AS age,
    COUNT(DISTINCT f.festival_id)         AS festival_count
FROM   Artist              AS a
JOIN   Performance_Artist  AS pa  ON pa.artist_id_FK      = a.artist_id
JOIN   Performance         AS p   ON p.performance_id     = pa.performance_id_FK
JOIN   Event               AS e   ON e.event_id           = p.event_id_FK
JOIN   Festival            AS f   ON f.festival_id        = e.festival_id_FK
WHERE  TIMESTAMPDIFF(YEAR, a.birth_date, CURDATE()) < 30
GROUP  BY a.artist_id, artist_name, age
ORDER  BY festival_count DESC, artist_name;
