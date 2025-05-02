SELECT
  v.visitor_id,
  v.first_name,
  v.last_name,
  YEAR(e.event_start) AS year,
  COUNT(*)             AS attended_count
FROM   Visitor v
JOIN   Ticket  t ON t.visitor_id_FK = v.visitor_id
               AND t.is_activated   = 1
JOIN   Event   e ON e.event_id       = t.event_id_FK
GROUP BY v.visitor_id, year
HAVING attended_count > 3;
