WITH GenreYearCounts AS (
  SELECT
    a.music_genre            AS genre,
    YEAR(e.event_date)       AS yr,
    COUNT(*)                 AS cnt
  FROM   Performance_Artist pa
  JOIN   Performance         p  ON p.performance_id   = pa.performance_id_FK
  JOIN   Event               e  ON e.event_id         = p.event_id_FK
  JOIN   Artist              a  ON a.artist_id        = pa.artist_id_FK
  GROUP  BY genre, yr
  HAVING COUNT(*) >= 3       
)
SELECT
  g1.genre,
  g1.yr      AS year1,
  g1.cnt     AS count1,
  g2.yr      AS year2,
  g2.cnt     AS count2
FROM   GenreYearCounts g1
JOIN   GenreYearCounts g2
  ON g1.genre = g2.genre
 AND g2.yr   = g1.yr + 1    
 AND g2.cnt  = g1.cnt      
ORDER  BY genre, year1;
