WITH
  visitor_counts AS (
    SELECT
      r.visitor_id_FK       AS visitor_id,
      COUNT(*)              AS perf_count
    FROM Rating      AS r
    JOIN Performance AS p
      ON r.performance_id_FK = p.performance_id
    WHERE
      p.start_time BETWEEN DATE_SUB(CURDATE(), INTERVAL 1 YEAR) AND CURDATE()
    GROUP BY
      r.visitor_id_FK
    HAVING
      COUNT(*) > 3
  ),

  duplicate_counts AS (
    SELECT
      perf_count
    FROM visitor_counts
    GROUP BY perf_count
    HAVING COUNT(*) > 1
  )

SELECT
  vc.visitor_id,
  v.first_name,
  v.last_name,
  vc.perf_count AS attendance_count
FROM visitor_counts AS vc
JOIN duplicate_counts AS dc
  ON vc.perf_count = dc.perf_count
JOIN Visitor AS v
  ON vc.visitor_id = v.visitor_id
ORDER BY
  vc.perf_count DESC,
  vc.visitor_id;
