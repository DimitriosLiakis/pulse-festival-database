WITH RECURSIVE festival_days AS (
  SELECT
    festival_id,
    festival_name,
    start_date  AS festival_day,
    end_date
  FROM Festival

  UNION ALL

  SELECT
    festival_id,
    festival_name,
    DATE_ADD(festival_day, INTERVAL 1 DAY),
    end_date
  FROM festival_days
  WHERE festival_day < end_date
)

SELECT
  fd.festival_id,
  fd.festival_name,
  fd.festival_day,
  COALESCE(s.role, 'none') AS staff_category,
  COUNT(DISTINCT ss.staff_id) AS staff_count
FROM festival_days AS fd

LEFT JOIN Stage_Staff AS ss
  ON ss.start_date <= fd.festival_day
 AND ss.end_date   >= fd.festival_day

LEFT JOIN Staff AS s
  ON ss.staff_id = s.staff_id

GROUP BY
  fd.festival_id,
  fd.festival_name,
  fd.festival_day,
  staff_category

ORDER BY
  fd.festival_id,
  fd.festival_day,
  staff_category;
