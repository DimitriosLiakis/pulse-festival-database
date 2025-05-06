WITH tech_assign AS (
  SELECT DISTINCT
    f.festival_id,
    s.staff_id,
    CASE s.experience
      WHEN 'intern'      THEN 1
      WHEN 'beginner'    THEN 2
      WHEN 'average'     THEN 3
      WHEN 'experienced' THEN 4
      WHEN 'expert'      THEN 5
    END AS exp_score
  FROM Stage_Staff ss
    JOIN Staff    s  ON ss.staff_id = s.staff_id
    JOIN Stage    st ON ss.stage_id = st.stage_id
    JOIN Event    e  ON e.stage_id_FK    = st.stage_id
    JOIN Festival f  ON e.festival_id_FK = f.festival_id
  WHERE s.role = 'tech'
    AND ss.start_date <= f.end_date
    AND ss.end_date   >= f.start_date
)
SELECT
  f.festival_id,
  f.festival_name,
  f.festival_year,
  ROUND(AVG(ta.exp_score), 2) AS avg_tech_experience
FROM tech_assign AS ta
  JOIN Festival AS f ON ta.festival_id = f.festival_id
GROUP BY
  f.festival_id,
  f.festival_name,
  f.festival_year
ORDER BY
  avg_tech_experience ASC
LIMIT 1;
