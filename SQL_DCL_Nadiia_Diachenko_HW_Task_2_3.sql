-----------Task 2. Implement role-based authentication model for dvd_rental database---------

-- 1. Create a new user with the username "rentaluser" and the password "rentalpassword". 

CREATE USER rentaluser WITH PASSWORD 'rentalpassword';
-- Query to confirm: SELECT * FROM pg_user;

-- 2. Give the user the ability to connect to the database but no other permissions.

GRANT CONNECT ON DATABASE dvdrental TO rentaluser;
-- Query to confirm: SELECT has_database_privilege('rentaluser', 'dvdrental', 'CONNECT');

--3. Grant "rentaluser" permission allows reading data from the "customer" table. Сheck to make sure this permission works correctly: write a SQL query to select all customers.

GRANT SELECT ON customer TO rentaluser;
--switching to rentaluser
SET ROLE rentaluser;
--confirming that the rentaluser is connected:
SELECT current_user;
--checking that permission works for customer table only:
SELECT * FROM customer;
--output: customer table
SELECT * FROM actor;
-- output: SQL Error [42501]: ERROR: permission denied for table actor

--4. Grant the "rental" group INSERT and UPDATE permissions for the "rental" table. Insert a new row and update one existing row in the "rental" table under that role. 

--precondition: RESET ROLE to postgres
GRANT SELECT, INSERT, UPDATE ON public.rental TO rentaluser

--precondition: SET ROLE to rentaluser
INSERT INTO public.rental(rental_date, inventory_id, customer_id, return_date, staff_id)
VALUES (current_date, 2, 3, current_date + interval '3 days', 1)
RETURNING rental_id, rental_date, inventory_id, customer_id, return_date, staff_id;

UPDATE public.rental 
SET return_date = current_date + interval '4 days'
WHERE customer_id = 5 AND inventory_id = 2 AND rental_date = current_date

--denied access example: SQL Error [42501]: ERROR: permission denied for table rental - the message was received when trying to insert data without permissions

--5. Revoke the "rental" group's INSERT permission for the "rental" table. Try to insert new rows into the "rental" table make sure this action is denied.

--precondition: RESET ROLE to postgres
REVOKE INSERT ON public.rental FROM rentaluser;

INSERT INTO public.rental(rental_date, inventory_id, customer_id, return_date, staff_id)
VALUES (current_date, 1, 3, current_date + interval '3 days', 1)
RETURNING rental_id, rental_date, inventory_id, customer_id, return_date, staff_id;

--output: SQL Error [42501]: ERROR: permission denied for table rental
 
--6. Create a personalized role for any customer already existing in the dvd_rental database. The name of the role name must be client_{first_name}_{last_name} (omit curly brackets). The customer's payment and rental history must not be empty. 

--precondition: find applicable customer
SELECT c.first_name, c.last_name, c.customer_id
FROM customer c
INNER JOIN rental r ON c.customer_id = r.customer_id
INNER JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(r.rental_id) > 0 AND COUNT(p.payment_id) > 0
LIMIT 1
--output: client_mary_smith

CREATE ROLE client_mary_smith WITH LOGIN PASSWORD 'mary12693@#'

-------------Task 3. Implement row-level security-----------------
--Configure that role so that the customer can only access their own data in the "rental" and "payment" tables. 

--RENTAL TABLE
--precondition: RESET ROLE to postgres

ALTER TABLE rental ENABLE ROW LEVEL SECURITY;

GRANT SELECT ON public.rental TO client_mary_smith;

CREATE POLICY user_1_rental_access ON public.rental 
FOR SELECT 
TO client_mary_smith 
USING (customer_id = 1);

--precondition: SET ROLE to client_mary_smith

SELECT * FROM public.rental;
--output:returns table with customer_id = 1 rentals

SELECT * FROM public.rental WHERE customer_id = 4;
--output: empty table is returned

--PAYMENT TABLE
--precondition: RESET ROLE to postgres
ALTER TABLE public.payment ENABLE ROW LEVEL SECURITY;

GRANT SELECT ON public.payment TO client_mary_smith;

CREATE POLICY user_1_payment_access ON public.payment
FOR SELECT 
TO client_mary_smith 
USING (customer_id = 1)

--precondition: SET ROLE to client_mary_smith

SELECT * FROM public.payment;
--output:returns table with customer_id = 1 payments

SELECT * FROM public.payment WHERE customer_id = 4;
--output: empty table is returned



