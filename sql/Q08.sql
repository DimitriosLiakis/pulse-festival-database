SELECT
  s.staff_id,
  s.staff_name,
  s.age,
  s.experience
FROM Staff AS s
WHERE
     s.role = 'support'
  AND NOT EXISTS (
    SELECT 1
    FROM Stage_Staff AS ss
    WHERE
         ss.staff_id = s.staff_id
      AND '2025-05-02' BETWEEN ss.start_date AND ss.end_date
  )
ORDER BY
  s.staff_name;
