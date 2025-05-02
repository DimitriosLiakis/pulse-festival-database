WITH genre_counts AS (
  SELECT
    a.main_genre          AS genre,
    YEAR(p.start_time)    AS yr,
    COUNT(*)              AS cnt
  FROM   Performance        p
  JOIN   Performance_Artist pa ON pa.performance_id = p.performance_id
  JOIN   Artist            a  ON a.artist_id       = pa.artist_id
  GROUP BY a.main_genre, YEAR(p.start_time)
)
SELECT
  gc1.genre,
  gc1.yr      AS year1,
  gc2.yr      AS year2,
  gc1.cnt     AS performances
FROM   genre_counts gc1
JOIN   genre_counts gc2
  ON gc1.genre = gc2.genre
 AND gc2.yr    = gc1.yr + 1
 AND gc1.cnt   = gc2.cnt
 AND gc1.cnt  >= 3
ORDER BY gc1.genre, gc1.yr;
