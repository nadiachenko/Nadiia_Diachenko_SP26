
--GENERAL ASSUMPTIONS (To avoid duplicate information)

/* 1. In all tasks, the join type approach is the most suitable from production code perspective and overall.
 2. Some query results with a 3/5 record limit have rows with the same output. This has been left as is (it was questioned and allowed in the general chat). */ 

--PART 1

--Task 1
/*The marketing team needs a list of animation movies between 2017 and 2019 to promote family-friendly content in an upcoming season in stores. 
 *Show all animation movies released during this period with rate more than 1, sorted alphabetically
 
 --Assumptions:
 
* Business logic interpretation: Select animation category movies with rental rating more than 1(>) between 2017-2019(including)
* Inner joins are used because the goal is to get films of specific categories. This allows to avoid missing data (null) processing 
* The category selection was subqueried/defined in CTE to filter to irrelevant categories*/

--SUBQUERY Part 1. Task 1

SELECT 
    f.title,
    f.release_year,
    f.rental_rate
FROM public.film f
INNER JOIN public.film_category fc
    ON f.film_id = fc.film_id
INNER JOIN public.category c
    ON fc.category_id = c.category_id
WHERE c.category_id = (
    SELECT c.category_id
    FROM public.category c
    WHERE c.name = 'Animation'
)
AND f.release_year BETWEEN 2017 AND 2019
AND f.rental_rate > 1
ORDER BY f.title ASC;

--JOIN Part 1. Task 1
                                
 SELECT 
    f.title,
    f.release_year,
    f.rental_rate
FROM public.film f
INNER JOIN public.film_category fc
    ON f.film_id = fc.film_id
INNER JOIN public.category c
    ON fc.category_id = c.category_id
WHERE c.name = 'Animation'
AND f.release_year BETWEEN 2017 AND 2019
AND f.rental_rate > 1
ORDER BY f.title ASC;          

--CTE Part 1. Task 1

WITH animation_category_films AS (
    SELECT c.category_id
    from category c 
    WHERE c.name = 'Animation'
)
SELECT title, release_year, rental_rate
FROM film f
inner join film_category fc 
on f.film_id  =fc.film_id 
INNER JOIN animation_category_films af ON fc.category_id = af.category_id
  AND f.release_year BETWEEN 2017 AND 2019
and f.rental_rate > 1;

--Task 2

/*The finance department requires a report on store performance to assess profitability and plan resource allocation for stores after March 2017. 
Calculate the revenue earned by each rental store after March 2017 (since April) (include columns: address and address2 – as one column, revenue)

-- Assumptions:

* Business logic interpretation: I need to sum all payments for separate stores since April 2017 
* In most cases, inner joins are used to avoid unnecessary null values. But the left join connect payments and rentals tables. During query creation, it was observed that rental_id  4591 appears 6 times in payments table and has associated payment amounts. 
* The subquery was used at the FROM level to limit table execution runs at least to required date range. The same approach was selected for CTE creation.
* Payment>rental>inventory>address path was selected as most reliable, as it ensures data consistency - each record in the previous table should have corresponding value in following
*/

--SUBQUERY Part 1. Task 2

SELECT 
    CONCAT(a.address, ' ', a.address2) AS full_store_address,
    SUM(p.amount) AS revenue
FROM (
    SELECT rental_id, amount
    FROM public.payment
    WHERE payment_date >= DATE '2017-04-01'
) p
LEFT JOIN public.rental r
    ON p.rental_id = r.rental_id
INNER JOIN public.inventory i
    ON r.inventory_id = i.inventory_id
INNER JOIN public.store s
    ON i.store_id = s.store_id
INNER JOIN public.address a
    ON s.address_id = a.address_id
GROUP BY a.address, a.address2;

--JOIN Part 1. Task 2

SELECT 
    CONCAT(a.address, ' ', a.address2) AS full_store_address,
    SUM(p.amount) AS revenue
FROM public.payment p
LEFT JOIN public.rental r
    ON p.rental_id = r.rental_id
INNER JOIN public.inventory i
    ON r.inventory_id = i.inventory_id
INNER JOIN public.store s
    ON i.store_id = s.store_id
INNER JOIN public.address a
    ON s.address_id = a.address_id
WHERE p.payment_date >= DATE '2017-04-01'
GROUP BY a.address, a.address2;

--CTE Part 1. Task 2

WITH payments_after_2017 as (
	SELECT rental_id, amount 
	FROM payment  
	WHERE payment_date >= '2017-04-01'
) 
SELECT CONCAT(address, ' ', address2) AS full_store_address,
       SUM(p.amount) AS revenue 
FROM payments_after_2017 p   
LEFT JOIN public.rental r
    ON p.rental_id = r.rental_id
INNER JOIN public.inventory i
    ON r.inventory_id = i.inventory_id
INNER JOIN public.store s
    ON i.store_id = s.store_id
INNER JOIN public.address a
    ON s.address_id = a.address_id
GROUP BY full_store_address

--TASK 3

/*The marketing department in our stores aims to identify the most successful actors since 2015 to boost customer interest in their films.
 Show top-5 actors by number of movies (released since 2015) they took part in (columns: first_name, last_name, number_of_movies, sorted by number_of_movies in descending order)

-- Assumptions:

* Business logic interpretation: Top 5 actors by movie count after 2015 should be selected 
* Initially, there was ambiguity in the task description: "released after 2015" was changed to "released since 2015", so >= operator was selected.
* Inner joins are chosen as we are not interested in actors with no movies
* The code in subquery and CTE parts was selected to limit data execution runs to specific range - since 2015*/

--SUBQUERY Part 1. Task 3

SELECT 
    a.first_name,
    a.last_name,
    COUNT(f.film_id) AS number_of_movies
FROM (
    SELECT film_id
    FROM public.film
    WHERE release_year >= 2015
) f
INNER JOIN public.film_actor fa
    ON fa.film_id = f.film_id
INNER JOIN public.actor a
    ON a.actor_id = fa.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY number_of_movies DESC
LIMIT 5;

--JOIN Part 1. Task 3

SELECT 
    a.first_name,
    a.last_name,
    COUNT(fa.film_id) AS number_of_movies
FROM public.actor a
INNER JOIN public.film_actor fa
    ON a.actor_id = fa.actor_id
INNER JOIN public.film f
    ON fa.film_id = f.film_id
WHERE f.release_year >= 2015
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY number_of_movies DESC
LIMIT 5;

--CTE Part 1. Task 3

 WITH films_after_2015 AS (
    SELECT film_id
    FROM public.film
    WHERE release_year >= 2015
)
SELECT 
    a.first_name,
    a.last_name,
    COUNT(f.film_id) AS number_of_movies
FROM films_after_2015 f
INNER JOIN public.film_actor fa
    ON fa.film_id = f.film_id
INNER JOIN public.actor a
    ON a.actor_id = fa.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY number_of_movies DESC
LIMIT 5;

--TASK 4

/*The marketing team needs to track the production trends of Drama, Travel, and Documentary films to inform genre-specific marketing strategies.
 Show number of Drama, Travel, Documentary per year (include columns: release_year, number_of_drama_movies, number_of_travel_movies, number_of_documentary_movies), sorted by release year in descending order.
 Dealing with NULL values is encouraged)

-- Assumptions:

* Business logic interpretation: Number of Drama, Travel, Documentary films per year should be displayed
* LEFT JOIN used to keep all years even if no films exist for a category starting from film table
* The subquery is used on the join level to filter for required categories only, the same approach was applied to the CTE*/

--SUBQUERY Part 1. Task 4

SELECT 
    f.release_year,
    SUM(CASE WHEN c.name = 'Drama' THEN 1 ELSE 0 END) AS number_of_drama_movies,
    SUM(CASE WHEN c.name = 'Travel' THEN 1 ELSE 0 END) AS number_of_travel_movies,
    SUM(CASE WHEN c.name = 'Documentary' THEN 1 ELSE 0 END) AS number_of_documentary_movies
FROM public.film f
LEFT JOIN public.film_category fc
    ON f.film_id = fc.film_id
LEFT JOIN (
    SELECT category_id, name
    FROM public.category
    WHERE name IN ('Drama', 'Travel', 'Documentary')
) c
    ON fc.category_id = c.category_id
GROUP BY f.release_year
ORDER BY f.release_year DESC;

--JOIN Part 1. Task 4

SELECT 
    f.release_year,
    SUM(CASE WHEN c.name = 'Drama' THEN 1 ELSE 0 END) AS number_of_drama_movies,
    SUM(CASE WHEN c.name = 'Travel' THEN 1 ELSE 0 END) AS number_of_travel_movies,
    SUM(CASE WHEN c.name = 'Documentary' THEN 1 ELSE 0 END) AS number_of_documentary_movies
FROM public.film f
LEFT JOIN public.film_category fc
    ON f.film_id = fc.film_id
LEFT JOIN public.category c
    ON fc.category_id = c.category_id
GROUP BY f.release_year
ORDER BY f.release_year DESC;

--CTE Part 1. Task 4

WITH categories AS (
    SELECT category_id, name
    FROM public.category
    WHERE name IN ('Drama', 'Travel', 'Documentary')
)
SELECT 
    f.release_year,
    SUM(CASE WHEN c.name = 'Drama' THEN 1 ELSE 0 END) AS number_of_drama_movies,
    SUM(CASE WHEN c.name = 'Travel' THEN 1 ELSE 0 END) AS number_of_travel_movies,
    SUM(CASE WHEN c.name = 'Documentary' THEN 1 ELSE 0 END) AS number_of_documentary_movies
FROM public.film f
LEFT JOIN public.film_category fc
    ON f.film_id = fc.film_id
LEFT JOIN categories c
    ON fc.category_id = c.category_id
GROUP BY f.release_year
ORDER BY f.release_year DESC;


--PART 2

--TASK 1

/*The HR department aims to reward top-performing employees in 2017 with bonuses to recognize their contribution to stores revenue. 
 Show which three employees generated the most revenue in 2017? 

--Assumptions:

* Business logic interpretation: The total payment amount for rentals processed by different staff members should be calculated regardless the store
* Assumption that store_id in the staff table reflects the latest store of staff
* Assumtion that the calculations should be based for staff associated with rentals
* INNER JOINs ensure only valid payment>rental>staff relations
* The date range is subqueried/used in CTE to reduce dataset before joins */

--SUBQUERY Part 2. Task 1

SELECT 
    s.staff_id,
    s.first_name,
    s.last_name,
    s.store_id,
    SUM(p.amount) AS staff_revenue
FROM (
    SELECT rental_id, amount
    FROM public.payment
    WHERE payment_date >= DATE '2017-01-01'
      AND payment_date < DATE '2018-01-01'
) p
INNER JOIN public.rental r
    ON p.rental_id = r.rental_id
INNER JOIN public.staff s
    ON r.staff_id = s.staff_id
GROUP BY s.staff_id, s.first_name, s.last_name, s.store_id
ORDER BY staff_revenue DESC
LIMIT 3;

--JOIN Part 2. Task 1

SELECT 
    s.staff_id,
    s.first_name,
    s.last_name,
    s.store_id,
    SUM(p.amount) AS staff_revenue
FROM public.payment p
INNER JOIN public.rental r
    ON p.rental_id = r.rental_id
INNER JOIN public.staff s
    ON r.staff_id = s.staff_id
WHERE p.payment_date >= DATE '2017-01-01'
  AND p.payment_date < DATE '2018-01-01'
GROUP BY s.staff_id, s.first_name, s.last_name, s.store_id
ORDER BY staff_revenue DESC
LIMIT 3;

--CTE Part 2. Task 1

WITH payments_2017 AS (
    SELECT rental_id, amount
    FROM public.payment
    WHERE payment_date >= DATE '2017-01-01'
      AND payment_date < DATE '2018-01-01'
)
SELECT 
    s.staff_id,
    s.first_name,
    s.last_name,
    s.store_id,
    SUM(p.amount) AS staff_revenue
FROM payments_2017 p
INNER JOIN public.rental r
    ON p.rental_id = r.rental_id
INNER JOIN public.staff s
    ON r.staff_id = s.staff_id
GROUP BY s.staff_id, s.first_name, s.last_name, s.store_id
ORDER BY staff_revenue DESC
LIMIT 3; 

--TASK 2 

/*The management team wants to identify the most popular movies and their target audience age groups to optimize marketing efforts. 
 Show which 5 movies were rented more than others (number of rentals), and what's the expected age of the audience for these movies?

--Assumptions:

* Business logic interpretation: the number of 5 most rented movies with ratings should be displayed (film table should be connected with rental via inventory table)
* INNER JOIN used to count only actual rentals*/

--SUBQUERY Part 2. Task 2

SELECT 
    mr.title,
    mr.rating,
    COUNT(mr.rental_id) AS number_of_rentals
FROM (
    SELECT f.title, f.rating, r.rental_id
    FROM public.film f
    INNER JOIN public.inventory i
        ON f.film_id = i.film_id
    INNER JOIN public.rental r
        ON i.inventory_id = r.inventory_id
) mr
GROUP BY mr.title, mr.rating
ORDER BY number_of_rentals DESC
LIMIT 5;

--JOIN Part 2. Task 2

SELECT 
    f.title,
    f.rating,
    COUNT(r.rental_id) AS number_of_rentals
FROM public.film f
INNER JOIN public.inventory i
    ON f.film_id = i.film_id
INNER JOIN public.rental r
    ON i.inventory_id = r.inventory_id
GROUP BY f.title, f.rating
ORDER BY number_of_rentals DESC
LIMIT 5;

--CTE Part 2. Task 2
WITH film_rentals AS (
    SELECT 
        f.title,
        f.rating,
        r.rental_id
    FROM public.film f
    INNER JOIN public.inventory i
        ON f.film_id = i.film_id
    INNER JOIN public.rental r
        ON i.inventory_id = r.inventory_id
)
SELECT 
    title,
    rating,
    COUNT(rental_id) AS number_of_rentals
FROM film_rentals
GROUP BY title, rating
ORDER BY number_of_rentals DESC
LIMIT 5;

--PART 3

/*The stores’ marketing team wants to analyze actors' inactivity periods to select those with notable career breaks for targeted 
 promotional campaigns, highlighting their comebacks or consistent appearances to engage customers with nostalgic or reliable film stars
 
V1: gap between the latest release_year and current year per each actor;
V2: gaps between sequential films per each actor;

 
 --Assumptions:
 
* Business logic interpretation: the year difference between films(depends on approach) for each actor should be calculated
* The LEFT JOINs are implemented to ensure that all actors will be displayed (even with no films)
* It was difficult to figure out what is meant by V2: gaps between sequential films per each actor(sum of gaps/max gap/other); approach with maximum gap was selected*/

--V1: gap between the latest release_year and current year per each actor;

--SUBQUERY Part 3. Approach 1

SELECT 
    a.first_name,
    a.last_name, 
    a.actor_id, 
    EXTRACT(YEAR FROM CURRENT_DATE) - MAX(f.release_year) as inactivity_duration
FROM public.actor a
LEFT JOIN public.film_actor fa
    ON a.actor_id = fa.actor_id
LEFT JOIN public.film f
    ON fa.film_id = f.film_id
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY inactivity_duration DESC;
 
--JOIN Part 3. Approach 1
SELECT 
    a.first_name,
    a.last_name, 
    a.actor_id, 
    EXTRACT(YEAR FROM CURRENT_DATE) - max(f.release_year) as inactivity_duration
FROM actor a
LEFT JOIN film_actor fa 
 	ON a.actor_id = fa.actor_id
LEFT JOIN film f 
    ON fa.film_id = f.film_id
GROUP BY a.first_name, a.last_name, a.actor_id
ORDER BY inactivity_duration desc;

--CTE Part 3. Approach 1

WITH actor_films AS (
    SELECT 
        a.first_name,
        a.last_name, 
        a.actor_id,
        f.release_year
    FROM actor a
    LEFT JOIN film_actor fa 
        ON a.actor_id = fa.actor_id
    LEFT JOIN film f 
        ON fa.film_id = f.film_id
) 
SELECT 
    first_name,
    last_name, 
    actor_id, 
    EXTRACT(YEAR FROM CURRENT_DATE) - MAX(release_year) AS inactivity_duration
FROM actor_films
GROUP BY first_name, last_name, actor_id
ORDER BY inactivity_duration DESC;


--V2: gaps between sequential films per each actor
--Honestly, It was difficult dealing with this without depth AI advice, and answers in the general chat)
--It is not possible to complete it without subquery


--JOIN/SUBQUERY Part 3. Approach 2

SELECT 
    a.first_name, 
    a.last_name,
    MAX(f2.release_year - f1.release_year) AS max_sequential_gap
FROM actor a
JOIN film_actor fa1 ON a.actor_id = fa1.actor_id
JOIN film f1 ON fa1.film_id = f1.film_id
JOIN film_actor fa2 ON a.actor_id = fa2.actor_id
JOIN film f2 ON fa2.film_id = f2.film_id
WHERE f2.release_year > f1.release_year 
AND NOT EXISTS (
    SELECT 1 FROM film_actor fa3 
    JOIN film f3 ON fa3.film_id = f3.film_id
    WHERE fa3.actor_id = a.actor_id 
    AND f3.release_year > f1.release_year 
    AND f3.release_year < f2.release_year
)
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY max_sequential_gap DESC;

--CTE Part 3. Approach 2

WITH actor_film_sequence AS (
    SELECT 
        a.actor_id,
        a.first_name,
        a.last_name,
        f1.release_year AS current_film_year,
        (SELECT MIN(f2.release_year) 
         FROM film_actor fa2
         JOIN film f2 ON fa2.film_id = f2.film_id
         WHERE fa2.actor_id = a.actor_id 
         AND f2.release_year > f1.release_year
        ) AS next_film_year
    FROM actor a
    JOIN film_actor fa1 ON a.actor_id = fa1.actor_id
    JOIN film f1 ON fa1.film_id = f1.film_id
)
SELECT 
    first_name,
    last_name,
    MAX(next_film_year - current_film_year) AS max_sequential_gap
FROM actor_film_sequence
WHERE next_film_year IS NOT NULL 
GROUP BY actor_id, first_name, last_name
ORDER BY max_sequential_gap DESC;


