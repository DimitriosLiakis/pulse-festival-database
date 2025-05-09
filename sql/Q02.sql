/* Δώστε τιμές στις δύο μεταβλητές πριν τρέξετε το SELECT */
SET @p_genre = 'rock';   -- μουσικό είδος που σας ενδιαφέρει
SET @p_year  = 2024;     -- έτος του φεστιβάλ

SELECT  a.artist_id,
        COALESCE(a.pseudonym, a.real_name) AS artist_name,
        a.music_genre,
        /* ‘Y’ αν ο καλλιτέχνης έπαιξε σε εκδήλωση τη συγκεκριμένη χρονιά */
        CASE WHEN x.artist_id_FK IS NOT NULL THEN 'Y' ELSE 'N' END AS participated
FROM    Artist AS a
LEFT JOIN (   /* σύνολο καλλιτεχνών που εμφανίστηκαν το @p_year */
        SELECT DISTINCT pa.artist_id_FK
        FROM   Performance_Artist pa
        JOIN   Performance       p ON p.performance_id = pa.performance_id_FK
        JOIN   Event             e ON e.event_id        = p.event_id_FK
        JOIN   Festival          f ON f.festival_id     = e.festival_id_FK
        WHERE  f.festival_year = @p_year
) AS x  ON x.artist_id_FK = a.artist_id
WHERE   a.music_genre = @p_genre           -- μόνο οι καλλιτέχνες του είδους
ORDER BY artist_name;
