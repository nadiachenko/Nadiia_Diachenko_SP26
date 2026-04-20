
--REFINED MODEL CHANGE NOTES

--I. APPLIED CHANGES (BASED ON DB_HW FEEDBACK):

/*1.Membership_history and membership_type_history tables are merged*/
/*2.Expeditions and expeditions_history tables are merged*/
/*3.Competitions and competition_history are regrouped to competitions and competition_participants tables to track members/competitions/results*/


--II. RETAINED LOGIC (NO CHANGES APPLIED):

/*1.Expeditions and competition tables are kept in separate tables as they are different types of activities from business point of view.
    Expeditions are journeys, while competitions involve time-limited hiking along designated routes with awards.*/
/*2.Activity_groups and activity_group_members tables are kept to handle a Many-to-Many relationship and avoid duplicates if the business will scale:
    One Member can belong to multiple groups. One Group contains multiple members.*/
/*3.Expeditions-to-mountains relationships are not changed - multiple mountains may be visited in a single expedition
    Also, expeditions may be repeated, as the dataset grows, duplicates appear. For instance, a single expedition may visit 10 peaks, so we will need extra 9 records*/

--III. CHANGES REQUIRED TO COMPLETE PHYSICAL DB:

/*1.GENERATED ALWAYS AS IDENTITY is added to members(member_id), activity_groups(activity_group_id), membership_types(membership_type_id),
    competitions(competition_id), awards(award_id),instructors (instructor_id), expeditions (expedition_id), mountains (mountain_id) tables */
/*2.A unique constraint is added to membership_types table (member_id, membership_type_id, start_date)
    This will ensure that records are unique even if a member rejoins the club (different start_dates)*/
/*3.A unique constraint on (expedition_name, expedition_date) is added to expeditions table to ensure that one and only one ID is applied for every specific event.
    The same expedition may be repeated.*/
/*4.A unique constraint is added to competition table(competition_name, competition_date) to ensure that one and only one ID is applied for every specific event
    For instance, 'The Carpathian Peak Rush' competition may take place on "May 15, 2026" and "May 15, 2027."*/
/*5.A unique constraint is added to tne mountain_name to prevent similar records insertion*/
/*6. CHECK constraint is added to prevent negative values(expeditions(cost))*/

----CREATE STEP----

CREATE database mountaneering_club

CREATE SCHEMA m_club

CREATE TABLE m_club.members(
	member_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	member_first_name varchar(50) NOT NULL,
	member_last_name varchar(50) NOT NULL,
	email varchar(50) NOT NULL UNIQUE,
	phone varchar(50) NOT NULL,
	date_of_birth date CHECK (date_of_birth >= '2001-01-01'))

CREATE TABLE m_club.activity_groups(
	activity_group_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	group_name varchar(50) NOT NULL,
	description text)

CREATE TABLE m_club.activity_group_members(
	member_id INT NOT NULL REFERENCES m_club.members(member_id),
	activity_group_id INT NOT NULL REFERENCES m_club.activity_groups(activity_group_id),
	PRIMARY KEY (member_id, activity_group_id))

CREATE TABLE m_club.membership_types(
	membership_type_id INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
	type_name varchar(20) DEFAULT 'Beginner' CHECK (type_name IN ('Beginner','Advanced','Proficient')))

CREATE TABLE m_club.membership_history(
	membership_id INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
	member_id INT NOT NULL  REFERENCES m_club.members(member_id),
	membership_type_id INT NOT NULL REFERENCES m_club.membership_types(membership_type_id ),
	start_date DATE NOT NULL,
	end_date DATE, 
	CONSTRAINT unique_member_type_date UNIQUE (member_id, membership_type_id, start_date))

CREATE TABLE m_club.competitions (
    competition_id INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    competition_name VARCHAR(255) NOT NULL,
    competition_date DATE NOT NULL,
    description TEXT,
    location VARCHAR(255),
    CONSTRAINT unique_competitions UNIQUE (competition_name, competition_date))

CREATE TABLE m_club.awards (
    award_id INT GENERATED ALWAYS AS IDENTITY  NOT NULL PRIMARY KEY,
    award_name VARCHAR(20) CHECK (award_name IN ('Gold', 'Silver', 'Bronze')))

CREATE TABLE m_club.competition_participants (
    competition_id INT NOT NULL REFERENCES m_club.competitions(competition_id),
    member_id INT NOT NULL REFERENCES m_club.members(member_id),
    award_id INT REFERENCES m_club.awards(award_id),
    PRIMARY KEY (competition_id, member_id))

CREATE TABLE m_club.instructors (
    instructor_id INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    instructor_first_name VARCHAR(50) NOT NULL,
    instructor_last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(50) NOT NULL)

CREATE TABLE m_club.expeditions (
    expedition_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    expedition_name VARCHAR(255) NOT NULL,
    expedition_date DATE NOT NULL,
    activity_group_id INT NOT NULL REFERENCES m_club.activity_groups(activity_group_id),
    cost DECIMAL(10,2) CHECK (cost >= 0),
    difficulty_level VARCHAR(20) CHECK (difficulty_level IN ('easy', 'medium', 'hard')),
    instructor_id INT NOT NULL REFERENCES m_club.instructors(instructor_id),
    CONSTRAINT unique_expeditions UNIQUE (expedition_name, expedition_date))

CREATE TABLE m_club.mountains (
    mountain_id INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    mountain_name VARCHAR(255) NOT NULL,
    region VARCHAR(255),
    description TEXT,
    height_m INT,
    winter_trips_mountain BOOLEAN,
    special_equipment_required BOOLEAN)

CREATE TABLE m_club.expedition_mountains (
    expedition_id INT NOT NULL REFERENCES m_club.expeditions(expedition_id),
    mountain_id INT NOT NULL REFERENCES m_club.mountains(mountain_id),
    PRIMARY KEY (expedition_id, mountain_id))

----INSERT STEP----
    
INSERT INTO m_club.members (member_first_name, member_last_name, email, phone, date_of_birth)
VALUES 
('Ivan', 'Petrenko', 'ivan.p@email.com', '+380501112233', '2001-05-12'),
('Olena', 'Zhuravlova', 'olena.z@email.com', '+380674445566', '2002-11-20')
ON CONFLICT DO NOTHING

INSERT INTO m_club.activity_groups(group_name, description)
VALUES ('Rock Climbing', 'Focuses on technical bouldering and sport climbing.'),
('Alpine Mountaineering', 'High-altitude expeditions involving ice and snow.')
ON CONFLICT DO NOTHING

INSERT INTO m_club.activity_group_members (activity_group_id, member_id)
SELECT activity_group_id, member_id
FROM m_club.activity_groups ag 
INNER JOIN m_club.members  m
ON (activity_group_id = 1  AND member_id = 2)
    OR (activity_group_id = 1  AND member_id = 1)
    OR (activity_group_id = 2  AND member_id = 2)
WHERE NOT EXISTS (SELECT *
FROM m_club.activity_group_members mag
WHERE mag.activity_group_id  = ag.activity_group_id 
AND mag.member_id = m.member_id)    
    
INSERT INTO m_club.membership_types(type_name)
VALUES ('Beginner'), ('Advanced'), ('Proficient')
ON CONFLICT DO NOTHING

INSERT INTO m_club.membership_history (member_id, membership_type_id, start_date)
SELECT member_id, membership_type_id, current_date
FROM m_club.members m
INNER JOIN m_club.membership_types t
ON (m.email = 'olena.z@email.com'  AND t.type_name = 'Beginner')
    OR (m.email = 'ivan.p@email.com'  AND t.type_name = 'Beginner')
ON conflict(member_id, membership_type_id, start_date) DO NOTHING

INSERT INTO m_club.competitions (competition_name, competition_date, description, location)
VALUES 
('Carpathian Peak Rush', '2026-05-15', 'Annual vertical kilometer race starting from the base camp.', 'Mount Hoverla, Ukraine'),
('Winter Ice Master', '2026-02-10', 'Technical ice climbing competition for advanced members.', 'Yaremche Ice Falls, Ukraine')
ON CONFLICT (competition_name, competition_date) DO NOTHING

INSERT INTO m_club.awards (award_name)
VALUES ('Gold'), ('Silver'), ('Bronze')

INSERT INTO m_club.competition_participants (competition_id, member_id, award_id)
SELECT c.competition_id, m.member_id, a.award_id
FROM m_club.competitions c
JOIN m_club.members m 
ON m.email IN ('olena.z@email.com', 'ivan.p@email.com')
JOIN m_club.awards a 
ON a.award_name = 'Silver'
WHERE c.competition_name = 'Carpathian Peak Rush' 
AND c.competition_date = '2026-05-15'
ON CONFLICT (competition_id, member_id) DO NOTHING

INSERT INTO m_club.instructors (instructor_first_name, instructor_last_name, email, phone)
VALUES('Viktor', 'Kovalenko', 'v.kovalenko@m_club.ua', '+380-50-123-4567'),
('Olena', 'Petrenko', 'o.petrenko@m_club.ua', '+380-67-987-6543')
ON CONFLICT DO NOTHING

INSERT INTO m_club.expeditions (expedition_name, expedition_date, activity_group_id, cost, difficulty_level, instructor_id)
SELECT 'Hoverla Sunrise Trek', '2026-06-20', ag.activity_group_id, 1500.00, 'medium', i.instructor_id
FROM m_club.activity_groups ag
INNER JOIN m_club.instructors i 
ON ag.group_name = 'Alpine Mountaineering' 
   AND i.email = 'v.kovalenko@m_club.ua'
ON CONFLICT DO NOTHING

INSERT INTO m_club.mountains (mountain_name, region, description, height_m, winter_trips_mountain, special_equipment_required)
VALUES 
('Hoverla', 'Chornohora', 'The highest peak in Ukraine, a popular destination for hikers.', 2061, TRUE, FALSE),
('Pip Ivan', 'Chornohora', 'Known for the "White Elephant" observatory at the summit.', 2022, TRUE, TRUE)
ON CONFLICT DO NOTHING

INSERT INTO m_club.expedition_mountains (expedition_id, mountain_id)
SELECT e.expedition_id, m.mountain_id
FROM m_club.expeditions e
INNER JOIN m_club.mountains m
on e.expedition_name = 'Hoverla Sunrise Trek' AND e.expedition_date = '2026-06-20' AND m.mountain_name = 'Hoverla'
or e.expedition_name = 'Hoverla Sunrise Trek' AND e.expedition_date = '2026-06-20' AND m.mountain_name = 'Pip Ivan'

----ALTER STEP----

ALTER TABLE m_club.members ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE;
ALTER TABLE m_club.membership_types ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE;
ALTER TABLE m_club.membership_history ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE;
ALTER TABLE m_club.activity_groups ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE;
ALTER TABLE m_club.activity_group_members ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE;
ALTER TABLE m_club.competitions ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE;
ALTER TABLE m_club.awards ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE;
ALTER TABLE m_club.competition_participants ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE;
ALTER TABLE m_club.instructors ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE;
ALTER TABLE m_club.expeditions ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE;
ALTER TABLE m_club.mountains ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE;
ALTER TABLE m_club.expedition_mountains ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE;

