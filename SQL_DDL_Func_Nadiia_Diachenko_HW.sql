--Task 1. Create a view

/* Only categories with sales appear, zero-sales categories are excluded. -It is achieved with use of  INNER JOINs across all tables. 
 * The view should only display categories in the current quarter. -It is achieved by quarter and year extraction
 * How I verified that view is working correctly - by inserting fresh records:
	
	1. INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id)
	VALUES (CURRENT_TIMESTAMP, 1, 269, CURRENT_TIMESTAMP + interval '3 days', 1)
	RETURNING rental_id; 
	2. CREATE TABLE payment_p2026_04 PARTITION OF payment
    FOR VALUES FROM ('2026-04-01') TO ('2026-05-01');
	3. INSERT INTO payment (customer_id, staff_id, rental_id, amount, payment_date)
	VALUES (269,1, (SELECT MAX(rental_id) FROM rental), 10.00, CURRENT_TIMESTAMP);
	
 * Example of data that should NOT appear: categories with no rented movies, unpaid but rented movies, rental out from the specified date range
 */
   
CREATE VIEW sales_revenue_by_category_qtr AS
SELECT c.name AS category_name,
    SUM(p.amount) AS total_revenue
FROM category c
INNER JOIN film_category fc ON c.category_id = fc.category_id
INNER JOIN film f ON fc.film_id = f.film_id
INNER JOIN inventory i ON f.film_id = i.film_id
INNER JOIN rental r ON i.inventory_id = r.inventory_id
INNER JOIN payment p ON r.rental_id = p.rental_id
WHERE EXTRACT(YEAR FROM p.payment_date) = EXTRACT(YEAR FROM CURRENT_DATE)
	AND EXTRACT(QUARTER FROM p.payment_date) = EXTRACT(QUARTER FROM CURRENT_DATE)
GROUP BY c.name;

--Task 2. Create a query language functions

--Explanations:
/* why parameter is needed:
 * parameter is required to reuse the function with any date
 
 * what happens if invalid quarter is passed:
 * invalid data type - error is raised, invalid date - empty rows are returned

 * what happens if no data exists:
 * empty rws are returned
 */

CREATE OR REPLACE FUNCTION get_sales_revenue_by_category_qtr (quarter_year date)
RETURNS TABLE (category_name text, total_revenue numeric) AS $$
SELECT c.name,
    SUM(p.amount) 
FROM category c
INNER JOIN film_category fc ON c.category_id = fc.category_id
INNER JOIN film f ON fc.film_id = f.film_id
INNER JOIN inventory i ON f.film_id = i.film_id
INNER JOIN rental r ON i.inventory_id = r.inventory_id
INNER JOIN payment p ON r.rental_id = p.rental_id
WHERE EXTRACT(YEAR FROM p.payment_date) = EXTRACT(YEAR FROM quarter_year)
	AND EXTRACT(QUARTER FROM p.payment_date) = EXTRACT(QUARTER FROM quarter_year)
GROUP BY c.name
$$ LANGUAGE SQL;

--SELECT* FROM get_sales_revenue_by_category_qtr ()

--Task 3. Create procedure language functions

--Explanations:

/* how 'most popular' is defined: by rentals / by revenue / by count
 * the most popular films are defined by rentals count
 
 * how ties are handled
 * the ties are handled with RANK() function, the same rank is assigned to identical values
 
 * what happens if country has no data
 * the country is not included into the table result
 
*/

CREATE OR REPLACE FUNCTION most_popular_films_by_countries(countries_list text[])
RETURNS TABLE (Country text, Film text, Rating mpaa_rating, Language char(20),Length int2, "release year" year)
AS $$
DECLARE 
country_to_check text;
country_exists boolean;
BEGIN
	FOREACH country_to_check IN ARRAY countries_list
LOOP  
SELECT EXISTS (SELECT * FROM country c WHERE c.country = country_to_check) INTO country_exists;
        IF NOT country_exists THEN
            RAISE EXCEPTION 'Invalid Input: The country "%" not found', country_to_check;   
        END IF;
RETURN QUERY
        SELECT sub.country,sub.title, sub.rating,sub.language, sub.length, sub.release_year
FROM (SELECT c.country, f.title, f.rating, l.name::char(20) AS language, f.length, f.release_year,
RANK() OVER (PARTITION BY c.country ORDER BY COUNT(r.rental_id) DESC) AS rnk
  FROM country c
  INNER JOIN city ci ON c.country_id = ci.country_id
  INNER JOIN address a ON a.city_id = ci.city_id
  INNER JOIN customer cu ON a.address_id = cu.address_id
  INNER JOIN rental r ON cu.customer_id = r.customer_id
  INNER JOIN inventory i ON r.inventory_id = i.inventory_id
  INNER JOIN film f ON f.film_id = i.film_id
  LEFT JOIN language l ON f.original_language_id = l.language_id
  WHERE c.country = country_to_check
  GROUP BY  c.country, f.title, f.rating, l.name, f.length, f.release_year) AS sub
        WHERE sub.rnk = 1;
END LOOP;
END $$
LANGUAGE plpgsql;

--SELECT * FROM most_popular_films_by_countries(ARRAY['Brazil', 'United States', 'Angola']);

---Task 4. Create procedure language functions

--Explanations:

/*how pattern matching works (LIKE, %)
 * LIKE function is replaced to ILIKE to avoid case-insensitive missing results
 
* how you ensure performance: which part of your query may become slow on large data; how your implementation minimizes unnecessary data processing
* WHERE r.return_date IS NULL filters the active rentals and reduces data;
* using JOINs (not subqueries);
* IF search_word IS NULL OR trim(search_word) = '' - prevents from search with empty input

* case sensitivity
* ILIKE handles case sensitivity issues

* what happens if:
* multiple matches
* all matching rows are returned with unique IDs

* no matches
* RAISE NOTICE 'No results found for your search' is created
*/

CREATE OR REPLACE FUNCTION films_in_stock_by_title(search_word text)
RETURNS TABLE (
    "Row number" bigint,
    "Film title" text,
    "Language" character(20),
    "Customer name" text,
    "Rental date" timestamptz)    
AS $$ 
BEGIN
IF search_word IS NULL OR trim(search_word) = '' THEN
RAISE EXCEPTION 'Please provide a search word' ;
END IF;
RETURN QUERY
SELECT ROW_NUMBER() OVER(), f.title, l.name, concat(c.first_name, ' ', c.last_name), max(r.rental_date)
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
JOIN customer c ON c.customer_id = r.customer_id
LEFT JOIN language l ON f.original_language_id = l.language_id
WHERE r.return_date IS null
    AND f.title ILIKE '%' || search_word || '%'
GROUP BY f.title, l.name, concat(c.first_name, ' ', c.last_name);
IF NOT FOUND THEN
    RAISE NOTICE 'No results found for your search';
    END IF;
END;
$$ 
LANGUAGE plpgsql;

--SELECT * FROM films_in_stock_by_title('CHA');

--Task 5. Create procedure language functions

/*how you generate unique ID
*it is generated by database automatically - no input needed from my side

*how you ensure no duplicates
*WHERE NOT EXISTS is added to the insert block

*what happens if movie already exists
*RAISE EXCEPTION 'The movie already exists' is added

*how you validate language existence
*if not found statement is added

*what happens if insertion fails
*in case of invalid data type the error is triggered

*how consistency is preserved
*duplicate films are prevented by checking film existence
*/
DROP FUNCTION new_movie(movie_title text)

CREATE OR REPLACE FUNCTION new_movie(movie_title text, 
release_year int DEFAULT extract(YEAR FROM current_date), 
language_name text DEFAULT 'Klingon')
RETURNS int
AS $$
declare new_movie_id int;
new_lang_id int;
begin 
SELECT film_id INTO new_movie_id 
    FROM film 
    WHERE title = movie_title;
IF new_movie_id IS not NULL THEN
        RAISE EXCEPTION 'The movie already exists';
    END IF;
SELECT language_id INTO new_lang_id 
    FROM language 
    WHERE trim(name) = language_name;
    IF new_lang_id IS NULL THEN
        RAISE NOTICE 'Language Klingon not found.';
        INSERT INTO language (name) 
        VALUES ('Klingon') 
        RETURNING language_id INTO new_lang_id;
    END IF;
INSERT INTO public.film (title, release_year, language_id, rental_duration, rental_rate, replacement_cost)
VALUES (movie_title, extract(YEAR FROM current_date), new_lang_id, 3, 4.99, 19.99)
returning film_id into new_movie_id;
return new_movie_id;
END;
$$
LANGUAGE plpgsql;

--SELECT * FROM new_movie('teghjestkjw')

