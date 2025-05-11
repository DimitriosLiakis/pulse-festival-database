SET @p_date = '2025-06-15';

SELECT
    s.staff_id,
    s.staff_name,
    s.experience_level
FROM   Staff AS s
WHERE  s.staff_role = 'support'
  AND NOT EXISTS (
      SELECT 1
      FROM   Stage_Staff AS ss
      WHERE  ss.staff_id_FK = s.staff_id
        AND  @p_date BETWEEN ss.start_date AND ss.end_date
  )
ORDER  BY s.staff_name;
