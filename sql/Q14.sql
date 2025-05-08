WITH genre_counts AS (
  SELECT
    a.main_genre,
    YEAR(p.start_time) AS year,
    COUNT(*)           AS cnt
  FROM Performance p
  JOIN Performance_Artist pa ON p.performance_id = pa.performance_id
  JOIN Artist a              ON pa.artist_id   = a.artist_id
  GROUP BY
    a.main_genre,
    YEAR(p.start_time)
  HAVING
    COUNT(*) >= 3
)
SELECT
  g1.main_genre,
  g1.year   AS year1,
  g2.year   AS year2,
  g1.cnt    AS count_year1,
  g2.cnt    AS count_year2
FROM genre_counts g1
JOIN genre_counts g2
  ON g1.main_genre = g2.main_genre
  AND g2.year = g1.year + 1
  AND g1.cnt  = g2.cnt
ORDER BY
  g1.main_genre,
  g1.year;
