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
JOIN Performance AS p
  ON r.performance_id_FK = p.performance_id
JOIN Event       AS e
  ON p.event_id_FK      = e.event_id
WHERE r.visitor_id_FK = 24
GROUP BY
  p.performance_id,
  e.event_name,
  p.performance_type
ORDER BY
  e.event_name,
  p.start_time;
