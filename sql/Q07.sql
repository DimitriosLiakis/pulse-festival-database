-- 7. Ποιο φεστιβάλ είχε τον χαμηλότερο μέσο όρο εμπειρίας τεχνικού προσωπικού;

-- Διαβάζουμε τις εμπειρίες ως αριθμούς:
--   intern=1, beginner=2, average=3, experienced=4, expert=5

SELECT
    f.festival_id,
    f.festival_name,
    ROUND(AVG(
      CASE s.experience_level
        WHEN 'intern'     THEN 1
        WHEN 'beginner'   THEN 2
        WHEN 'average'    THEN 3
        WHEN 'experienced' THEN 4
        WHEN 'expert'     THEN 5
      END
    ), 2) AS avg_tech_experience
FROM   Festival            AS f
JOIN   Event               AS e
  ON f.festival_id = e.festival_id_FK
JOIN   Stage               AS st
  ON st.stage_id    = e.stage_id_FK
JOIN   Stage_Staff         AS ss
  ON ss.stage_id_FK = st.stage_id
JOIN   Staff               AS s
  ON s.staff_id     = ss.staff_id_FK
WHERE  s.staff_role = 'tech'
  AND  ss.start_date BETWEEN f.start_date AND f.end_date
GROUP  BY f.festival_id, f.festival_name
ORDER  BY avg_tech_experience ASC
LIMIT  1;
