## Instructions
use sakila;
-- 1a. Display the first and last names of all actors from the table `actor`.

select first_name, last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.

select upper(concat(first_name, ',', last_name)) as Actor_Name  from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_ID, first_name, last_name from actor where first_name ="Joe";

-- 2b. Find all actors whose last name contain the letters `GEN`:
select actor_ID, first_name, last_name from actor where last_name  like "%GEN%";

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
select actor_ID, first_name, last_name from actor where last_name  like "%LI%" order by 3,2;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select  country_id, country from country where country in ('Afghanistan', 'Bangladesh',  'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).

alter table `sakila`.`actor` 
add column `description` blob null after `last_update`;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
alter table `sakila`.`actor` 
drop column `description`; 

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(*) as num from actor
	group by last_name
	order by count(*) desc;
    
-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(*) as num from actor
	group by last_name
	having count(last_name) > 1
	order by count(*) desc;  
    
-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
select actor_id, first_name, last_name from actor
	where last_name = ("Williams") and first_name = ("Groucho");
    
update actor
	set first_name = ("HARPO")
    where actor_id = 172;
    
select actor_id, first_name, last_name from actor
	where actor_id = 172;
    
-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
update actor
	set first_name = ("GROUCHO")
    where actor_id = 172;
    
    
select actor_id, first_name, last_name from actor
	where actor_id = 172;
    
-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?

  -- Hint: <https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html>
desc sakila.address;
explain sakila.address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
select first_name, last_name, address from staff s 
inner join address a on s.address_id = a.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
select p.staff_id, first_name, last_name,sum(amount) from staff s
inner join payment p on s.staff_id = p.staff_id
where payment_date between '2005-08-01' and '2005-08-31'
group by p.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
select film.film_id, film.title, count(film_actor.actor_id) AS total_actors
from film
inner join film_actor
on film.film_id = film_actor.film_id
group by 1; 
-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
select title, count(film.film_id) as total_copies
from film 
	join inventory on film.film_id = inventory.film_id where title = "Hunchback Impossible"
group by title;
-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
select c.customer_id, c.first_name, c.last_name, sum(p.amount) as total_payments
from customer c
inner join payment p
on c.customer_id = p.customer_id
group by 1
order by last_name asc; 

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
select title
from film 
where (title like "K%" or title like "%Q") and language_id in
(
select language_id
from language where name = "English"
);
-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
 select first_name, last_name
 from actor
 where actor_id in
 (
 select actor_id
  from film_actor
  where film_id in
  (
    select film_id
    from film 
    where title = 'Alone Trip'
  ));
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select first_name, last_name, email
from customer
	join address using (address_id)
    join city using (city_id)
    join country using (country_id) where country = "Canada";

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select title, film_id
from film
where film_id in
(
select film_id
from film_category
where category_id in
(
select category_id 
from category
where name = "Family"
));

-- 7e. Display the most frequently rented movies in descending order.
select inventory_id, count(inventory_id) as total_rentals
from rental 
group by inventory_id
order by total_rentals desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select store_id, sum(amount) as total_revenue
from store
	join inventory using (store_id)
    join rental using (inventory_id)
    join payment using (rental_id)
group by store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select store_id, city, country 
from address
	join store using (address_id)
    join city using (city_id)
    join country using (country_id)
group by 1;

-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select name as genre, sum(amount) as gross_revenue
from category
    join film_category using (category_id)
    join inventory using (film_id)
    join rental using (inventory_id)
    join Payment using (rental_id)
group by genre
order by gross_revenue desc
limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create view top_five_genres as  	
    select name as genre, sum(amount) as gross_revenue
	from category
		join film_category using (category_id)
		join inventory using (film_id)
		join rental using (inventory_id)
		join Payment using (rental_id)
	group by genre
	order by gross_revenue desc
	limit 5;



-- 8b. How would you display the view that you created in 8a?
Select * from top_five_genres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
drop view top_five_genres;
