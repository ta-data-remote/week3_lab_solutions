USE sakila;
-- 1. There are 6 copies of Hunchback Impossible for rent
SELECT COUNT(inventory_id) FROM sakila.inventory
WHERE film_id IN (
SELECT film_id as film FROM(
SELECT film_id, title
FROM film
WHERE title = 'Hunchback Impossible') sub1
);

-- 2. There are 489 movies that have a length longer than the average of all the films
SELECT title, length FROM sakila.film
WHERE length > (SELECT AVG(length) as 'Average_duration'
FROM sakila.film);

-- 3. There are 8 actors in the movie Alone Trip
SELECT CONCAT(first_name,' ',last_name) FROM sakila.actor
WHERE actor_id IN(
SELECT actor_id FROM(
SELECT actor_id, title
FROM sakila.film
JOIN sakila.film_actor USING(film_id)
WHERE title = 'Alone Trip') sub1
);

-- 4. There are 69 family films
SELECT title FROM sakila.film
WHERE film_id IN(
SELECT film_id FROM(
SELECT film_id
FROM sakila.category
JOIN sakila.film_category USING(category_id)
WHERE name = 'Family') sub1
);

-- 5. There are 5 customers from Canada
-- using subqueries
SELECT CONCAT(first_name,' ',last_name), email FROM sakila.customer
WHERE address_id IN(
SELECT address_id FROM sakila.address
WHERE city_id IN(
SELECT city_id FROM sakila.city
WHERE country_id IN(
SELECT country_id FROM sakila.country
WHERE country = 'Canada'))
);

-- using joins
SELECT CONCAT(first_name,' ',last_name), email
FROM sakila.customer
JOIN sakila.address USING(address_id)
JOIN sakila.city USING(city_id)
JOIN sakila.country USING(country_id)
WHERE country = 'Canada';

-- 6. THe most prolofic actor starred in 42 movies. Starting with Bed Highball if you look at it on alphabetical order
-- using a temporary table
CREATE TEMPORARY TABLE most_movies_actor AS(
SELECT actor_id, COUNT(film_id) FROM sakila.film_actor
GROUP BY actor_id
ORDER BY COUNT(film_id) DESC
LIMIT 1);

SELECT f.title 
FROM sakila.film f
WHERE film_id IN(
SELECT film_id FROM film_actor
WHERE actor_id = (SELECT actor_id FROM most_movies_actor)
);

-- using one query including subqueries 
SELECT title 
FROM sakila.film
WHERE film_id IN(
SELECT film_id FROM film_actor
WHERE actor_id = (SELECT actor_id FROM ( 
SELECT actor_id, COUNT(film_id) FROM sakila.film_actor
GROUP BY actor_id
ORDER BY COUNT(film_id) DESC
LIMIT 1)sub1) 
);

--  7. There are 44 movies rented by the most profitable customers
SELECT title
FROM sakila.film
WHERE film_id IN(
SELECT film_id FROM( 
SELECT film_id FROM sakila.inventory i
JOIN sakila.rental r USING(inventory_id)
WHERE customer_id = (SELECT customer_id FROM (
SELECT customer_id, SUM(amount) FROM sakila.payment
GROUP BY customer_id
ORDER BY SUM(amount) DESC
LIMIT 1)sub1))sub2
);

-- 8. There are 285 customers that spend more than the average. The biggest spender is Karl Seal with 221,55 dollars
SELECT SUM(amount), CONCAT(first_name,' ',last_name) FROM sakila.customer
JOIN sakila.payment USING (customer_id)
GROUP BY customer_id
HAVING sum(amount) > (SELECT avg(total_payment) FROM (
SELECT customer_id, SUM(amount) as total_payment FROM sakila.payment
GROUP BY customer_id) sub1)
ORDER BY SUM(amount) DESC;
