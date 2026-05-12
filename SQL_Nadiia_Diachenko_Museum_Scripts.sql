
-- GENERAL DESCRIPTION AND NOTES--

/* The database consist of 7 tables : 
* Staff – represents employees of the museum. Employees have roles (Curator, Security, Facilities Manager, Admin). Based on roles staff may be responsible for collections, exhibitions, or storage facilities.
Tables creation is started from the staff table, as three of the next tables are depend on it.
 
* Storage – reflects storage locations within the museum. Each storage unit is managed by a staff and stores one collection only.

* Collections – logical groupings of artefacts. Each collection is managed by a curator responsible for its content.

* Items – individual museum objects or artifacts. Each item belongs to a one collection and contains descriptive information, acquisition date, and current status (e.g., displayed, stored, under repair).

* Exhibitions – represents museum exhibitions or events. Includes details such as name, duration, ticket cost, format (offline/online), and the responsible staff member. End date of the exhibition may be NULL as there is ongoing and permanent exhibitions.

* Exhibition_items – associative table linking items to exhibitions. Tracks which items are displayed in which exhibitions.

* Visits – represents visitor activity for exhibitions. This is transaction table. From the 'business' perspective there is no need to identify each visitor, so the table reflects only total_amount of the cost and quantity of the visitors for analytics. Date limitations are added (greater than January 1, 2026) 

*There may be confusion regarding the need for a separate STORAGE table since each storage hosts only one collection. The purpose of separate tables is to reflect different staff roles (STAFF table. The staff member responsible for a COLLECTION (overseeing items, history, curation) is a different person than the one responsible for the STORAGE facility (overseeing physical security, climate control).*/ 

-----Database creation----
CREATE database museum;

-----Schema creation----
CREATE SCHEMA core;

-----Tables creation----
CREATE TABLE core.staff (
    staff_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    staff_first_name VARCHAR(50) NOT NULL,
    staff_last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    role VARCHAR(50) NOT NULL);

CREATE TABLE core.storage (
    storage_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    location VARCHAR(255) NOT NULL,
    responsible_staff_id INT NOT NULL REFERENCES core.staff(staff_id));

CREATE TABLE core.collections (
    collection_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    collection_name VARCHAR(255) NOT NULL,
    description TEXT,
    storage_id INT NOT NULL REFERENCES core.storage(storage_id),
    responsible_staff_id INT NOT NULL REFERENCES core.staff(staff_id));

CREATE TABLE core.items (
    item_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    item_name VARCHAR(255) NOT NULL,
    collection_id INT NOT NULL REFERENCES core.collections(collection_id),
    description TEXT,
    date_received DATE NOT NULL,
    item_status VARCHAR(20) NOT NULL);

CREATE TABLE core.exhibitions (
    exhibition_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    exhibition_name VARCHAR(255) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    ticket_cost DECIMAL(10,2),
    is_offline BOOLEAN,
    responsible_staff_id INT NOT NULL REFERENCES core.staff(staff_id));

CREATE TABLE core.exhibition_items (
    item_id INT NOT NULL REFERENCES core.items(item_id),
    exhibition_id INT NOT NULL REFERENCES core.exhibitions(exhibition_id),
    PRIMARY KEY (item_id, exhibition_id));

CREATE TABLE core.visits (
    visit_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    exhibition_id INT NOT NULL REFERENCES core.exhibitions(exhibition_id),
    total_amount DECIMAL(10,2) NOT NULL,
    visitors_quantity INT NOT NULL,
    visit_date DATE NOT NULL,
    visit_email VARCHAR(255) NOT NULL);

-----Adding constrains----

ALTER TABLE core.staff
ADD CONSTRAINT unique_email UNIQUE (email);

ALTER TABLE core.staff
ADD CONSTRAINT staff_roles CHECK (role IN ('Security','Curator', 'Facilities Manager', 'Admin'));

ALTER TABLE core.storage
ADD CONSTRAINT unique_storage UNIQUE (location);

ALTER TABLE core.collections 
ADD CONSTRAINT unique_collection_storage UNIQUE (storage_id);

ALTER TABLE core.collections 
ADD CONSTRAINT unique_collection_name UNIQUE (collection_name);

ALTER TABLE core.items 
ADD CONSTRAINT unique_item_name UNIQUE (item_name);

ALTER TABLE core.items 
ADD CONSTRAINT chk_item_status_values CHECK (item_status IN ('Displayed', 'Stored', 'Under Repair'));

ALTER TABLE core.exhibitions 
ADD CONSTRAINT unique_exhibitions UNIQUE (exhibition_name);

ALTER TABLE core.exhibitions 
ALTER COLUMN is_offline SET DEFAULT TRUE;

ALTER TABLE core.exhibitions 
ADD CONSTRAINT exhibition_dates CHECK (end_date IS NULL OR end_date > start_date);

ALTER TABLE core.visits 
ADD CONSTRAINT visit_date_limitation CHECK(visit_date> '2026-01-01');

ALTER TABLE core.visits 
ADD CONSTRAINT unique_visit_email UNIQUE (visit_email);

-----Data insertion----

INSERT INTO core.staff (staff_first_name, staff_last_name, email, phone, role)
VALUES 
('Alice', 'Vance', 'a.vance@museum.com', '555-0101', 'Curator'),
('Bob', 'Miller', 'b.miller@museum.com', '555-0102', 'Facilities Manager'),
('Charlie', 'Davis', 'c.davis@museum.com', '555-0103', 'Curator'),
('Diana', 'Prince', 'd.prince@museum.com', '555-0104', 'Security'),
('Edward', 'Norton', 'e.norton@museum.com', '555-0105', 'Curator'),
('Fiona', 'Gallagher', 'f.gallagher@museum.com', '555-0106', 'Admin')
ON CONFLICT DO NOTHING;

INSERT INTO core.storage (location, responsible_staff_id)
VALUES 
('Vault Alpha', (SELECT staff_id FROM core.staff WHERE email = 'b.miller@museum.com')),
('Climate Room 1', (SELECT staff_id FROM core.staff WHERE email = 'b.miller@museum.com')),
('Secure Basement', (SELECT staff_id FROM core.staff WHERE email = 'd.prince@museum.com')),
('North Wing Safe', (SELECT staff_id FROM core.staff WHERE email = 'b.miller@museum.com')),
('Archive Hall', (SELECT staff_id FROM core.staff WHERE email = 'b.miller@museum.com')),
('Restoration Lab', (SELECT staff_id FROM core.staff WHERE email = 'd.prince@museum.com'))
ON CONFLICT DO NOTHING;

INSERT INTO core.collections (collection_name, description, storage_id, responsible_staff_id)
VALUES 
('Ancient Egypt', 'Pharaonic artifacts', (SELECT storage_id FROM core.storage WHERE location = 'Vault Alpha'), (SELECT staff_id FROM core.staff WHERE email = 'a.vance@museum.com')),
('Impressionism', '19th century paintings', (SELECT storage_id FROM core.storage WHERE location = 'Climate Room 1'), (SELECT staff_id FROM core.staff WHERE email = 'c.davis@museum.com')),
('Medieval Arms', 'Armor and weaponry', (SELECT storage_id FROM core.storage WHERE location = 'Secure Basement'), (SELECT staff_id FROM core.staff WHERE email = 'e.norton@museum.com')),
('Rare Coins', 'Greek and Roman currency', (SELECT storage_id FROM core.storage WHERE location = 'North Wing Safe'), (SELECT staff_id FROM core.staff WHERE email = 'a.vance@museum.com')),
('Prehistoric', 'Fossils and remains', (SELECT storage_id FROM core.storage WHERE location = 'Archive Hall'), (SELECT staff_id FROM core.staff WHERE email = 'c.davis@museum.com')),
('Modern Art', '20th century sculptures', (SELECT storage_id FROM core.storage WHERE location = 'Restoration Lab'), (SELECT staff_id FROM core.staff WHERE email = 'e.norton@museum.com'))
ON CONFLICT DO NOTHING;

INSERT INTO core.items (item_name, collection_id, description, date_received, item_status)
VALUES 
('Gold Mask', (SELECT collection_id FROM core.collections WHERE collection_name = 'Ancient Egypt'), 'Funeral mask', '2026-03-20', 'Displayed'),
('Sunflowers Study', (SELECT collection_id FROM core.collections WHERE collection_name = 'Impressionism'), 'Oil on canvas', '2026-03-05', 'Displayed'),
('Knight Shield', (SELECT collection_id FROM core.collections WHERE collection_name = 'Medieval Arms'), 'Steel', '2026-03-12', 'Stored'),
('Silver Drachma', (SELECT collection_id FROM core.collections WHERE collection_name = 'Rare Coins'), 'Circa 400 BC', '2026-03-05', 'Stored'),
('T-Rex Tooth', (SELECT collection_id FROM core.collections WHERE collection_name = 'Prehistoric'), 'Found in Montana', '2026-03-28', 'Under Repair'),
('Iron Man Statue', (SELECT collection_id FROM core.collections WHERE collection_name = 'Modern Art'), 'Welded iron', '2026-04-02', 'Displayed')
ON CONFLICT DO NOTHING;

INSERT INTO core.exhibitions (exhibition_name, start_date, end_date, ticket_cost, is_offline, responsible_staff_id)
VALUES 
('Wonders of Nile', '2026-03-20', '2026-04-20', 25.00, TRUE, (SELECT staff_id FROM core.staff WHERE email = 'a.vance@museum.com')),
('Van Gogh Era', '2026-02-15', '2026-05-15', 20.00, TRUE, (SELECT staff_id FROM core.staff WHERE email = 'c.davis@museum.com')),
('Steel & Honor', '2026-02-10', '2026-03-10', 15.00, TRUE, (SELECT staff_id FROM core.staff WHERE email = 'f.gallagher@museum.com')),
('Money Matters', '2026-03-01', '2026-06-01', 10.00, FALSE, (SELECT staff_id FROM core.staff WHERE email = 'a.vance@museum.com')),
('Dino Discovery', '2026-03-15', '2026-06-15', 30.00, TRUE, (SELECT staff_id FROM core.staff WHERE email = 'c.davis@museum.com')),
('Future Forms', '2026-04-05', '2026-07-05', 12.00, FALSE, (SELECT staff_id FROM core.staff WHERE email = 'f.gallagher@museum.com'))
ON CONFLICT DO NOTHING;

INSERT INTO core.exhibition_items (item_id, exhibition_id)
VALUES 
    ((SELECT item_id FROM core.items WHERE item_name = 'Gold Mask'), 
     (SELECT exhibition_id FROM core.exhibitions WHERE exhibition_name = 'Wonders of Nile')),
     
    ((SELECT item_id FROM core.items WHERE item_name = 'Sunflowers Study'), 
     (SELECT exhibition_id FROM core.exhibitions WHERE exhibition_name = 'Van Gogh Era')),
     
    ((SELECT item_id FROM core.items WHERE item_name = 'Knight Shield'), 
     (SELECT exhibition_id FROM core.exhibitions WHERE exhibition_name = 'Steel & Honor')),
     
    ((SELECT item_id FROM core.items WHERE item_name = 'Silver Drachma'), 
     (SELECT exhibition_id FROM core.exhibitions WHERE exhibition_name = 'Money Matters')),
     
    ((SELECT item_id FROM core.items WHERE item_name = 'T-Rex Tooth'), 
     (SELECT exhibition_id FROM core.exhibitions WHERE exhibition_name = 'Dino Discovery')),
     
    ((SELECT item_id FROM core.items WHERE item_name = 'Iron Man Statue'), 
     (SELECT exhibition_id FROM core.exhibitions WHERE exhibition_name = 'Future Forms'))
ON CONFLICT DO NOTHING;

INSERT INTO core.visits (exhibition_id, total_amount, visitors_quantity, visit_date, visit_email)
VALUES 
((SELECT exhibition_id FROM core.exhibitions WHERE exhibition_name = 'Wonders of Nile'), 
    500.00, 20, '2026-02-15', 'archaeo_fan@example.com'),
((SELECT exhibition_id FROM core.exhibitions WHERE exhibition_name = 'Van Gogh Era'), 
    200.00, 10, '2026-03-10', 'art.lover@example.com'),
((SELECT exhibition_id FROM core.exhibitions WHERE exhibition_name = 'Steel & Honor'), 
    150.00, 10, '2026-01-25', 'history_buff@example.com'),
((SELECT exhibition_id FROM core.exhibitions WHERE exhibition_name = 'Money Matters'), 
    50.00, 5, '2026-04-02', 'coin_collector@example.com'),
((SELECT exhibition_id FROM core.exhibitions WHERE exhibition_name = 'Dino Discovery'), 
    300.00, 10, '2026-04-10', 'paleo_student@example.com'),
((SELECT exhibition_id FROM core.exhibitions WHERE exhibition_name = 'Future Forms'), 
    120.00, 10, '2026-04-18', 'modern_visitor@example.com')
ON CONFLICT DO NOTHING;

-----Function that updates data in one of tables----


CREATE OR REPLACE FUNCTION core.update_item_data (id INT,  column_name TEXT, new_value TEXT)
RETURNS VOID
AS $$
DECLARE rows_affected INT;
BEGIN 
    EXECUTE format('UPDATE core.items SET %I = $1 WHERE item_id = $2', column_name)
    USING new_value, id;
    GET DIAGNOSTICS rows_affected = ROW_COUNT;
    IF rows_affected = 0 THEN
        RAISE EXCEPTION 'Item with ID % not found in core.items', id;
    END IF;
END;
$$ 
LANGUAGE plpgsql;

--To test
SELECT core.update_item_data(1, 'item_status', 'Stored');

-----Function that adds a new transaction----

CREATE OR REPLACE FUNCTION core.add_transaction(exhibition_name_current text, amount_value DECIMAL(10,2), visitors_quantity_value int, visit_date_value date, visit_email_value text)
RETURNS text
AS $$
DECLARE exhibition_id_current int;
BEGIN
	SELECT exhibition_id INTO exhibition_id_current
	FROM core.exhibitions
	WHERE exhibition_name = exhibition_name_current;

	IF exhibition_id_current IS NULL THEN
	RAISE EXCEPTION 'Exhibition % not found', exhibition_name_current;
	END IF;

	INSERT INTO core.visits (exhibition_id, total_amount, visitors_quantity, visit_date, visit_email)
	VALUES (exhibition_id_current, amount_value, visitors_quantity_value, visit_date_value, visit_email_value);
	RETURN 'Operation completed successfully';
END;
$$ 
LANGUAGE plpgsql;

--To test
SELECT core.add_transaction('Wonders of Nile', 500.00, 20, '2026-02-15', 'archaeo_dddfan@example.com')


-----View that presents analytics for the most recently added quarter----

--NOTE! The requirements are ambiguous. It is not clear what "most recently added" indicates: the latest completed or the current quater (I use the current one for the task, assuming we need ongoing analytics, for example, for every day decisions)

CREATE VIEW recent_quater_anlytics AS 
SELECT e.exhibition_name AS exhibition, sum(v.total_amount) AS total_sale
FROM core.visits v 
INNER JOIN core.exhibitions e
ON v.exhibition_id = e.exhibition_id
WHERE EXTRACT(YEAR FROM v.visit_date) = EXTRACT(YEAR FROM CURRENT_DATE)
	AND EXTRACT(QUARTER FROM v.visit_date) = EXTRACT(QUARTER FROM CURRENT_DATE)
GROUP BY e.exhibition_name
ORDER BY total_sale

--To test
SELECT * FROM recent_quater_anlytics
SELECT * FROM core.exhibitions
SELECT * FROM core.visits

-----Read-only role for the manager----

CREATE USER manager WITH LOGIN PASSWORD 'managerpassword';

GRANT CONNECT ON DATABASE museum TO manager;

GRANT USAGE ON SCHEMA core TO manager;

GRANT SELECT ON ALL TABLES IN SCHEMA core TO manager;

