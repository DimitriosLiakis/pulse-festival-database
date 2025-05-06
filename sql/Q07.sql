SELECT
  f.festival_id,
  f.festival_name,
  f.festival_year,
  ROUND(AVG(
    CASE
      WHEN LOWER(s.experience) LIKE '%intern%'      THEN 1
      WHEN LOWER(s.experience) LIKE '%beginner%'    THEN 2
      WHEN LOWER(s.experience) LIKE '%average%'     THEN 3
      WHEN LOWER(s.experience) LIKE '%experienced%' THEN 4
      WHEN LOWER(s.experience) LIKE '%expert%'      THEN 5
      ELSE NULL
    END
  ), 2) AS avg_tech_experience
FROM Staff       AS s
JOIN Stage_Staff AS ss ON ss.staff_id    = s.staff_id
                      AND LOWER(s.role) = 'tech'
JOIN Event       AS e  ON ss.stage_id    = e.stage_id_FK
JOIN Festival    AS f  ON e.festival_id_FK = f.festival_id
GROUP BY
  f.festival_id,
  f.festival_name,
  f.festival_year
HAVING
  AVG(
    CASE
      WHEN LOWER(s.experience) LIKE '%intern%'      THEN 1
      WHEN LOWER(s.experience) LIKE '%beginner%'    THEN 2
      WHEN LOWER(s.experience) LIKE '%average%'     THEN 3
      WHEN LOWER(s.experience) LIKE '%experienced%' THEN 4
      WHEN LOWER(s.experience) LIKE '%expert%'      THEN 5
      ELSE NULL
    END
  ) IS NOT NULL
ORDER BY
  avg_tech_experience ASC
LIMIT 1;
