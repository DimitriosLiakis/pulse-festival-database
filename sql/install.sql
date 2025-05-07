DROP DATABASE IF EXISTS pip;
CREATE DATABASE pip
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;
USE pip;

CREATE TABLE Location (
  location_id INT PRIMARY KEY,
  address VARCHAR(255) NOT NULL,
  city VARCHAR(100) NOT NULL,
  country VARCHAR(100) NOT NULL,
  continent VARCHAR(50) NOT NULL,
  coordinates VARCHAR(50),
  location_image VARCHAR(255)
);

CREATE TABLE Festival (
  festival_id INT PRIMARY KEY,
  festival_name VARCHAR(100) NOT NULL,
  festival_year YEAR NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  location_id_FK INT NOT NULL,
  festival_image VARCHAR(255),
  FOREIGN KEY (location_id_FK)
    REFERENCES Location(location_id)
      ON UPDATE CASCADE
      ON DELETE RESTRICT,
  CHECK (end_date >= start_date)
);

CREATE TABLE Stage (
  stage_id INT PRIMARY KEY,
  stage_name VARCHAR(100) NOT NULL,
  stage_description TEXT,
  capacity INT NOT NULL CHECK (capacity > 0),
  tech_equipment VARCHAR(255),
  stage_image VARCHAR(255)
);

CREATE TABLE Event (
  event_id INT PRIMARY KEY,
  event_name VARCHAR(100) NOT NULL,
  festival_id_FK INT NOT NULL,
  stage_id_FK INT NOT NULL,
  event_start DATETIME NOT NULL,
  event_end DATETIME NOT NULL,
  event_image VARCHAR(255),
  FOREIGN KEY (festival_id_FK)
    REFERENCES Festival(festival_id)
      ON UPDATE CASCADE
      ON DELETE CASCADE,
  FOREIGN KEY (stage_id_FK)
    REFERENCES Stage(stage_id)
      ON UPDATE CASCADE
      ON DELETE CASCADE,
  CHECK (event_end > event_start)
);

CREATE TABLE Artist (
  artist_id INT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  pseudonym VARCHAR(50),
  birth_date DATE NOT NULL,
  main_genre VARCHAR(50) NOT NULL,
  sub_genre VARCHAR(50),
  website VARCHAR(255),
  instagram VARCHAR(255),
  image_url VARCHAR(255)
);

CREATE TABLE Band (
  band_id INT PRIMARY KEY,
  band_name VARCHAR(100) NOT NULL,
  formation_date DATE NOT NULL,
  website VARCHAR(255),
  instagram VARCHAR(255),
  image_url VARCHAR(255)
);

CREATE TABLE Artist_Band (
  artist_id INT NOT NULL,
  band_id INT NOT NULL,
  join_date DATE NOT NULL,
  PRIMARY KEY (artist_id, band_id),
  FOREIGN KEY (artist_id)
    REFERENCES Artist(artist_id)
      ON UPDATE CASCADE
      ON DELETE CASCADE,
  FOREIGN KEY (band_id)
    REFERENCES Band(band_id)
      ON UPDATE CASCADE
      ON DELETE CASCADE
);

CREATE TABLE Performance (
  performance_id INT PRIMARY KEY,
  event_id_FK INT NOT NULL,
  performance_type VARCHAR(30) NOT NULL
    CHECK (performance_type IN (
      'warm up','headline','special guest','main act'
    )),
  start_time DATETIME NOT NULL,
  duration_minutes INT NOT NULL
    CHECK (duration_minutes BETWEEN 1 AND 180),
  performance_image VARCHAR(255),
  FOREIGN KEY (event_id_FK)
    REFERENCES Event(event_id)
      ON UPDATE CASCADE
      ON DELETE CASCADE
);

CREATE TABLE Performance_Artist (
  performance_id INT NOT NULL,
  artist_id INT NOT NULL,
  PRIMARY KEY (performance_id, artist_id),
  FOREIGN KEY (performance_id)
    REFERENCES Performance(performance_id)
      ON UPDATE CASCADE
      ON DELETE CASCADE,
  FOREIGN KEY (artist_id)
    REFERENCES Artist(artist_id)
      ON UPDATE CASCADE
      ON DELETE CASCADE
);

CREATE TABLE Performance_Band (
  performance_id INT NOT NULL,
  band_id INT NOT NULL,
  PRIMARY KEY (performance_id, band_id),
  FOREIGN KEY (performance_id)
    REFERENCES Performance(performance_id)
      ON UPDATE CASCADE
      ON DELETE CASCADE,
  FOREIGN KEY (band_id)
    REFERENCES Band(band_id)
      ON UPDATE CASCADE
      ON DELETE CASCADE
);

CREATE TABLE Visitor (
  visitor_id INT PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  age INT CHECK (age BETWEEN 0 AND 120),
  phone VARCHAR(30),
  email VARCHAR(100)
);

CREATE TABLE Ticket (
  ticket_id INT PRIMARY KEY,
  event_id_FK INT NOT NULL,
  visitor_id_FK INT NOT NULL,
  ticket_category VARCHAR(30) NOT NULL
    CHECK (ticket_category IN ('general','VIP','backstage')),
  purchase_date DATETIME NOT NULL,
  ticket_cost DECIMAL(8,2) NOT NULL CHECK (ticket_cost >= 0),
  purchase_method VARCHAR(30) NOT NULL
    CHECK (purchase_method IN (
      'credit_card','debit_card','bank_transfer','other'
    )),
  ean_code CHAR(13) NOT NULL UNIQUE,
  is_activated TINYINT(1) NOT NULL DEFAULT 0,
  FOREIGN KEY (event_id_FK)
    REFERENCES Event(event_id)
      ON UPDATE CASCADE
      ON DELETE CASCADE,
  FOREIGN KEY (visitor_id_FK)
    REFERENCES Visitor(visitor_id)
      ON UPDATE CASCADE
      ON DELETE CASCADE,
  UNIQUE KEY uk_ticket_per_day (visitor_id_FK, event_id_FK)
);

CREATE TABLE Staff (
  staff_id INT PRIMARY KEY,
  staff_name VARCHAR(100) NOT NULL,
  age INT NOT NULL CHECK (age >= 18),
  role VARCHAR(30) NOT NULL
    CHECK (role IN ('tech','security','support')),
  experience VARCHAR(30) NOT NULL
    CHECK (experience IN (
      'intern','beginner','average','experienced','expert'
    ))
);

CREATE TABLE Stage_Staff (
  stage_id INT NOT NULL,
  staff_id INT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  PRIMARY KEY (stage_id, staff_id, start_date),
  FOREIGN KEY (stage_id)
    REFERENCES Stage(stage_id)
      ON UPDATE CASCADE
      ON DELETE CASCADE,
  FOREIGN KEY (staff_id)
    REFERENCES Staff(staff_id)
      ON UPDATE CASCADE
      ON DELETE CASCADE,
  CHECK (end_date >= start_date)
);

CREATE TABLE Rating (
  rating_id INT PRIMARY KEY,
  visitor_id_FK INT NOT NULL,
  performance_id_FK INT NOT NULL,
  rating_interpretation TINYINT NOT NULL
    CHECK (rating_interpretation BETWEEN 1 AND 5),
  rating_sound_light    TINYINT NOT NULL
    CHECK (rating_sound_light BETWEEN 1 AND 5),
  rating_stage_presence TINYINT NOT NULL
    CHECK (rating_stage_presence BETWEEN 1 AND 5),
  rating_organization   TINYINT NOT NULL
    CHECK (rating_organization BETWEEN 1 AND 5),
  rating_overall        TINYINT NOT NULL
    CHECK (rating_overall BETWEEN 1 AND 5),
  FOREIGN KEY (visitor_id_FK)
    REFERENCES Visitor(visitor_id)
      ON UPDATE CASCADE
      ON DELETE CASCADE,
  FOREIGN KEY (performance_id_FK)
    REFERENCES Performance(performance_id)
      ON UPDATE CASCADE
      ON DELETE CASCADE,
  UNIQUE KEY uk_rating_once(visitor_id_FK, performance_id_FK)
);

CREATE TABLE Resale_queue (
  resale_id INT PRIMARY KEY,
  ticket_id_FK INT NOT NULL,
  visitor_id_FK INT NOT NULL,
  interest_type VARCHAR(30) NOT NULL
    CHECK (interest_type IN ('seller','buyer')),
  interest_date DATETIME NOT NULL,
  FOREIGN KEY (ticket_id_FK)
    REFERENCES Ticket(ticket_id)
      ON UPDATE CASCADE
      ON DELETE CASCADE,
  FOREIGN KEY (visitor_id_FK)
    REFERENCES Visitor(visitor_id)
      ON UPDATE CASCADE
      ON DELETE CASCADE
);

CREATE INDEX idx_event_period
  ON Event(event_start, event_end);
CREATE INDEX idx_performance_event
  ON Performance(event_id_FK, start_time);
CREATE INDEX idx_staff_role
  ON Staff(role);

DROP TRIGGER IF EXISTS trg_staff_quota;
DELIMITER $$
CREATE TRIGGER trg_staff_quota
BEFORE INSERT ON Stage_Staff
FOR EACH ROW
BEGIN
  DECLARE cap INT;
  DECLARE role_txt VARCHAR(30);
  DECLARE cnt INT;
  IF IFNULL(@bulk_load,0)=0 THEN
    SELECT capacity INTO cap
      FROM Stage
     WHERE stage_id = NEW.stage_id;

    SELECT role INTO role_txt
      FROM Staff
     WHERE staff_id = NEW.staff_id;

    SELECT COUNT(*) INTO cnt
      FROM Stage_Staff ss
      JOIN Staff s ON s.staff_id = ss.staff_id
     WHERE ss.stage_id = NEW.stage_id
       AND ss.start_date = NEW.start_date
       AND s.role = role_txt;

    IF role_txt = 'security'
       AND cnt + 1 < CEIL(cap * 0.05) THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Security staff below 5%';
    ELSEIF role_txt = 'support'
       AND cnt + 1 < CEIL(cap * 0.02) THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Support staff below 2%';
    END IF;
  END IF;
END$$
DELIMITER ;
