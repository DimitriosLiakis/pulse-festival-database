EXPLAIN ANALYZE
SELECT
  e.event_id,
  e.event_name,
  AVG(r.rating_overall) AS avg_overall_rating
FROM   Rating     r
JOIN   Performance p ON p.performance_id = r.performance_id_FK
JOIN   Event       e ON e.event_id       = p.event_id_FK
WHERE  r.visitor_id_FK = 10
GROUP BY
  e.event_id,
  e.event_name;
-- NESTED-LOOP