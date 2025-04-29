WITH attend AS (
  SELECT
    t.visitor_id_FK AS visitor_id,
    p.performance_id,
    e.event_date    AS attend_date
  FROM Ticket t
  JOIN Event e ON t.event_id_FK = e.event_id
  JOIN Performance p ON p.event_id_FK = e.event_id
  GROUP BY
    t.visitor_id_FK,
    p.performance_id,
    e.event_date
),
windowed AS (
  SELECT
    visitor_id,
    COUNT(*) OVER (
      PARTITION BY visitor_id
      ORDER BY attend_date
      RANGE BETWEEN INTERVAL 1 YEAR PRECEDING AND CURRENT ROW
    ) AS cnt_12mo
  FROM attend
)
SELECT DISTINCT visitor_id
FROM windowed
WHERE cnt_12mo > 3;
