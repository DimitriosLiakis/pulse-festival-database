WITH artist_participations AS (
  SELECT
    a.artist_id,
    a.name                           AS artist_name,
    TIMESTAMPDIFF(YEAR, a.birth_date, CURDATE()) AS age,
    COUNT(DISTINCT f.festival_id)    AS festival_count
  FROM Artist               AS a
  JOIN Performance_Artist  AS pa ON a.artist_id = pa.artist_id
  JOIN Performance         AS p  ON pa.performance_id = p.performance_id
  JOIN Event               AS e  ON p.event_id_FK    = e.event_id
  JOIN Festival            AS f  ON e.festival_id_FK = f.festival_id
  WHERE
    TIMESTAMPDIFF(YEAR, a.birth_date, CURDATE()) < 30
  GROUP BY
    a.artist_id,
    a.name,
    age
)
SELECT
  artist_id,
  artist_name,
  age,
  festival_count
FROM artist_participations
WHERE festival_count = (
  SELECT MAX(festival_count)
  FROM artist_participations
)
;
