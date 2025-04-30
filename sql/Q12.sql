WITH festival_days AS (
  SELECT
    f.festival_id,
    DATE_ADD(f.start_date, INTERVAL seq DAY) AS fest_date
  FROM Festival f
  JOIN (
    SELECT 0 AS seq UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
    UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
    UNION ALL SELECT 8 UNION ALL SELECT 9
  ) AS days
    ON DATE_ADD(f.start_date, INTERVAL days.seq DAY) <= f.end_date
),
staff_days AS (
  SELECT
    ss.staff_id,
    ss.stage_id,
    DATE_ADD(ss.start_date, INTERVAL seq DAY) AS work_date,
    s.role
  FROM Stage_Staff ss
  JOIN Staff s ON ss.staff_id = s.staff_id
  JOIN (
    SELECT 0 AS seq UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
    UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
    UNION ALL SELECT 8 UNION ALL SELECT 9
  ) AS days
    ON DATE_ADD(ss.start_date, INTERVAL days.seq DAY) <= ss.end_date
),
festival_staff AS (
  SELECT
    fd.festival_id,
    fd.fest_date,
    sd.role,
    sd.staff_id
  FROM festival_days fd
  LEFT JOIN staff_days sd
    ON sd.work_date = fd.fest_date
  LEFT JOIN Event e
    ON e.stage_id_FK = sd.stage_id
   AND e.festival_id_FK = fd.festival_id
)
SELECT
  fs.festival_id,
  fs.fest_date   AS date,
  fs.role        AS staff_category,
  COUNT(DISTINCT fs.staff_id) AS staff_required
FROM festival_staff fs
WHERE fs.role IS NOT NULL
GROUP BY
  fs.festival_id,
  fs.fest_date,
  fs.role
ORDER BY
  fs.festival_id,
  fs.fest_date,
  fs.role;
