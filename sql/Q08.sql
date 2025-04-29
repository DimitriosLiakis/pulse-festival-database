SELECT
  s.staff_id,
  s.staff_name
FROM Staff s
WHERE s.role = 'support'
  AND NOT EXISTS (
    SELECT 1
    FROM Stage_Staff ss
    WHERE ss.staff_id = s.staff_id
      AND '2025-05-01' BETWEEN ss.start_date AND ss.end_date
  );
