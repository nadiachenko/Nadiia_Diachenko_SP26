
--TASK 1

-- General notes. 
/*In DVDrental, last_update columns have default NOW() function. 
CURRENT_DATE is used to meet task requirements (confirmed in student chat that it will be overwritten finally).*/

--STEP 1. Adding 3 favorite movies to the 'film' table

/* Precondition: Check mandatory columns in the FILM table (NOT NULL contstraint and without default values): language_id,
 identify languages ids - SELECT * FROM public.language
*/

INSERT INTO public.film (title, language_id, rental_rate, rental_duration)
WITH new_films(title, language_id, rental_rate, rental_duration) AS (
VALUES ('Home Alone', 1, 4.99, 7),
	('The Intouchables', 1, 9.99, 14),
	('The Gentlemen', 1, 19.99, 21))
SELECT title, language_id, rental_rate, rental_duration
FROM new_films n
WHERE NOT EXISTS (SELECT *
FROM film f
WHERE f.title = n.title)
RETURNING film_id, title

/*STEP 2. Add film categories

Precondition: Check existing film categories SELECT * FROM public.category*/

INSERT INTO film_category (film_id, category_id)
SELECT film_id, category_id
FROM film 
INNER JOIN category  
ON (title = 'Home Alone' AND name = 'Family')
    OR (title = 'The Intouchables' AND name = 'Drama')
    OR (title = 'The Gentlemen' AND name = 'Action')
RETURNING film_id, category_id

--Step3. Add actors to the table


INSERT INTO actor (first_name, last_name)
WITH actors_list(first_name, last_name) AS (
    VALUES ('Macaulay', 'Culkin'),
        ('Joe', 'Pesci'),
        ('Daniel', 'Stern'),
        ('Francois', 'Cluzet'),
        ('Omar', 'Sy'),
        ('Anne', 'Le Ny'),
        ('Matthew', 'McConaughey'),
        ('Charlie', 'Hunnam'),
        ('Hugh', 'Grant'))
    SELECT first_name, last_name FROM actors_list l
    WHERE NOT EXISTS (
    SELECT * 
    FROM actor a
    WHERE a.first_name = l.first_name 
      AND a.last_name = l.last_name )
RETURNING actor_id, first_name, last_name

--Step 4. Link film_id with actor_id - populating film_actor table

INSERT INTO public.film_actor (film_id, actor_id, last_update)
SELECT f.film_id, a.actor_id, CURRENT_DATE
FROM public.film f
JOIN public.actor a
  ON ( (f.title = 'Home Alone' AND a.last_name IN ('Culkin', 'Pesci', 'Stern'))
    OR (f.title = 'The Intouchables' AND a.last_name IN ('Cluzet', 'Sy', 'Le Ny'))
    OR (f.title = 'The Gentlemen' AND a.last_name IN ('McConaughey', 'Hunnam', 'Grant')))
 WHERE NOT EXISTS (
 	SELECT *
 	FROM public.film_actor fa
    WHERE fa.film_id = f.film_id
      AND fa.actor_id = a.actor_id)
RETURNING film_id, actor_id;

--Step 5. Add inventory to stores
--Precondition: Obtain available stores SELECT * FROM public.store (store_id is mandatory)

--store 1
INSERT INTO inventory (film_id, store_id, last_update)
SELECT f.film_id, s.store_id, CURRENT_DATE
FROM public.film f
INNER JOIN public.store s ON s.address_id = 1
WHERE f.title IN ('Home Alone',
    'The Intouchables',
    'The Gentlemen')
RETURNING film_id, inventory_id;

--store 2
INSERT INTO inventory (film_id, store_id, last_update)
SELECT f.film_id, s.store_id, CURRENT_DATE
FROM public.film f
INNER JOIN public.store s ON s.address_id = 2
CROSS JOIN generate_series(1,2)
WHERE f.title IN ('Home Alone',
    'The Intouchables',
    'The Gentlemen')
RETURNING film_id, inventory_id

--Step 6. Update customer personal information

UPDATE public.customer 
SET first_name = 'Nadiia',
last_name = 'Diachenko',
email = 'nadiachenko@gmail.com',
last_update = CURRENT_DATE
WHERE customer_id = (SELECT customer_id 
FROM public.payment  
GROUP BY customer_id 
HAVING count(payment_id) >= 43
ORDER BY count(payment_id) DESC
LIMIT 1)
RETURNING *

--Step 7. Remove any records related to customer from all tables except 'Customer' and 'Inventory'

DELETE FROM public.payment
WHERE customer_id = (SELECT customer_id 
FROM public.customer  
WHERE email = 'nadiachenko@gmail.com')
RETURNING *

DELETE FROM public.rental
WHERE customer_id = (SELECT customer_id 
FROM public.customer  
WHERE email = 'nadiachenko@gmail.com')
RETURNING *

--Step 8. Rent and payfor movies from the store they are in 
--Preconditions:
--Create partition for records

CREATE TABLE payment_2026 PARTITION OF public.payment
FOR VALUES FROM ('2026-03-01') TO ('2026-05-01');

--Investigating staff table to identify staff_id and address_id - SELECT * FROM staff

WITH add_rental AS (
INSERT INTO rental (
    rental_date,
    inventory_id,
    customer_id,
    return_date,
    staff_id,
    last_update)
SELECT 
    CURRENT_DATE - (FLOOR(RANDOM() * 6 + 5))::int AS rental_date,
    i.inventory_id,
    c.customer_id,
    CURRENT_DATE - (FLOOR(RANDOM() * 3 + 1))::int AS return_date,
    FLOOR(RANDOM() * 5 + 1) AS staff_id,
    CURRENT_DATE
FROM public.film f
JOIN public.inventory i ON f.film_id = i.film_id
JOIN public.customer c ON c.email = 'nadiachenko@gmail.com'
WHERE f.title IN (
    'Home Alone',
    'The Intouchables',
    'The Gentlemen')
LIMIT 10
RETURNING rental_id, customer_id, rental_date, staff_id)
INSERT INTO public.payment (customer_id, staff_id,rental_id, amount, payment_date)
SELECT customer_id, staff_id, rental_id, ROUND((random()*14.01+0.99)::numeric, 2), rental_date
FROM add_rental
RETURNING payment_id, customer_id, staff_id,rental_id, amount, payment_date

