-- ===============================================
-- 1) Location
-- ===============================================
CREATE TABLE IF NOT EXISTS Location (
  location_id     INT            PRIMARY KEY,
  address         VARCHAR(255)   NOT NULL,
  city            VARCHAR(100)   NOT NULL,
  country         VARCHAR(100)   NOT NULL,
  continent       VARCHAR(50)    NOT NULL,
  coordinates     VARCHAR(50),
  location_image  VARCHAR(255)
);

-- ===============================================
-- 2) Festival
-- ===============================================
CREATE TABLE IF NOT EXISTS Festival (
  festival_id     INT            PRIMARY KEY,
  festival_name   VARCHAR(100)   NOT NULL,
  festival_year   YEAR           NOT NULL,
  start_date      DATE           NOT NULL,
  end_date        DATE           NOT NULL,
  location_id_FK  INT            NOT NULL,
  festival_image  VARCHAR(255),
  CONSTRAINT fk_festival_location
    FOREIGN KEY (location_id_FK) REFERENCES Location(location_id)
      ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ===============================================
-- 3) Stage
-- ===============================================
CREATE TABLE IF NOT EXISTS Stage (
  stage_id        INT            PRIMARY KEY,
  stage_name      VARCHAR(100)   NOT NULL,
  stage_description TEXT,
  capacity        INT            NOT NULL,
  tech_equipment  VARCHAR(255),
  stage_image     VARCHAR(255)
);

-- ===============================================
-- 4) Event
-- ===============================================
CREATE TABLE IF NOT EXISTS Event (
  event_id        INT            PRIMARY KEY,
  event_name      VARCHAR(100)   NOT NULL,
  festival_id_FK  INT            NOT NULL,
  stage_id_FK     INT            NOT NULL,
  event_date      DATE           NOT NULL,
  event_image     VARCHAR(255),
  CONSTRAINT fk_event_festival FOREIGN KEY (festival_id_FK)
    REFERENCES Festival(festival_id)
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_event_stage     FOREIGN KEY (stage_id_FK)
    REFERENCES Stage(stage_id)
      ON UPDATE CASCADE ON DELETE CASCADE,
  UNIQUE KEY uk_event_unique (festival_id_FK, stage_id_FK, event_date)
);



-- ===============================================
-- 5) Artist
-- ===============================================
CREATE TABLE IF NOT EXISTS Artist (
  artist_id       INT            PRIMARY KEY,
  name            VARCHAR(100)   NOT NULL,
  pseudonym       VARCHAR(50),
  birth_date      DATE           NOT NULL,
  music_genres    VARCHAR(50)    NOT NULL,
  music_subgenres VARCHAR(50),
  website         VARCHAR(255),
  instagram       VARCHAR(255),
  image_url       VARCHAR(255)
);

-- ===============================================
-- 6) Band
-- ===============================================
CREATE TABLE IF NOT EXISTS Band (
  band_id         INT            PRIMARY KEY,
  band_name       VARCHAR(100)   NOT NULL,
  formation_date  DATE           NOT NULL,
  music_genres    VARCHAR(50)    NOT NULL,
  music_subgenres VARCHAR(50),
  website         VARCHAR(255),
  instagram       VARCHAR(255),
  image_url       VARCHAR(255)
);

-- ===============================================
-- 7) Artist_Band (M:N)
-- ===============================================
CREATE TABLE IF NOT EXISTS Artist_Band (
  artist_id       INT            NOT NULL,
  band_id         INT            NOT NULL,
  join_date       DATE           NOT NULL,
  PRIMARY KEY (artist_id, band_id),
  CONSTRAINT fk_ab_artist FOREIGN KEY (artist_id)
    REFERENCES Artist(artist_id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_ab_band   FOREIGN KEY (band_id)
    REFERENCES Band(band_id)   ON UPDATE CASCADE ON DELETE CASCADE
);

-- ===============================================
-- 8) Performance
-- ===============================================
CREATE TABLE IF NOT EXISTS Performance (
  performance_id   INT            PRIMARY KEY,
  event_id_FK      INT            NOT NULL,
  performance_type VARCHAR(20)    NOT NULL,
  start_time       DATETIME       NOT NULL,
  duration_minutes INT            NOT NULL CHECK (duration_minutes <= 180),
  performance_image VARCHAR(255),
  CONSTRAINT fk_perf_event FOREIGN KEY (event_id_FK)
    REFERENCES Event(event_id) ON UPDATE CASCADE ON DELETE CASCADE,
  CHECK (performance_type IN (
    'warm up','headline','special guest','main act'
  ))
);


-- ===============================================
-- 9a) Performance_Artist
-- ===============================================
CREATE TABLE IF NOT EXISTS Performance_Artist (
  performance_id  INT            NOT NULL,
  artist_id       INT            NOT NULL,
  PRIMARY KEY (performance_id, artist_id),
  CONSTRAINT fk_pa_performance FOREIGN KEY (performance_id)
    REFERENCES Performance(performance_id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_pa_artist      FOREIGN KEY (artist_id)
    REFERENCES Artist(artist_id)      ON UPDATE CASCADE ON DELETE CASCADE
);


-- ===============================================
-- 9b) Performance_Band
-- ===============================================
CREATE TABLE IF NOT EXISTS Performance_Band (
  performance_id  INT            NOT NULL,
  band_id         INT            NOT NULL,
  PRIMARY KEY (performance_id, band_id),
  CONSTRAINT fk_pb_performance FOREIGN KEY (performance_id)
    REFERENCES Performance(performance_id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_pb_band        FOREIGN KEY (band_id)
    REFERENCES Band(band_id)           ON UPDATE CASCADE ON DELETE CASCADE
);

-- ===============================================
-- 10) Visitor
-- ===============================================
CREATE TABLE IF NOT EXISTS Visitor (
  visitor_id      INT            PRIMARY KEY,
  first_name      VARCHAR(50)    NOT NULL,
  last_name       VARCHAR(50)    NOT NULL,
  age             INT            NOT NULL CHECK(age >= 0),
  phone           VARCHAR(30),
  email           VARCHAR(100)
);

-- ===============================================
-- 11) Ticket
-- ===============================================
CREATE TABLE IF NOT EXISTS Ticket (
  ticket_id        INT            PRIMARY KEY,
  event_id_FK      INT            NOT NULL,
  visitor_id_FK    INT            NOT NULL,
  ticket_category  VARCHAR(20)    NOT NULL,
  purchase_date    DATETIME       NOT NULL,
  ticket_cost      DECIMAL(8,2)   NOT NULL CHECK(ticket_cost >= 0),
  purchase_method  VARCHAR(20)    NOT NULL,
  ean_code         CHAR(13)       NOT NULL UNIQUE,
  is_activated     BOOLEAN        NOT NULL DEFAULT FALSE,
  CONSTRAINT fk_ticket_event   FOREIGN KEY (event_id_FK)
    REFERENCES Event(event_id)     ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_ticket_visitor FOREIGN KEY (visitor_id_FK)
    REFERENCES Visitor(visitor_id) ON UPDATE CASCADE ON DELETE CASCADE,
  UNIQUE KEY uk_ticket_visitor_event (visitor_id_FK, event_id_FK),
  CHECK (ticket_category IN ('general','VIP','backstage')),
  CHECK (purchase_method IN (
    'credit_card','debit_card','bank_transfer','other'
  ))
);

-- ===============================================
-- 12) Staff
-- ===============================================
CREATE TABLE IF NOT EXISTS Staff (
  staff_id         INT            PRIMARY KEY,
  staff_name       VARCHAR(100)   NOT NULL,
  age              INT            NOT NULL CHECK(age >= 18),
  role             VARCHAR(20)    NOT NULL,
  experience_level VARCHAR(20)    NOT NULL,
  CHECK (role IN ('tech','security','support')),
  CHECK (experience_level IN (
    'intern','beginner','average','experienced','expert'
  ))
);

-- ===============================================
-- 13) Stage_Staff
-- ===============================================
CREATE TABLE IF NOT EXISTS Stage_Staff (
  stage_id        INT            NOT NULL,
  staff_id        INT            NOT NULL,
  start_date      DATE           NOT NULL,
  end_date        DATE           NOT NULL,
  PRIMARY KEY (stage_id, staff_id, start_date),
  CONSTRAINT fk_ss_stage  FOREIGN KEY (stage_id)
    REFERENCES Stage(stage_id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_ss_staff  FOREIGN KEY (staff_id)
    REFERENCES Staff(staff_id) ON UPDATE CASCADE ON DELETE CASCADE,
  CHECK (start_date <= end_date)
);


-- ===============================================
-- 14) Rating
-- ===============================================
CREATE TABLE IF NOT EXISTS Rating (
  rating_id               INT      PRIMARY KEY,
  visitor_id_FK           INT      NOT NULL,
  performance_id_FK       INT      NOT NULL,
  rating_interpretation   TINYINT  NOT NULL CHECK(rating_interpretation BETWEEN 1 AND 5),
  rating_sound_light      TINYINT  NOT NULL CHECK(rating_sound_light BETWEEN 1 AND 5),
  rating_stage_presence   TINYINT  NOT NULL CHECK(rating_stage_presence BETWEEN 1 AND 5),
  rating_organization     TINYINT  NOT NULL CHECK(rating_organization BETWEEN 1 AND 5),
  rating_overall          TINYINT  NOT NULL CHECK(rating_overall BETWEEN 1 AND 5),
  CONSTRAINT fk_rating_visitor     FOREIGN KEY (visitor_id_FK)
    REFERENCES Visitor(visitor_id)     ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_rating_performance FOREIGN KEY (performance_id_FK)
    REFERENCES Performance(performance_id)
      ON UPDATE CASCADE ON DELETE CASCADE,
  UNIQUE KEY uk_rating_visitor_perf (visitor_id_FK, performance_id_FK)
);


-- ===============================================
-- 15) Resale_queue
-- ===============================================
CREATE TABLE IF NOT EXISTS Resale_queue (
  resale_id      INT            PRIMARY KEY,
  ticket_id_FK   INT            NOT NULL,
  visitor_id_FK  INT            NOT NULL,
  interest_type  VARCHAR(10)    NOT NULL,
  interest_date  DATETIME       NOT NULL,
  CONSTRAINT fk_resale_ticket  FOREIGN KEY (ticket_id_FK)
    REFERENCES Ticket(ticket_id)   ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_resale_visitor FOREIGN KEY (visitor_id_FK)
    REFERENCES Visitor(visitor_id) ON UPDATE CASCADE ON DELETE CASCADE,
  CHECK (interest_type IN ('seller','buyer'))
);
