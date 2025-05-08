WITH attendance AS (
  SELECT
    t.visitor_id_FK   AS visitor_id,
    YEAR(p.start_time) AS year,
    COUNT(DISTINCT p.performance_id) AS cnt
  FROM Ticket t
  JOIN Event e
    ON t.event_id_FK = e.event_id
  JOIN Performance p
    ON p.event_id_FK = e.event_id
  WHERE YEAR(p.start_time) = 2025
  GROUP BY
    t.visitor_id_FK,
    YEAR(p.start_time)
  HAVING COUNT(*) > 3
)
SELECT
  v.visitor_id,
  v.first_name,
  v.last_name,
  a.cnt
FROM attendance a
JOIN Visitor v
  ON v.visitor_id = a.visitor_id
WHERE
  a.cnt IN (
    SELECT cnt
    FROM attendance
    GROUP BY cnt
    HAVING COUNT(*) > 1
  )
ORDER BY a.cnt DESC;
