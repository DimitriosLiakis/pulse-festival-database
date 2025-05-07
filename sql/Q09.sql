WITH ετήσιες_παρακολουθήσεις AS (
  SELECT
    t.visitor_id_FK                             AS επισκέπτης,
    COUNT(DISTINCT p.performance_id)            AS παρακολουθήσεις
  FROM Ticket      AS t
  JOIN Performance AS p
    ON p.event_id_FK = t.event_id_FK
  WHERE p.start_time
    BETWEEN DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
        AND CURDATE()
  GROUP BY t.visitor_id_FK
),
διπλά_πλήθη AS (
  SELECT
    παρακολουθήσεις
  FROM ετήσιες_παρακολουθήσεις
  WHERE παρακολουθήσεις > 3
  GROUP BY παρακολουθήσεις
  HAVING COUNT(*) > 1
)
SELECT
  e.επισκέπτης                             AS visitor_id,
  v.first_name                             AS Όνομα,
  v.last_name                              AS Επώνυμο,
  e.παρακολουθήσεις                        AS Παρακολουθήσεις_τελευταίου_έτους
FROM ετήσιες_παρακολουθήσεις AS e
JOIN διπλά_πλήθη          AS d
  ON e.παρακολουθήσεις = d.παρακολουθήσεις
JOIN Visitor              AS v
  ON v.visitor_id      = e.επισκέπτης
ORDER BY e.παρακολουθήσεις, e.επισκέπτης;
