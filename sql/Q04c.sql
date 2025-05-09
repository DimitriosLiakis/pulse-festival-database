/* 4.3 Forced Nested Loop Join */
SELECT
  a.artist_id,
  a.name                     AS artist_name,
  AVG(r.rating_interpretation) AS avg_interpretation,
  AVG(r.rating_overall)        AS avg_overall
FROM Rating             AS r
  FORCE INDEX (performance_id_FK)    -- αναγκαστική χρήση του index επί του FK
JOIN Performance_Artist AS pa
  FORCE INDEX (PRIMARY)              -- χρήση primary key index
  /*+ LOOP_JOIN(r pa) */             -- hint για Nested Loop
  ON r.performance_id_FK = pa.performance_id
JOIN Artist             AS a
  FORCE INDEX (PRIMARY)
  ON pa.artist_id       = a.artist_id
WHERE a.artist_id = 5
GROUP BY a.artist_id;

EXPLAIN FORMAT=JSON
SELECT
  a.artist_id,
  a.name                     AS artist_name,
  AVG(r.rating_interpretation) AS avg_interpretation,
  AVG(r.rating_overall)        AS avg_overall
FROM Rating             AS r
  FORCE INDEX (performance_id_FK)    -- αναγκαστική χρήση του index επί του FK
JOIN Performance_Artist AS pa
  FORCE INDEX (PRIMARY)              -- χρήση primary key index
  /*+ LOOP_JOIN(r pa) */             -- hint για Nested Loop
  ON r.performance_id_FK = pa.performance_id
JOIN Artist             AS a
  FORCE INDEX (PRIMARY)
  ON pa.artist_id       = a.artist_id
WHERE a.artist_id = 5
GROUP BY a.artist_id;
