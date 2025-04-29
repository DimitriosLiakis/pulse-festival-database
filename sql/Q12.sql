WITH fd AS (
  SELECT f.festival_id, DATE_ADD(f.start_date, INTERVAL seq DAY) AS fest_date
  FROM Festival f
  JOIN (
    SELECT 0 AS seq UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
    UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
  ) s ON f.start_date + INTERVAL s.seq DAY <= f.end_date
),
ss AS (
  SELECT
    ss.staff_id, ss.stage_id,
    DATE_ADD(ss.start_date, INTERVAL s.seq DAY) AS work_date,
    st.role
  FROM Stage_Staff ss
  JOIN Staff st ON ss.staff_id = st.staff_id
  JOIN (
    SELECT 0 AS seq UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
    UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
  ) s ON ss.start_date + INTERVAL s.seq DAY <= ss.end_date
),
fs AS (
  SELECT
    fd.festival_id,
    fd.fest_date,
    ss.role,
    ss.staff_id
  FROM fd
  LEFT JOIN ss ON ss.work_date = fd.fest_date
)
SELECT
  festival_id,
  fest_date,
  role AS staff_category,
  COUNT(DISTINCT staff_id) AS staff_count
FROM fs
GROUP BY festival_id, fest_date, role
ORDER BY festival_id, fest_date, role;
