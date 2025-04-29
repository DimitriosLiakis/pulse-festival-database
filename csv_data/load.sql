-- load.sql: bulk data load for pulse_university

-- 1. Disable foreign‐key checks to allow truncation in any order
SET FOREIGN_KEY_CHECKS = 0;

-- 2. Truncate all tables to clear existing data
TRUNCATE TABLE Resale_Queue;
TRUNCATE TABLE Rating;
TRUNCATE TABLE Stage_Staff;
TRUNCATE TABLE Staff;
TRUNCATE TABLE Ticket;
TRUNCATE TABLE Visitor;
TRUNCATE TABLE Performance_Artist;
TRUNCATE TABLE Performance_Band;
TRUNCATE TABLE Performance;
TRUNCATE TABLE Artist_Band;
TRUNCATE TABLE Band;
TRUNCATE TABLE Artist;
TRUNCATE TABLE Event;
TRUNCATE TABLE Stage;
TRUNCATE TABLE Festival;
TRUNCATE TABLE Location;

-- 3. Re‐enable foreign‐key checks
SET FOREIGN_KEY_CHECKS = 1;

-- 4. Load CSV data from secure import directory
LOAD DATA INFILE '/var/lib/mysql-files/Location.csv'
INTO TABLE Location
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(location_id, address, city, country, continent, coordinates, location_image);

LOAD DATA INFILE '/var/lib/mysql-files/Festival.csv'
INTO TABLE Festival
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(festival_id, festival_name, festival_year, start_date, end_date, location_id_FK, festival_image);

LOAD DATA INFILE '/var/lib/mysql-files/Stage.csv'
INTO TABLE Stage
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(stage_id, stage_name, stage_description, capacity, tech_equipment, stage_image);

LOAD DATA INFILE '/var/lib/mysql-files/Event.csv'
INTO TABLE Event
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(event_id, event_name, festival_id_FK, stage_id_FK, event_date, event_image);

LOAD DATA INFILE '/var/lib/mysql-files/Artist.csv'
INTO TABLE Artist
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(artist_id, name, pseudonym, birth_date, music_genres, music_subgenres, website, instagram, image_url);

LOAD DATA INFILE '/var/lib/mysql-files/Band.csv'
INTO TABLE Band
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(band_id, band_name, formation_date, music_genres, music_subgenres, website, instagram, image_url);

LOAD DATA INFILE '/var/lib/mysql-files/Artist_Band.csv'
INTO TABLE Artist_Band
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(artist_id, band_id, join_date);

LOAD DATA INFILE '/var/lib/mysql-files/Performance.csv'
INTO TABLE Performance
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(performance_id, event_id_FK, performance_type, start_time, duration_minutes, performance_image);

LOAD DATA INFILE '/var/lib/mysql-files/Performance_Artist.csv'
INTO TABLE Performance_Artist
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(performance_id, artist_id);

LOAD DATA INFILE '/var/lib/mysql-files/Performance_Band.csv'
INTO TABLE Performance_Band
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(performance_id, band_id);

LOAD DATA INFILE '/var/lib/mysql-files/Visitor.csv'
INTO TABLE Visitor
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(visitor_id, first_name, last_name, age, phone, email);

-- Ticket: map 'true'/'false' to boolean
LOAD DATA INFILE '/var/lib/mysql-files/Ticket.csv'
INTO TABLE Ticket
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(ticket_id, event_id_FK, visitor_id_FK, ticket_category, purchase_date, ticket_cost, purchase_method, ean_code, @ia)
SET is_activated = IF(LOWER(TRIM(@ia))='true',1,0);

-- Staff: normalize experience_level
LOAD DATA INFILE '/var/lib/mysql-files/Staff.csv'
INTO TABLE Staff
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(staff_id, staff_name, age, role, @exp)
SET experience_level = CASE LOWER(TRIM(@exp))
  WHEN 'intern'      THEN 'intern'
  WHEN 'beginner'    THEN 'beginner'
  WHEN 'average'     THEN 'average'
  WHEN 'experienced' THEN 'experienced'
  WHEN 'expert'      THEN 'expert'
  ELSE 'average'
END;

LOAD DATA INFILE '/var/lib/mysql-files/Stage_Staff.csv'
INTO TABLE Stage_Staff
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(stage_id, staff_id, start_date, end_date);

LOAD DATA INFILE '/var/lib/mysql-files/Rating.csv'
INTO TABLE Rating
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(rating_id, visitor_id_FK, performance_id_FK, rating_interpretation, rating_sound_light, rating_stage_presence, rating_organization, rating_overall);

LOAD DATA INFILE '/var/lib/mysql-files/Resale_queue.csv'
INTO TABLE Resale_Queue
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(resale_id, ticket_id_FK, visitor_id_FK, interest_type, interest_date);
