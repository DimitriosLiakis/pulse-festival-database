SELECT
  p.performance_id,
  p.performance_type,
  COUNT(t.ticket_id)              AS times_attended,
  ROUND(AVG(r.rating_overall),2)  AS avg_rating
FROM Ticket t
JOIN Performance p
  ON t.event_id_FK = p.event_id_FK
LEFT JOIN Rating r
  ON r.visitor_id_FK    = t.visitor_id_FK
 AND r.performance_id_FK = p.performance_id
WHERE t.visitor_id_FK = 7
GROUP BY
  p.performance_id,
  p.performance_type
ORDER BY p.performance_id;
