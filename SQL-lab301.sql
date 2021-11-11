USE sakila;

-- 1. Drop column picture from staff
ALTER TABLE sakila.staff
DROP picture;

-- 2. Add Tammy Sanders to staff database
SELECT *
FROM sakila.staff
WHERE first_name = 'Jon';

SELECT *
FROM sakila.customer
WHERE first_name = 'TAMMY' and last_name = 'SANDERS';

INSERT INTO sakila.staff(first_name, last_name, address_id, email, store_id,active,username)
VALUES
('TAMMY','SANDERS','79','TAMMY.SANDERS@sakilacustomer.org',2,1,'TAMMY');

-- 3. Add Acadamy Dinosaur to rental column
SELECT *
FROM sakila.rental;

SELECT *
FROM sakila.film
WHERE title = 'Academy Dinosaur'; -- film_id is 1

SELECT *
FROM sakila.inventory
WHERE film_id = 1;

SELECT customer_id FROM sakila.customer
WHERE first_name = 'CHARLOTTE' AND last_name = 'HUNTER';

SELECT *
FROM sakila.staff;

INSERT INTO sakila.rental(rental_date, inventory_id, customer_id, staff_id)
VALUES
('2021-08-23 00:00:00',4,130,1);

SELECT *
FROM sakila.rental
WHERE rental_date = '2021-08-23 18:40:46'
