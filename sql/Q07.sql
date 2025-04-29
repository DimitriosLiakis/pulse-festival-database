SELECT
  f.festival_id,
  f.festival_name,
  ROUND(AVG(
    FIELD(s.experience_level,
      'intern','beginner','average','experienced','expert')
  ),2) AS avg_tech_experience
FROM Festival f
JOIN Event e       ON e.festival_id_FK = f.festival_id
JOIN Stage_Staff ss ON ss.stage_id     = e.stage_id_FK
JOIN Staff s       ON ss.staff_id       = s.staff_id
WHERE s.role = 'tech'
GROUP BY
  f.festival_id,
  f.festival_name
ORDER BY avg_tech_experience
LIMIT 1;
