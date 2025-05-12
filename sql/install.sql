
DROP DATABASE IF EXISTS music_festival;
CREATE DATABASE music_festival
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;
USE music_festival;

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
  location_id_FK     INT          NOT NULL,
  festival_image     VARCHAR(255),
  festival_image_alt VARCHAR(255),
  CONSTRAINT fk_festival_location
    FOREIGN KEY (location_id_FK)
    REFERENCES Location(location_id)
      ON UPDATE CASCADE
      ON DELETE RESTRICT,
  CONSTRAINT ck_festival_dates CHECK (end_date >= start_date)
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
  event_id         INT AUTO_INCREMENT PRIMARY KEY,
  festival_id_FK   INT NOT NULL,
  stage_id_FK      INT NOT NULL,
  event_name       VARCHAR(100) NOT NULL,
  event_date       DATE NOT NULL,
  start_time       TIME NOT NULL,
  end_time         TIME NOT NULL,
  event_image      VARCHAR(255),
  event_image_alt  VARCHAR(255),
  FOREIGN KEY (festival_id_FK) REFERENCES Festival(festival_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (stage_id_FK)    REFERENCES Stage(stage_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT ck_event_time CHECK (end_time > start_time)
);

CREATE TABLE Artist (
  artist_id        INT AUTO_INCREMENT PRIMARY KEY,
  real_name        VARCHAR(100) NOT NULL,
  pseudonym       VARCHAR(100),
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
      CHECK (performance_type IN ('warm up','headline','special guest','main act')),
  start_time            TIME NOT NULL,
  end_time              TIME NOT NULL,
  performance_image     VARCHAR(255),
  performance_image_alt VARCHAR(255),
  FOREIGN KEY (event_id_FK) REFERENCES Event(event_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
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
      CHECK (purchase_method IN ('credit_card','debit_card','bank_transfer','other')),
  ean_code         CHAR(13) NOT NULL UNIQUE,
  is_activated     TINYINT(1) NOT NULL DEFAULT 0,
  FOREIGN KEY (event_id_FK)   REFERENCES Event(event_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (visitor_id_FK) REFERENCES Visitor(visitor_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  UNIQUE KEY uk_ticket_once (visitor_id_FK, event_id_FK)
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
  rating_date           DATE NOT NULL DEFAULT (CURRENT_DATE),
  FOREIGN KEY (visitor_id_FK)     REFERENCES Visitor(visitor_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (performance_id_FK) REFERENCES Performance(performance_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  UNIQUE KEY uk_visitor_performance (visitor_id_FK, performance_id_FK)
);

CREATE TABLE Staff (
  staff_id        INT AUTO_INCREMENT PRIMARY KEY,
  staff_name      VARCHAR(100) NOT NULL,
  staff_age       INT  NOT NULL CHECK (staff_age >= 18),
  staff_role      VARCHAR(10) NOT NULL
      CHECK (staff_role IN ('tech','security','support')),
  experience_level VARCHAR(12) NOT NULL
      CHECK (experience_level IN ('intern','beginner','average','experienced','expert')),
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
  queue_id           INT AUTO_INCREMENT PRIMARY KEY,
  ticket_id_FK       INT NOT NULL,
  visitor_id_FK      INT NOT NULL,
  event_id_FK        INT NOT NULL,
  interest_type      VARCHAR(6) NOT NULL
      CHECK (interest_type IN ('seller','buyer')),
  interest_date      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (ticket_id_FK)
    REFERENCES Ticket(ticket_id)
      ON UPDATE CASCADE
      ON DELETE CASCADE,
  FOREIGN KEY (visitor_id_FK)
    REFERENCES Visitor(visitor_id)
      ON UPDATE CASCADE
      ON DELETE CASCADE,
  FOREIGN KEY (event_id_FK)
    REFERENCES Event(event_id)
      ON UPDATE CASCADE
      ON DELETE CASCADE
);

-- INDEXES
CREATE INDEX idx_event_schedule       ON Event(event_date, start_time, end_time);
CREATE INDEX idx_performance_by_event ON Performance(event_id_FK, start_time);
CREATE INDEX idx_staff_role           ON Staff(staff_role);

-- TRIGGERS
DROP TRIGGER IF EXISTS trg_staff_quota;
DELIMITER $$
CREATE TRIGGER trg_staff_quota
BEFORE INSERT ON Stage_Staff
FOR EACH ROW
BEGIN
  DECLARE cap INT;
  DECLARE role_txt VARCHAR(30);
  DECLARE cnt INT;

  IF IFNULL(@bulk_load,0) = 0 THEN
    SELECT capacity INTO cap
      FROM Stage
     WHERE stage_id = NEW.stage_id_FK;

    SELECT staff_role INTO role_txt
      FROM Staff
     WHERE staff_id = NEW.staff_id_FK;

    SELECT COUNT(*) INTO cnt
      FROM Stage_Staff ss
      JOIN Staff s ON s.staff_id = ss.staff_id_FK
     WHERE ss.stage_id_FK = NEW.stage_id_FK
       AND ss.start_date  = NEW.start_date
       AND s.staff_role   = role_txt;

    IF role_txt = 'security' AND cnt + 1 < CEIL(cap * 0.05) THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Security staff below 5% of capacity';
    ELSEIF role_txt = 'support' AND cnt + 1 < CEIL(cap * 0.02) THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Support staff below 2% of capacity';
    END IF;
  END IF;
END$$
DELIMITER ;
