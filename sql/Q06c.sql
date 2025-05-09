/* 6.3 Forced Nested Loop Join */
SELECT
  p.performance_id,
  e.event_name,
  p.performance_type,
  AVG(
    (r.rating_interpretation
   + r.rating_sound_light
   + r.rating_stage_presence
   + r.rating_organization
   + r.rating_overall)
    / 5.0
  ) AS avg_visitor_rating
FROM Rating      AS r
  FORCE INDEX (performance_id_FK)     -- force FK index on Rating
JOIN Performance AS p
  FORCE INDEX (PRIMARY)               -- force PK index on Performance
  /*+ LOOP_JOIN(r p) */               -- hint for Nested Loop
  ON r.performance_id_FK = p.performance_id
JOIN Event      AS e
  FORCE INDEX (PRIMARY)               -- force PK index on Event
  ON p.event_id_FK      = e.event_id
WHERE r.visitor_id_FK = 24
GROUP BY
  p.performance_id,
  e.event_name,
  p.performance_type
ORDER BY
  e.event_name,
  p.start_time;

EXPLAIN FORMAT=JSON
/* 6.3 Forced Nested Loop Join */
SELECT
  p.performance_id,
  e.event_name,
  p.performance_type,
  AVG(
    (r.rating_interpretation
   + r.rating_sound_light
   + r.rating_stage_presence
   + r.rating_organization
   + r.rating_overall)
    / 5.0
  ) AS avg_visitor_rating
FROM Rating      AS r
  FORCE INDEX (performance_id_FK)     -- force FK index on Rating
JOIN Performance AS p
  FORCE INDEX (PRIMARY)               -- force PK index on Performance
  /*+ LOOP_JOIN(r p) */               -- hint for Nested Loop
  ON r.performance_id_FK = p.performance_id
JOIN Event      AS e
  FORCE INDEX (PRIMARY)               -- force PK index on Event
  ON p.event_id_FK      = e.event_id
WHERE r.visitor_id_FK = 24
GROUP BY
  p.performance_id,
  e.event_name,
  p.performance_type
ORDER BY
  e.event_name,
  p.start_time;
