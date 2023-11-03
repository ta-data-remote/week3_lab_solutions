use sakila;

-- 1.How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT * FROM film;
SELECT * FROM inventory;

(SELECT film_id
FROM film
WHERE title = 'Hunchback Impossible');

SELECT COUNT(film_id) AS count, film_id
FROM inventory
WHERE film_id = ( -- film_id = 439
				SELECT film_id
				FROM film
				WHERE title = 'Hunchback Impossible');
-- Output is 6.


-- trying with the subquery
SELECT Amount_of_copies
FROM ( -- Only number of copies
		SELECT film_id, COUNT(inventory_id) AS Amount_of_copies
		FROM inventory
		GROUP BY film_id
		HAVING film_id = ( -- 439 film_id 
							SELECT film_id
							FROM film
							WHERE title = 'Hunchback Impossible'))sub2 ;

-- Output is 6. (same as above)

-- 2. List all films whose length is longer than the average of all the films.
SELECT AVG(length) 
FROM film; -- Output: 115.2720

SELECT film_id, title, length
FROM film
WHERE length > -- Avg(length) 115.2720
		(SELECT AVG(length)
        FROM film);

-- 3. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT film_id
FROM film
WHERE title = 'Alone Trip';
    
 SELECT actor_id
FROM film_actor
WHERE film_id IN (  -- film_id = 17
					SELECT film_id
					FROM film
					WHERE title = 'Alone Trip')  ; 
    
    
SELECT first_name, last_name
FROM actor
WHERE actor_id IN ( -- List of Actor_ids in Alone Trip
					SELECT actor_id
					FROM film_actor
					WHERE film_id IN ( -- film_id of Alone Trip
										SELECT film_id
										FROM film
										WHERE title = 'Alone Trip'));
                                        

-- 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

SELECT * 
FROM film_category;

SELECT * 
FROM category;
-- category_id = 8, and name (of category) = Family

SELECT title
FROM film
WHERE film_id IN ( -- List of film_ids for Family 
					SELECT film_id
					FROM film_category
					WHERE category_id IN ( -- 8 = Family
											SELECT category_id
											FROM category
											WHERE name = 'Family'));


-- 5. Get name and email from customers from Canada using subqueries. 
-- Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, 
-- that will help you get the relevant information.

SELECT *
FROM city;

-- USING SUBQUERIES
SELECT country_id 
FROM sakila.country
WHERE country = 'Canada';

SELECT city_id 
FROM sakila.city
WHERE country_id = (SELECT country_id 
					FROM sakila.country
					WHERE country = 'Canada');
                    
SELECT address_id 
FROM sakila.address
WHERE city_id IN ( -- list of all 7 city_ids in Canada
					SELECT city_id 
					FROM sakila.city
					WHERE country_id = ( -- Canada country_id = 20
										SELECT country_id 
										FROM sakila.country
										WHERE country = 'Canada')) ;                   
                    
SELECT first_name, last_name, email 
FROM sakila.customer
WHERE address_id IN ( -- list of all adress_ids in Canada
						SELECT address_id 
						FROM sakila.address
						WHERE city_id IN (SELECT city_id 
											FROM sakila.city
											WHERE country_id = (SELECT country_id 
																FROM sakila.country
																WHERE country = 'Canada')));

-- USING JOIN
SELECT c.first_name, c.last_name, c.email 
FROM customer c
JOIN address a
	ON (c.address_id = a.address_id)
	JOIN city ct
		ON (ct.city_id = a.city_id)
		JOIN country co
			ON (co.country_id = ct.country_id)
WHERE co.country= 'Canada';



-- 6. Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. 
-- First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.


SELECT title AS Movies
FROM film
JOIN film_actor USING (film_id) 
WHERE actor_id =
				(SELECT actor_id
                FROM sakila.actor
				JOIN sakila.film_actor USING (actor_id)
				JOIN sakila.film USING (film_id)
				GROUP BY actor_id
				ORDER BY count(film_id) DESC
				LIMIT 1);

SELECT film_id, title, first_name, last_name
FROM film_actor
LEFT JOIN film USING (film_id)
JOIN actor USING (actor_id)
WHERE actor_id = (
					SELECT actor_id
					FROM (
							SELECT actor_id, COUNT(film_id)
							FROM film_actor
							GROUP BY actor_id
							ORDER BY COUNT(film_id)DESC
                            LIMIT 1) sub1);  -- Can't have a Limit at end of subquery, 

-- Who is the most prolific actor??

-- SELECT 
SELECT first_name, last_name
FROM actor
WHERE actor_id IN (
						SELECT actor_id 
						FROM(
							SELECT actor_id, COUNT(film_id)
							FROM film_actor
							GROUP BY actor_id
							ORDER BY COUNT(film_id) DESC
                            LIMIT 1) sub1);


-- 7.Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer 
-- ie the customer that has made the largest sum of payments

SELECT *
FROM payment;
SELECT *
FROM rental;
SELECT *
FROM inventory;
SELECT *
FROM film;
-- 
SELECT inventory.film_id, film.title, customer_id
FROM rental
LEFT JOIN inventory USING (inventory_id)
LEFT JOIN film USING (film_id)
WHERE customer_id IN (
						SELECT customer_id
						FROM(
								SELECT customer_id, SUM(amount)
								FROM payment
								GROUP BY customer_id
								ORDER BY SUM(amount) DESC
								 LIMIT 1) sub1);
                                 
                                 
-- 8.Customers who spent more than the average payments.
SELECT *
FROM customer;
SELECT *
FROM payment;


SELECT customer_id, SUM(amount) AS sum
FROM payment
GROUP BY customer_id;

SELECT AVG(sum) AS Average
FROM (SELECT customer_id, SUM(amount) AS sum
		FROM payment
		GROUP BY customer_id) sub1;

-- doing the subquery now
SELECT customer_id, SUM(amount) AS Total_amount_spent
FROM payment
GROUP BY customer_id
HAVING SUM(amount) > (SELECT AVG(sum) AS Average
						FROM (SELECT customer_id, SUM(amount) AS sum
								FROM payment
								GROUP BY customer_id) sub1);                            
                                 
-- 285 rows returned
SELECT customer_id, SUM(amount) AS Total_amount_spent
FROM payment
GROUP BY customer_id
HAVING SUM(amount) > (SELECT AVG(sum) AS Average
						FROM 
							(SELECT customer_id, SUM(amount) AS sum
							FROM payment
							GROUP BY customer_id) sub1)
							ORDER BY SUM(amount) DESC;                                 


-- 8 Retrieve the customer_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. You can use subqueries to accomplish this.
SELECT customer_id, SUM(amount) as total_amount_spent
FROM payment
GROUP BY customer_id
HAVING total_amount_spent > (SELECT AVG(total_amount_spent)
							 FROM (SELECT SUM(amount) as total_amount_spent
									FROM sakila.payment
									GROUP BY customer_id) as subquery);

-- 45 rows returned
SELECT customer_id
FROM (SELECT customer_id, SUM(amount)
		FROM payment
		GROUP BY customer_id
		ORDER BY SUM(amount) DESC
		LIMIT 1) sub1;
-- most profitable customer: customer_id = 526










