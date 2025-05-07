WITH genre_year_counts AS (
  SELECT
    a.main_genre     AS genre,
    f.festival_year  AS year,
    COUNT(DISTINCT p.performance_id) AS appearances
  FROM Performance        AS p
  JOIN Performance_Artist AS pa ON p.performance_id = pa.performance_id
  JOIN Artist             AS a  ON pa.artist_id       = a.artist_id
  JOIN Event              AS e  ON p.event_id_FK       = e.event_id
  JOIN Festival           AS f  ON e.festival_id_FK    = f.festival_id
  GROUP BY
    a.main_genre,
    f.festival_year
)
SELECT
  g1.genre,
  g1.year    AS year_n,
  g2.year    AS year_n_plus_1,
  g1.appearances AS appearances_in_both_years
FROM genre_year_counts AS g1
JOIN genre_year_counts AS g2
  ON g1.genre = g2.genre
 AND g2.year  = g1.year + 1
WHERE
  g1.appearances = g2.appearances
  AND g1.appearances >= 3
ORDER BY
  g1.genre,
  g1.year;

/*
WITH genre_year_counts AS (
  SELECT
    a.main_genre     AS genre,
    f.festival_year  AS year,
    COUNT(DISTINCT p.performance_id) AS appearances
  FROM Performance        AS p
  JOIN Performance_Artist AS pa  ON p.performance_id = pa.performance_id
  JOIN Artist             AS a   ON pa.artist_id       = a.artist_id
  JOIN Event              AS e   ON p.event_id_FK       = e.event_id
  JOIN Festival           AS f   ON e.festival_id_FK    = f.festival_id
  GROUP BY a.main_genre, f.festival_year
)
SELECT
  g1.genre,
  g1.year      AS year_n,
  g2.year      AS year_n_plus_1,
  g1.appearances
FROM genre_year_counts AS g1
JOIN genre_year_counts AS g2
  ON g1.genre = g2.genre
 AND g2.year  = g1.year + 1
AND g1.appearances = g2.appearances
ORDER BY g1.genre, g1.year;
*/