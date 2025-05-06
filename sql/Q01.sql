SELECT
  f.festival_year       AS Έτος,
  COALESCE(t.purchase_method, 'Σύνολο_Εσόδων') AS Τρόπος_Πληρωμής,
  SUM(t.ticket_cost)    AS Σύνολο_Εσόδων
FROM Ticket    AS t
JOIN Event     AS e  ON t.event_id_FK    = e.event_id
JOIN Festival  AS f  ON e.festival_id_FK = f.festival_id
GROUP BY
  f.festival_year,
  t.purchase_method
WITH ROLLUP
HAVING
  (festival_year IS NOT NULL AND purchase_method IS NOT NULL)
  OR
  (festival_year IS NOT NULL AND purchase_method IS NULL)
ORDER BY
  f.festival_year,
  purchase_method IS NULL,
  purchase_method;
