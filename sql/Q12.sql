WITH RECURSIVE
  FestivalDays AS (
    SELECT
      f.festival_id,
      f.festival_name,
      f.start_date AS day
    FROM Festival f
    UNION ALL
    SELECT
      fd.festival_id,
      fd.festival_name,
      DATE_ADD(fd.day, INTERVAL 1 DAY)
    FROM FestivalDays fd
    WHERE fd.day < (SELECT end_date
                    FROM Festival
                    WHERE festival_id = fd.festival_id)
  )

SELECT
  fd.festival_id,
  fd.festival_name,
  fd.day,
  SUM(CASE WHEN s.staff_role = 'tech'    THEN 1 ELSE 0 END) AS tech_count,
  SUM(CASE WHEN s.staff_role = 'security' THEN 1 ELSE 0 END) AS security_count,
  SUM(CASE WHEN s.staff_role = 'support'  THEN 1 ELSE 0 END) AS support_count
FROM FestivalDays fd
LEFT JOIN Stage_Staff ss
  ON ss.start_date <= fd.day
 AND ss.end_date   >= fd.day
LEFT JOIN Staff s
  ON s.staff_id = ss.staff_id_FK
GROUP BY
  fd.festival_id,
  fd.festival_name,
  fd.day
ORDER BY
  fd.festival_id,
  fd.day;
