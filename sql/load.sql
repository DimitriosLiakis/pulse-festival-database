SET FOREIGN_KEY_CHECKS=0;
TRUNCATE TABLE Resale_queue; TRUNCATE TABLE Rating;
TRUNCATE TABLE Stage_Staff;     TRUNCATE TABLE Staff;
TRUNCATE TABLE Ticket;          TRUNCATE TABLE Visitor;
TRUNCATE TABLE Performance_Artist; TRUNCATE TABLE Performance_Band;
TRUNCATE TABLE Performance;     TRUNCATE TABLE Artist_Band;
TRUNCATE TABLE Band;            TRUNCATE TABLE Artist;
TRUNCATE TABLE Event;           TRUNCATE TABLE Stage;
TRUNCATE TABLE Festival;        TRUNCATE TABLE Location;
SET FOREIGN_KEY_CHECKS=1;

/* Location */
LOAD DATA INFILE '/var/lib/mysql-files/Location.csv'
INTO TABLE Location
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(location_id,address,city,country,continent,coordinates,location_image);

/* Festival */
LOAD DATA INFILE '/var/lib/mysql-files/Festival.csv'
INTO TABLE Festival
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(festival_id,festival_name,festival_year,start_date,end_date,location_id_FK,festival_image);

/* Stage */
LOAD DATA INFILE '/var/lib/mysql-files/Stage.csv'
INTO TABLE Stage
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(stage_id,stage_name,stage_description,capacity,tech_equipment,stage_image);

/* Event */
LOAD DATA INFILE '/var/lib/mysql-files/Event.csv'
INTO TABLE Event
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(event_id,event_name,festival_id_FK,stage_id_FK,event_start,event_end,event_image);

/* Artist */
LOAD DATA INFILE '/var/lib/mysql-files/Artist.csv'
INTO TABLE Artist
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(artist_id,name,pseudonym,birth_date,main_genre,sub_genre,website,instagram,image_url);

/* Band */
LOAD DATA INFILE '/var/lib/mysql-files/Band.csv'
INTO TABLE Band
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(band_id,band_name,formation_date,website,instagram,image_url);

/* Artist_Band */
LOAD DATA INFILE '/var/lib/mysql-files/Artist_Band.csv'
INTO TABLE Artist_Band
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(artist_id,band_id,join_date);

/* Performance */
LOAD DATA INFILE '/var/lib/mysql-files/Performance.csv'
INTO TABLE Performance
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(performance_id,event_id_FK,@ptype,start_time,duration_minutes,performance_image)
SET performance_type_id=(SELECT performance_type_id FROM Performance_type WHERE description=@ptype);

/* Performance_Artist / Band */
LOAD DATA INFILE '/var/lib/mysql-files/Performance_Artist.csv'
INTO TABLE Performance_Artist
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(performance_id,artist_id);

LOAD DATA INFILE '/var/lib/mysql-files/Performance_Band.csv'
INTO TABLE Performance_Band
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(performance_id,band_id);

/* Visitor */
LOAD DATA INFILE '/var/lib/mysql-files/Visitor.csv'
INTO TABLE Visitor
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(visitor_id,first_name,last_name,age,phone,email);

/* Ticket */
LOAD DATA INFILE '/var/lib/mysql-files/Ticket.csv'
INTO TABLE Ticket
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(ticket_id,event_id_FK,visitor_id_FK,@tcat,purchase_date,ticket_cost,@pm,ean_code,is_activated)
SET ticket_cat_id       = COALESCE((SELECT ticket_cat_id       FROM Ticket_category WHERE description=@tcat),1),
    purchase_method_id  = COALESCE((SELECT purchase_method_id FROM Purchase_method   WHERE description=@pm),1);

/* Staff */
LOAD DATA INFILE '/var/lib/mysql-files/Staff.csv'
INTO TABLE Staff
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(staff_id,staff_name,age,@role,@exp)
SET role_id = COALESCE((SELECT staff_role_id FROM Staff_role       WHERE description=TRIM(@role)),1),
    exp_id  = COALESCE((SELECT staff_exp_id  FROM Staff_experience WHERE description=TRIM(@exp)),1);

/* Stage_Staff */
SET @bulk_load := 1;
LOAD DATA INFILE '/var/lib/mysql-files/Stage_Staff.csv'
INTO TABLE Stage_Staff
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(stage_id,staff_id,start_date,end_date);
SET @bulk_load := NULL;

/* Rating */
LOAD DATA INFILE '/var/lib/mysql-files/Rating.csv'
INTO TABLE Rating
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(rating_id,visitor_id_FK,performance_id_FK,rating_interpretation,rating_sound_light,
 rating_stage_presence,rating_organization,rating_overall);

/* Resale_queue */
LOAD DATA INFILE '/var/lib/mysql-files/Resale_queue.csv'
INTO TABLE Resale_queue
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(resale_id,ticket_id_FK,visitor_id_FK,@itype,interest_date)
SET interest_type_id=COALESCE((SELECT interest_type_id FROM Interest_type WHERE description=TRIM(@itype)),1);
