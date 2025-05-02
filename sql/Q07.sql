SELECT
  f.festival_id,
  f.festival_name,
  f.festival_year,
  ROUND(AVG(s.exp_id), 2) AS avg_tech_experience_level
FROM   Festival      f
JOIN   Stage_Staff   ss  ON ss.start_date BETWEEN f.start_date AND f.end_date
JOIN   Staff         s   ON s.staff_id = ss.staff_id
JOIN   Staff_role    sr  ON sr.staff_role_id = s.role_id
WHERE  sr.description = 'tech'
GROUP BY
  f.festival_id,
  f.festival_name,
  f.festival_year
ORDER BY
  avg_tech_experience_level ASC
LIMIT 1;
