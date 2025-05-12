/* ============================================================
   Pulse‑University Music Festival – COMPLETE install.sql
   (MySQL 8 / MariaDB 10.6+)
   ============================================================ */

DROP DATABASE IF EXISTS music_festival;
CREATE DATABASE music_festival
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;
USE music_festival;

/* ------------------------------------------------------------
   1.  Πίνακες
   ------------------------------------------------------------ */

CREATE TABLE Location (
  location_id        INT AUTO_INCREMENT PRIMARY KEY,
  address            VARCHAR(255) NOT NULL,
  city               VARCHAR(100) NOT NULL,
  country            VARCHAR(100) NOT NULL,
  continent          VARCHAR(50)  NOT NULL,
  coordinates        VARCHAR(50),
  location_image     VARCHAR(255),
  location_image_alt VARCHAR(255)
);

CREATE TABLE Festival (
  festival_id        INT AUTO_INCREMENT PRIMARY KEY,
  festival_name      VARCHAR(100) NOT NULL,
  festival_year      YEAR         NOT NULL,
  start_date         DATE         NOT NULL,
  end_date           DATE         NOT NULL,
  location_id_FK     INT NOT NULL,
  festival_image     VARCHAR(255),
  festival_image_alt VARCHAR(255),

  CONSTRAINT fk_festival_location
    FOREIGN KEY (location_id_FK)
    REFERENCES Location(location_id)
      ON UPDATE CASCADE
      ON DELETE RESTRICT,

  CONSTRAINT ck_festival_dates CHECK (end_date >= start_date),
  CONSTRAINT uk_festival_year  UNIQUE (festival_year)          -- ένα/έτος
);

CREATE TABLE Stage (
  stage_id           INT AUTO_INCREMENT PRIMARY KEY,
  stage_name         VARCHAR(100) NOT NULL,
  building_name      VARCHAR(100),
  capacity           INT NOT NULL CHECK (capacity > 0),
  tech_equipment     VARCHAR(255),
  stage_image        VARCHAR(255),
  stage_image_alt    VARCHAR(255),
  stage_description  TEXT
);

CREATE TABLE Event (
  event_id       INT AUTO_INCREMENT PRIMARY KEY,
  festival_id_FK INT NOT NULL,
  stage_id_FK    INT NOT NULL,
  event_name     VARCHAR(100) NOT NULL,
  event_date     DATE NOT NULL,
  start_time     TIME NOT NULL,
  end_time       TIME NOT NULL,
  event_image    VARCHAR(255),
  event_image_alt VARCHAR(255),

  FOREIGN KEY (festival_id_FK) REFERENCES Festival(festival_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (stage_id_FK)    REFERENCES Stage(stage_id)
    ON UPDATE CASCADE ON DELETE CASCADE,

  CHECK (end_time > start_time)
);

CREATE TABLE Artist (
  artist_id        INT AUTO_INCREMENT PRIMARY KEY,
  real_name        VARCHAR(100) NOT NULL,
  pseudonym        VARCHAR(100),
  birth_date       DATE NOT NULL,
  music_genre      VARCHAR(50) NOT NULL,
  sub_genre        VARCHAR(50),
  website          VARCHAR(255),
  instagram        VARCHAR(255),
  artist_image     VARCHAR(255),
  artist_image_alt VARCHAR(255)
);

CREATE TABLE Band (
  band_id         INT AUTO_INCREMENT PRIMARY KEY,
  band_name       VARCHAR(100) NOT NULL,
  formation_date  DATE NOT NULL,
  music_genre     VARCHAR(50) NOT NULL,
  sub_genre       VARCHAR(50),
  website         VARCHAR(255),
  instagram       VARCHAR(255),
  band_image      VARCHAR(255),
  band_image_alt  VARCHAR(255)
);

CREATE TABLE Artist_Band (
  artist_id_FK INT NOT NULL,
  band_id_FK   INT NOT NULL,
  join_date    DATE NOT NULL,
  PRIMARY KEY (artist_id_FK, band_id_FK),
  FOREIGN KEY (artist_id_FK) REFERENCES Artist(artist_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (band_id_FK)   REFERENCES Band(band_id)
    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Performance (
  performance_id        INT AUTO_INCREMENT PRIMARY KEY,
  event_id_FK           INT NOT NULL,
  performance_type      VARCHAR(20) NOT NULL
      CHECK (performance_type IN ('warm up','headline',
                                  'special guest','main act')),
  start_time            TIME NOT NULL,
  end_time              TIME NOT NULL,
  performance_image     VARCHAR(255),
  performance_image_alt VARCHAR(255),

  FOREIGN KEY (event_id_FK) REFERENCES Event(event_id)
    ON UPDATE CASCADE ON DELETE CASCADE,

  /* διάρκεια ≤ 3 ώρες */
  CONSTRAINT ck_perf_duration
     CHECK (TIMESTAMPDIFF(SECOND,start_time,end_time) BETWEEN 1 AND 10800),

  CHECK (end_time > start_time)
);

CREATE TABLE Performance_Artist (
  performance_id_FK INT NOT NULL,
  artist_id_FK      INT NOT NULL,
  band_id_FK        INT,
  PRIMARY KEY (performance_id_FK, artist_id_FK),
  FOREIGN KEY (performance_id_FK) REFERENCES Performance(performance_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (artist_id_FK) REFERENCES Artist(artist_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (band_id_FK)   REFERENCES Band(band_id)
    ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE Performance_Band (
  performance_id_FK INT NOT NULL,
  band_id_FK        INT NOT NULL,
  artist_id_FK      INT,
  PRIMARY KEY (performance_id_FK, band_id_FK),
  FOREIGN KEY (performance_id_FK) REFERENCES Performance(performance_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (band_id_FK)   REFERENCES Band(band_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (artist_id_FK) REFERENCES Artist(artist_id)
    ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE Visitor (
  visitor_id   INT AUTO_INCREMENT PRIMARY KEY,
  first_name   VARCHAR(50) NOT NULL,
  last_name    VARCHAR(50) NOT NULL,
  contact_info VARCHAR(255),
  visitor_age  INT CHECK (visitor_age BETWEEN 0 AND 120)
);

CREATE TABLE Ticket (
  ticket_id        INT AUTO_INCREMENT PRIMARY KEY,
  event_id_FK      INT NOT NULL,
  visitor_id_FK    INT NOT NULL,
  ticket_category  VARCHAR(10) NOT NULL
      CHECK (ticket_category IN ('general','VIP','backstage')),
  purchase_date    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ticket_cost      DECIMAL(8,2) NOT NULL CHECK (ticket_cost >= 0),
  purchase_method  VARCHAR(15) NOT NULL
      CHECK (purchase_method IN ('credit_card','debit_card',
                                 'bank_transfer','other')),
  ean_code         CHAR(13) NOT NULL,
  is_activated     TINYINT(1) NOT NULL DEFAULT 0,

  FOREIGN KEY (event_id_FK)   REFERENCES Event(event_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (visitor_id_FK) REFERENCES Visitor(visitor_id)
    ON UPDATE CASCADE ON DELETE CASCADE,

  UNIQUE KEY uk_ticket_once (visitor_id_FK, event_id_FK),

  /* έγκυρος EAN‑13 */
  CONSTRAINT ck_ean13_numeric
     CHECK (ean_code REGEXP '^[0-9]{13}$')
);

CREATE TABLE Rating (
  rating_id             INT AUTO_INCREMENT PRIMARY KEY,
  visitor_id_FK         INT NOT NULL,
  performance_id_FK     INT NOT NULL,
  rating_interpretation TINYINT NOT NULL CHECK (rating_interpretation BETWEEN 1 AND 5),
  rating_sound_light    TINYINT NOT NULL CHECK (rating_sound_light    BETWEEN 1 AND 5),
  rating_stage_presence TINYINT NOT NULL CHECK (rating_stage_presence BETWEEN 1 AND 5),
  rating_organization   TINYINT NOT NULL CHECK (rating_organization   BETWEEN 1 AND 5),
  rating_overall        TINYINT NOT NULL CHECK (rating_overall        BETWEEN 1 AND 5),
  rating_date           DATE   NOT NULL DEFAULT (CURRENT_DATE),

  FOREIGN KEY (visitor_id_FK)     REFERENCES Visitor(visitor_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (performance_id_FK) REFERENCES Performance(performance_id)
    ON UPDATE CASCADE ON DELETE CASCADE,

  UNIQUE KEY uk_visitor_performance (visitor_id_FK, performance_id_FK)
);

CREATE TABLE Staff (
  staff_id        INT AUTO_INCREMENT PRIMARY KEY,
  staff_name      VARCHAR(100) NOT NULL,
  staff_age       INT NOT NULL CHECK (staff_age >= 18),
  staff_role      VARCHAR(10) NOT NULL
      CHECK (staff_role IN ('tech','security','support')),
  experience_level VARCHAR(12) NOT NULL
      CHECK (experience_level IN ('intern','beginner','average',
                                  'experienced','expert')),
  staff_image     VARCHAR(255),
  staff_image_alt VARCHAR(255)
);

CREATE TABLE Stage_Staff (
  stage_id_FK INT NOT NULL,
  staff_id_FK INT NOT NULL,
  start_date  DATE NOT NULL,
  end_date    DATE NOT NULL,
  PRIMARY KEY (stage_id_FK, staff_id_FK, start_date),
  FOREIGN KEY (stage_id_FK) REFERENCES Stage(stage_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (staff_id_FK) REFERENCES Staff(staff_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CHECK (end_date >= start_date)
);

CREATE TABLE Resale_queue (
  queue_id       INT AUTO_INCREMENT PRIMARY KEY,
  ticket_id_FK   INT NOT NULL,
  visitor_id_FK  INT NOT NULL,
  event_id_FK    INT NOT NULL,
  interest_type  VARCHAR(6) NOT NULL
      CHECK (interest_type IN ('seller','buyer')),
  interest_date  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (ticket_id_FK)  REFERENCES Ticket(ticket_id)
      ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (visitor_id_FK) REFERENCES Visitor(visitor_id)
      ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (event_id_FK)   REFERENCES Event(event_id)
      ON UPDATE CASCADE ON DELETE CASCADE
);

/* ------------------------------------------------------------
   2.  Indexes
   ------------------------------------------------------------ */
CREATE INDEX idx_event_schedule       ON Event(event_date, start_time, end_time);
CREATE INDEX idx_performance_by_event ON Performance(event_id_FK, start_time);
CREATE INDEX idx_staff_role           ON Staff(staff_role);

/* ============================================================
   3.  Triggers  – Business Rules
   ============================================================ */
DELIMITER $$

/* ------------------------------------------------------------
   3.1  Staff quotas (≥ 5 % security, ≥ 2 % support)
   ------------------------------------------------------------ */
DROP TRIGGER IF EXISTS trg_staff_quota;
CREATE TRIGGER trg_staff_quota
BEFORE INSERT ON Stage_Staff
FOR EACH ROW
BEGIN
  DECLARE cap INT;
  DECLARE role_txt VARCHAR(10);
  DECLARE cnt INT;

  IF IFNULL(@bulk_load,0) = 0 THEN

    SELECT capacity INTO cap
      FROM Stage WHERE stage_id = NEW.stage_id_FK;

    SELECT staff_role INTO role_txt
      FROM Staff WHERE staff_id = NEW.staff_id_FK;

    SELECT COUNT(*) INTO cnt
      FROM Stage_Staff ss
      JOIN Staff s ON s.staff_id = ss.staff_id_FK
     WHERE ss.stage_id_FK = NEW.stage_id_FK
       AND ss.start_date  = NEW.start_date
       AND s.staff_role   = role_txt;

    IF role_txt = 'security' AND cnt + 1 < CEIL(cap*0.05) THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Security staff below 5% of capacity';
    ELSEIF role_txt = 'support' AND cnt + 1 < CEIL(cap*0.02) THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Support staff below 2% of capacity';
    END IF;
  END IF;
END$$

/* ------------------------------------------------------------
   3.2  No overlapping Events in same Stage
   ------------------------------------------------------------ */
DROP TRIGGER IF EXISTS trg_event_overlap;
CREATE TRIGGER trg_event_overlap
BEFORE INSERT ON Event
FOR EACH ROW
BEGIN
  DECLARE overlap INT;
  SELECT COUNT(*) INTO overlap
    FROM Event
   WHERE stage_id_FK = NEW.stage_id_FK
     AND event_date  = NEW.event_date
     AND (NEW.start_time < end_time AND NEW.end_time > start_time);

  IF overlap > 0 THEN
     SIGNAL SQLSTATE '45000'
       SET MESSAGE_TEXT='Stage already booked in this time slot';
  END IF;
END$$

/* ------------------------------------------------------------
   3.3  Performance gaps 5–30′  &  no overlap inside Event
   ------------------------------------------------------------ */
DROP TRIGGER IF EXISTS trg_performance_gap;
CREATE TRIGGER trg_performance_gap
BEFORE INSERT ON Performance
FOR EACH ROW
BEGIN
  DECLARE overlap_cnt INT;
  DECLARE prev_end TIME;
  DECLARE gap INT;

  /* 3.3.1 overlap στον ίδιο Event */
  SELECT COUNT(*) INTO overlap_cnt
    FROM Performance
   WHERE event_id_FK = NEW.event_id_FK
     AND (NEW.start_time < end_time AND NEW.end_time > start_time);

  IF overlap_cnt > 0 THEN
     SIGNAL SQLSTATE '45000'
       SET MESSAGE_TEXT='Overlapping performance in same event';
  END IF;

  /* 3.3.2 κενό 5–30 λεπτά */
  SET prev_end = NULL;
  SELECT end_time INTO prev_end
    FROM Performance
   WHERE event_id_FK = NEW.event_id_FK
     AND end_time <= NEW.start_time
   ORDER BY end_time DESC LIMIT 1;

  IF prev_end IS NOT NULL THEN
     SET gap = TIMESTAMPDIFF(MINUTE, prev_end, NEW.start_time);
     IF gap < 5 OR gap > 30 THEN
        SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT='Gap between performances must be 5–30 minutes';
     END IF;
  END IF;
END$$

/* ------------------------------------------------------------
   3.4  Artist cannot be in two stages simultaneously
   ------------------------------------------------------------ */
DROP TRIGGER IF EXISTS trg_artist_double_booking;
CREATE TRIGGER trg_artist_double_booking
BEFORE INSERT ON Performance_Artist
FOR EACH ROW
BEGIN
  DECLARE v_event INT;
  DECLARE st TIME;
  DECLARE et TIME;
  DECLARE ev_date DATE;
  DECLARE clash INT;

  /* λεπτομέρειες νέου slot */
  SELECT event_id_FK, start_time, end_time
    INTO v_event, st, et
    FROM Performance WHERE performance_id = NEW.performance_id_FK;

  SELECT event_date INTO ev_date
    FROM Event WHERE event_id = v_event;

  /* check overlap */
  SELECT COUNT(*) INTO clash
    FROM Performance_Artist pa
    JOIN Performance p  ON p.performance_id = pa.performance_id_FK
    JOIN Event      e  ON e.event_id        = p.event_id_FK
   WHERE pa.artist_id_FK = NEW.artist_id_FK
     AND e.event_date    = ev_date
     AND (st < p.end_time AND et > p.start_time)
     AND pa.performance_id_FK <> NEW.performance_id_FK;

  IF clash > 0 THEN
     SIGNAL SQLSTATE '45000'
       SET MESSAGE_TEXT='Artist already booked in another stage this time';
  END IF;
END$$

/* ------------------------------------------------------------
   3.5  Artist ≤ 3 consecutive years
   ------------------------------------------------------------ */
DROP TRIGGER IF EXISTS trg_artist_consecutive_years;
CREATE TRIGGER trg_artist_consecutive_years
BEFORE INSERT ON Performance_Artist
FOR EACH ROW
BEGIN
  DECLARE v_year YEAR;
  DECLARE years_cnt INT;

  /* έτος της νέας εμφάνισης */
  SELECT f.festival_year INTO v_year
    FROM Performance p
    JOIN Event    e ON e.event_id        = p.event_id_FK
    JOIN Festival f ON f.festival_id     = e.festival_id_FK
   WHERE p.performance_id = NEW.performance_id_FK;

  /* πόσα διαδοχικά έτη (v_year-2 .. v_year-1) */
  SELECT COUNT(DISTINCT f.festival_year)
    INTO years_cnt
    FROM Performance_Artist pa
    JOIN Performance p  ON p.performance_id = pa.performance_id_FK
    JOIN Event      e  ON e.event_id        = p.event_id_FK
    JOIN Festival   f  ON f.festival_id     = e.festival_id_FK
   WHERE pa.artist_id_FK = NEW.artist_id_FK
     AND f.festival_year BETWEEN v_year-2 AND v_year-1;

  IF years_cnt = 3 THEN
     SIGNAL SQLSTATE '45000'
       SET MESSAGE_TEXT='Artist cannot perform more than 3 consecutive years';
  END IF;
END$$

/* ------------------------------------------------------------
   3.6  Stage capacity & VIP ≤ 10 %
   ------------------------------------------------------------ */
DROP TRIGGER IF EXISTS trg_ticket_capacity;
CREATE TRIGGER trg_ticket_capacity
BEFORE INSERT ON Ticket
FOR EACH ROW
BEGIN
  DECLARE cap INT;
  DECLARE sold INT;
  DECLARE sold_vip INT;

  SELECT capacity INTO cap
    FROM Stage s
    JOIN Event e ON e.stage_id_FK = s.stage_id
   WHERE e.event_id = NEW.event_id_FK;

  SELECT COUNT(*) INTO sold
    FROM Ticket t WHERE t.event_id_FK = NEW.event_id_FK;

  IF sold >= cap THEN
     SIGNAL SQLSTATE '45000'
       SET MESSAGE_TEXT='Stage capacity exceeded';
  END IF;

  IF NEW.ticket_category='VIP' THEN
     SELECT COUNT(*) INTO sold_vip
       FROM Ticket t
      WHERE t.event_id_FK    = NEW.event_id_FK
        AND t.ticket_category='VIP';
     IF sold_vip >= CEIL(cap*0.10) THEN
        SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT='VIP quota (10%) exceeded';
     END IF;
  END IF;
END$$

/* ------------------------------------------------------------
   3.7  Rating only with activated ticket
   ------------------------------------------------------------ */
DROP TRIGGER IF EXISTS trg_rating_allowed;
CREATE TRIGGER trg_rating_allowed
BEFORE INSERT ON Rating
FOR EACH ROW
BEGIN
  DECLARE v_cnt INT;

  SELECT COUNT(*) INTO v_cnt
    FROM Ticket t
    JOIN Performance p ON p.performance_id = NEW.performance_id_FK
   WHERE t.visitor_id_FK = NEW.visitor_id_FK
     AND t.event_id_FK   = p.event_id_FK
     AND t.is_activated  = 1;

  IF v_cnt = 0 THEN
     SIGNAL SQLSTATE '45000'
       SET MESSAGE_TEXT='Rating allowed only for holders of activated ticket';
  END IF;
END$$

DELIMITER ;

/* ------------------------------------------------------------
   4.  OK Message
   ------------------------------------------------------------ */
SELECT '✅  Schema installed with full constraint set.' AS status;
