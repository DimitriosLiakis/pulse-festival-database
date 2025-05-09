-- 11. Καλλιτέχνες που συμμετείχαν τουλάχιστον 5 φορές λιγότερο
--     από τον κορυφαίο σε εμφανίσεις σε φεστιβάλ.

WITH ArtistCounts AS (
  -- Μέτρηση εμφανίσεων (performances) ανά καλλιτέχνη
  SELECT
    a.artist_id,
    a.real_name                                    AS artist_name,
    COUNT(*)                                       AS cnt
  FROM   Performance_Artist pa
  JOIN   Performance         p  ON p.performance_id     = pa.performance_id_FK
  JOIN   Event               e  ON e.event_id           = p.event_id_FK
  JOIN   Artist              a  ON a.artist_id          = pa.artist_id_FK
  GROUP  BY a.artist_id, artist_name
),
MaxCount AS (
  -- Εύρεση της μέγιστης τιμής εμφανίσεων
  SELECT MAX(cnt) AS max_cnt
  FROM   ArtistCounts
)
SELECT
  ac.artist_id,
  ac.artist_name,
  ac.cnt              AS appearances,
  mc.max_cnt          AS top_appearances
FROM   ArtistCounts AS ac
CROSS  JOIN MaxCount  AS mc
WHERE  ac.cnt <= mc.max_cnt - 5
ORDER  BY ac.cnt DESC, ac.artist_name;
