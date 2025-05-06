-- sql/load.sql

-- 1) Turn off foreign key checks so we can truncate in any order
SET FOREIGN_KEY_CHECKS = 0;

-- 2) Truncate all tables
TRUNCATE TABLE Resale_queue;
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

-- 3) Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- 4) Dynamically drop any CHECK constraint on Staff.experience
--    (works regardless of the constraint's auto-generated name)
SELECT CONSTRAINT_NAME
  INTO @cn
  FROM information_schema.TABLE_CONSTRAINTS
 WHERE TABLE_SCHEMA = DATABASE()
   AND TABLE_NAME   = 'Staff'
   AND CONSTRAINT_TYPE = 'CHECK'
 LIMIT 1;

SET @sql = CONCAT('ALTER TABLE Staff DROP CHECK ', @cn);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 5) Bulk load CSV files

/* Location */
LOAD DATA INFILE '/var/lib/mysql-files/Location.csv'
INTO TABLE Location
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(location_id, address, city, country, continent, coordinates, location_image);

/* Festival */
LOAD DATA INFILE '/var/lib/mysql-files/Festival.csv'
INTO TABLE Festival
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(festival_id, festival_name, festival_year, start_date, end_date, location_id_FK, festival_image);

/* Stage */
LOAD DATA INFILE '/var/lib/mysql-files/Stage.csv'
INTO TABLE Stage
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(stage_id, stage_name, stage_description, capacity, tech_equipment, stage_image);

/* Event */
LOAD DATA INFILE '/var/lib/mysql-files/Event.csv'
INTO TABLE Event
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(event_id, event_name, festival_id_FK, stage_id_FK, event_start, event_end, event_image);

/* Artist */
LOAD DATA INFILE '/var/lib/mysql-files/Artist.csv'
INTO TABLE Artist
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(artist_id, name, pseudonym, birth_date, main_genre, sub_genre, website, instagram, image_url);

/* Band */
LOAD DATA INFILE '/var/lib/mysql-files/Band.csv'
INTO TABLE Band
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(band_id, band_name, formation_date, website, instagram, image_url);

/* Artist_Band */
LOAD DATA INFILE '/var/lib/mysql-files/Artist_Band.csv'
INTO TABLE Artist_Band
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(artist_id, band_id, join_date);

/* Performance */
LOAD DATA INFILE '/var/lib/mysql-files/Performance.csv'
INTO TABLE Performance
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(performance_id, event_id_FK, performance_type, start_time, duration_minutes, performance_image);

/* Performance_Artist */
LOAD DATA INFILE '/var/lib/mysql-files/Performance_Artist.csv'
INTO TABLE Performance_Artist
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(performance_id, artist_id);

/* Performance_Band */
LOAD DATA INFILE '/var/lib/mysql-files/Performance_Band.csv'
INTO TABLE Performance_Band
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(performance_id, band_id);

/* Visitor */
LOAD DATA INFILE '/var/lib/mysql-files/Visitor.csv'
INTO TABLE Visitor
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(visitor_id, first_name, last_name, age, phone, email);

/* Ticket */
LOAD DATA INFILE '/var/lib/mysql-files/Ticket.csv'
INTO TABLE Ticket
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(ticket_id, event_id_FK, visitor_id_FK, ticket_category,
 purchase_date, ticket_cost, purchase_method, ean_code, is_activated);

/* Staff */
LOAD DATA INFILE '/var/lib/mysql-files/Staff.csv'
INTO TABLE Staff
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(staff_id, staff_name, age, role, experience);

/* Stage_Staff */
SET @bulk_load = 1;
LOAD DATA INFILE '/var/lib/mysql-files/Stage_Staff.csv'
INTO TABLE Stage_Staff
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(stage_id, staff_id, start_date, end_date);
SET @bulk_load = NULL;

/* Rating */
LOAD DATA INFILE '/var/lib/mysql-files/Rating.csv'
INTO TABLE Rating
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(rating_id, visitor_id_FK, performance_id_FK,
 rating_interpretation, rating_sound_light,
 rating_stage_presence, rating_organization, rating_overall);

/* Resale_queue */
LOAD DATA INFILE '/var/lib/mysql-files/Resale_queue.csv'
INTO TABLE Resale_queue
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(resale_id, ticket_id_FK, visitor_id_FK, interest_type, interest_date);
