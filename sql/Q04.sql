SELECT
  ROUND(AVG(r.rating_interpretation),2) AS avg_interpretation,
  ROUND(AVG(r.rating_overall),2)        AS avg_overall
FROM Rating r
JOIN Performance_Artist pa ON r.performance_id_FK = pa.performance_id
WHERE pa.artist_id = 20;