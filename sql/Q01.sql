SELECT
  f.festival_year,
  t.purchase_method,
  SUM(t.ticket_cost) AS total_revenue
FROM Ticket   AS t
JOIN Event    AS e ON t.event_id_FK    = e.event_id
JOIN Festival AS f ON e.festival_id_FK = f.festival_id
GROUP BY f.festival_year, t.purchase_method
ORDER BY f.festival_year, t.purchase_method;
