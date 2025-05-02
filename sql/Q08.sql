SET @target_date = '2025-05-02';

SELECT
  s.staff_id,
  s.staff_name
FROM   Staff       s
JOIN   Staff_role  sr ON sr.staff_role_id = s.role_id
WHERE  sr.description = 'support'
  AND NOT EXISTS (
    SELECT 1
    FROM   Stage_Staff ss
    WHERE  ss.staff_id   = s.staff_id
      AND  @target_date BETWEEN ss.start_date AND ss.end_date
);
