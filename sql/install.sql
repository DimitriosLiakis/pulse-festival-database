    -- 1) LOCATION
    CREATE TABLE Location (
    location_id    INT            PRIMARY KEY,
    address        VARCHAR(255)   NOT NULL,
    city           VARCHAR(100)   NOT NULL,
    country        VARCHAR(100)   NOT NULL,
    continent      VARCHAR(50)    NOT NULL,
    coordinates    VARCHAR(50)    NOT NULL,
    location_image VARCHAR(255)
    );

    -- 2) FESTIVAL
    CREATE TABLE Festival (
    festival_id     INT            PRIMARY KEY,
    festival_name   VARCHAR(100)   NOT NULL,
    festival_year   INT            NOT NULL,
    start_date      DATE           NOT NULL,
    end_date        DATE           NOT NULL,
    location_id_FK  INT            NOT NULL,
    festival_image  VARCHAR(255),
    FOREIGN KEY (location_id_FK)
        REFERENCES Location(location_id)
    );

    -- 3) STAGE
    CREATE TABLE Stage (
    stage_id          INT         PRIMARY KEY,
    stage_name        VARCHAR(100) NOT NULL,
    stage_description TEXT        NOT NULL,
    capacity          INT         NOT NULL,
    tech_equipment    VARCHAR(255) NOT NULL,
    stage_image       VARCHAR(255)
    );

    -- 4) EVENT
    CREATE TABLE Event (
    event_id        INT          PRIMARY KEY,
    event_name      VARCHAR(100) NOT NULL,
    festival_id_FK  INT          NOT NULL,
    stage_id_FK     INT          NOT NULL,
    event_date      DATE         NOT NULL,
    event_image     VARCHAR(255),
    FOREIGN KEY (festival_id_FK)
        REFERENCES Festival(festival_id),
    FOREIGN KEY (stage_id_FK)
        REFERENCES Stage(stage_id)
    );

    -- 5) ARTIST
    CREATE TABLE Artist (
    artist_id        INT            PRIMARY KEY,
    name             VARCHAR(100)   NOT NULL,
    pseudonym        VARCHAR(100),
    birth_date       DATE           NOT NULL,
    music_genres     VARCHAR(50),    -- added to match CSV
    music_subgenres  VARCHAR(50),    -- added to match CSV
    website          VARCHAR(255),
    instagram        VARCHAR(255),
    image_url        VARCHAR(255)
    );

    -- 6) BAND
    CREATE TABLE Band (
    band_id         INT            PRIMARY KEY,
    band_name       VARCHAR(100)   NOT NULL,
    formation_date  DATE           NOT NULL,
    music_genres    VARCHAR(50),    -- added to match CSV
    music_subgenres VARCHAR(50),    -- added to match CSV
    website         VARCHAR(255),
    instagram       VARCHAR(255),
    image_url       VARCHAR(255)
    );

    -- 7) ARTIST_BAND (M:N)
    CREATE TABLE Artist_Band (
    artist_id  INT NOT NULL,
    band_id    INT NOT NULL,
    join_date  DATE NOT NULL,
    PRIMARY KEY (artist_id, band_id),
    FOREIGN KEY (artist_id)
        REFERENCES Artist(artist_id),
    FOREIGN KEY (band_id)
        REFERENCES Band(band_id)
    );

    -- 8) PERFORMANCE
    CREATE TABLE Performance (
    performance_id    INT        PRIMARY KEY,
    event_id_FK       INT        NOT NULL,
    performance_type  VARCHAR(50) NOT NULL,
    start_time        DATETIME   NOT NULL,
    duration_minutes  INT        NOT NULL,
    performance_image VARCHAR(255),
    FOREIGN KEY (event_id_FK)
        REFERENCES Event(event_id)
    );

    -- 9a) PERFORMANCE_ARTIST (M:N)
    CREATE TABLE Performance_Artist (
    performance_id  INT NOT NULL,
    artist_id       INT NOT NULL,
    PRIMARY KEY (performance_id, artist_id),
    FOREIGN KEY (performance_id)
        REFERENCES Performance(performance_id),
    FOREIGN KEY (artist_id)
        REFERENCES Artist(artist_id)
    );

    -- 9b) PERFORMANCE_BAND (M:N)
    CREATE TABLE Performance_Band (
    performance_id  INT NOT NULL,
    band_id         INT NOT NULL,
    PRIMARY KEY (performance_id, band_id),
    FOREIGN KEY (performance_id)
        REFERENCES Performance(performance_id),
    FOREIGN KEY (band_id)
        REFERENCES Band(band_id)
    );

    -- 10) VISITOR
    CREATE TABLE Visitor (
    visitor_id INT          PRIMARY KEY,
    first_name VARCHAR(50)  NOT NULL,
    last_name  VARCHAR(50)  NOT NULL,
    age        INT          NOT NULL,
    phone      VARCHAR(50),
    email      VARCHAR(100) UNIQUE
    );

    -- 11) TICKET
    CREATE TABLE Ticket (
    ticket_id       INT            PRIMARY KEY,
    event_id_FK     INT            NOT NULL,
    visitor_id_FK   INT            NOT NULL,
    ticket_category ENUM('general','VIP','backstage') NOT NULL,
    purchase_date   DATETIME       NOT NULL,
    ticket_cost     DECIMAL(10,2)  NOT NULL,
    purchase_method ENUM('credit_card','debit_card','bank_transfer','other') NOT NULL,
    ean_code        CHAR(13)       NOT NULL UNIQUE,
    is_activated    BOOLEAN        NOT NULL,
    FOREIGN KEY (event_id_FK)
        REFERENCES Event(event_id),
    FOREIGN KEY (visitor_id_FK)
        REFERENCES Visitor(visitor_id)
    );

    -- 12) STAFF
    CREATE TABLE Staff (
    staff_id         INT          PRIMARY KEY,
    staff_name       VARCHAR(100) NOT NULL,
    age              INT          NOT NULL,
    role             ENUM('tech','security','support') NOT NULL,
    experience_level ENUM('intern','beginner','average','experienced','expert') NOT NULL
    );

    -- 13) STAGE_STAFF
    CREATE TABLE Stage_Staff (
    stage_id   INT    NOT NULL,
    staff_id   INT    NOT NULL,
    start_date DATE   NOT NULL,
    end_date   DATE   NOT NULL,
    PRIMARY KEY (stage_id, staff_id, start_date),
    FOREIGN KEY (stage_id)
        REFERENCES Stage(stage_id),
    FOREIGN KEY (staff_id)
        REFERENCES Staff(staff_id)
    );

    -- 14) RATING
    CREATE TABLE Rating (
    rating_id             INT   PRIMARY KEY,
    visitor_id_FK         INT   NOT NULL,
    performance_id_FK     INT   NOT NULL,
    rating_interpretation TINYINT NOT NULL CHECK (rating_interpretation BETWEEN 1 AND 5),
    rating_sound_light    TINYINT NOT NULL CHECK (rating_sound_light BETWEEN 1 AND 5),
    rating_stage_presence TINYINT NOT NULL CHECK (rating_stage_presence BETWEEN 1 AND 5),
    rating_organization   TINYINT NOT NULL CHECK (rating_organization BETWEEN 1 AND 5),
    rating_overall        TINYINT NOT NULL CHECK (rating_overall BETWEEN 1 AND 5),
    FOREIGN KEY (visitor_id_FK)
        REFERENCES Visitor(visitor_id),
    FOREIGN KEY (performance_id_FK)
        REFERENCES Performance(performance_id)
    );

    -- 15) RESALE_QUEUE
    CREATE TABLE Resale_Queue (
    resale_id     INT            PRIMARY KEY,
    ticket_id_FK  INT            NOT NULL,
    visitor_id_FK INT            NOT NULL,
    interest_type ENUM('seller','buyer') NOT NULL,
    interest_date DATETIME       NOT NULL,
    FOREIGN KEY (ticket_id_FK)
        REFERENCES Ticket(ticket_id),
    FOREIGN KEY (visitor_id_FK)
        REFERENCES Visitor(visitor_id)
    );
