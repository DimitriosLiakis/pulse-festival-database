WITH RECURSIVE festival_days AS (
  SELECT
    festival_id,
    start_date AS day
  FROM Festival
  UNION ALL
  SELECT
    festival_id,
    DATE_ADD(day, INTERVAL 1 DAY)
  FROM festival_days
  WHERE day < (
    SELECT end_date
      FROM Festival
     WHERE Festival.festival_id = festival_days.festival_id
  )
)
SELECT
  f.festival_id,
  f.festival_name,
  fd.day,
  sr.description     AS role,
  COUNT(DISTINCT ss.staff_id) AS staff_count
FROM festival_days fd
JOIN Festival     f  ON f.festival_id   = fd.festival_id
JOIN Stage_Staff  ss ON ss.start_date <= fd.day
                    AND ss.end_date   >= fd.day
JOIN Staff        s  ON s.staff_id      = ss.staff_id
JOIN Staff_role   sr ON sr.staff_role_id = s.role_id
GROUP BY
  f.festival_id,
  f.festival_name,
  fd.day,
  sr.description
ORDER BY
  f.festival_id,
  fd.day,
  sr.description;
