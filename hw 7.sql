# Unit 10 Assignment - SQL

### Create these queries to develop greater fluency in SQL, an important database language.

# * 1a. Display the first and last names of all actors from the table `actor`.
select first_name, last_name
from actor;
# * 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
select concat(first_name, ' ', last_name) AS 'Actor NAME' FROM actor;

# * 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

select actor_id,first_name,last_name
from actor
where first_name like '%Joe%';
# * 2b. Find all actors whose last name contain the letters `GEN`:
select *
from actor
where last_name like '%GEN%';
# * 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
select *
from actor
where last_name like '%LI%'
order by last_name ,first_name
;
# * 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country
from country
where country 
in ("Afghanistan", "Bangladesh","China");
# * 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
alter table actor
  ADD description BLOB;
# * 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
alter table actor
  drop column description;
# * 4a. List the last names of actors, as well as how many actors have that last name.
select last_name,count(*)
from actor
group by last_name
;
# * 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors.
select last_name, count(*) 
from actor
group by last_name
having count(*) > 2
;
# * 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
set SQL_SAFE_UPDATES = 0;
update actor
set first_name = "HARPO"
where first_name = "GROUCHO" and last_name = "WILLIAMS"
;

#* 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
update actor
set first_name = "HARPO"
where first_name = "HARPO" and last_name = "WILLIAMS"
;

# * 5a. You cannot locate the schema of the `address` table. Which query would you use 
# to re-create it?
create table address3 (
  `address_id` smallint(5) not null,
  `address` varchar(50) not null,
  `address2` varchar(50) null,
  `district` varchar(20) not null,
  `city_id` smallint(5) not null,
  `postal_code` varchar(10) not null,
  `phone` varchar(20) not null,
   `last_update` timestamp default current_timestamp

);

# * 6a. Use `JOIN` to display the first and last names, 
# as well as the address, of each staff member. Use the tables `staff` and `address`:

select first_name, last_name, address 
from staff join address
where staff.address_id = address.address_id;
# * 6b. Use `JOIN` to display the total amount rung up by each 
# staff member in August of 2005. Use tables `staff` and `payment`
select staff.staff_id,sum(payment.amount)
from staff join payment
where staff.staff_id = payment.staff_id
and (MONTH(payment.payment_date) = 8 AND YEAR(payment.payment_date) = 2005)
group by staff.staff_id
;
# * 6c. List each film and the number of actors who are listed for that film.
# Use tables `film_actor` and `film`. Use inner join.

select title, count(*)
from film_actor  left join film
on film_actor.film_id = film.film_id
group by title
;
# * 6d. How many copies of the film `Hunchback Impossible` exist 
# in the inventory system?
select film.title,count(*)
from film  left join inventory
on film.film_id = inventory.film_id
where film.title = "Hunchback Impossible"
;
# * 6e. Using the tables `payment` and `customer` and the `JOIN` command
# , list the total paid by each customer. List the customers alphabetically 
# by last name:
select first_name, last_name,customer.customer_id,sum(payment.amount) as total
from customer join payment
where customer.customer_id = payment.customer_id
group by customer.customer_id
order by last_name
;

# * 7a. The music of Queen and Kris Kristofferson have seen an 
# unlikely resurgence. As an unintended consequence, films
#  starting with the letters `K` and `Q` have also soared in popularity. 
# Use subqueries to display the titles of movies starting with the letters
#  `K` and `Q` whose language is English.

select title, name as language
from
(select language_id, name from sakila.language where sakila.language.name = "English") t1
inner join
(select title, language_id from film where title like  'K%' or title like 'Q%') t2
on t1.language_id = t2.language_id
;

# * 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
select *
from
(select title, actor_id
from film_actor  left join film
on film_actor.film_id = film.film_id
where film.title = "Alone Trip") f
inner join
(select *
from actor)  a
on a.actor_id = f.actor_id
;

# * 7c. You want to run an email marketing campaign in Canada,
#  for which you will need the names and email addresses of all Canadian customers.
#  Use joins to retrieve this information.

select *
from
(select address.city_id, customer.email
from customer
join address
on customer.address_id = address.address_id) f
inner join
(select city.city_id, country.country
from country
join city
on country.country_id = city.country_id where country.country = "Canada")  a
on a.city_id = f.city_id
;

# * 7d. Sales have been lagging among young families, and you wish to target all 
# family movies for a promotion. Identify all movies categorized as _family_ films.

select title, name as category
from
(select title, film_id
from film) f
inner join
(
select film_category.film_id, category.category_id, category.name
from film_category join category
on film_category.category_id = category.category_id
where category.name = "Family"
)  c
on f.film_id = c.film_id
;

# * 7e. Display the most frequently rented movies in descending order.

select f.film_id, c.title, count(f.film_id) as rented
from
(select film_id,rental_id
from rental join inventory
on rental.inventory_id = inventory.inventory_id) f
inner join
(
select film_id, title
from film
)  c
on f.film_id = c.film_id
group by f.film_id
order by  rented desc
;
# * 7f. Write a query to display how much business, in dollars, each store brought in.

select store_id, sum(amount) as total
from
(select store.store_id, inventory.inventory_id
from store join inventory
on store.store_id = inventory.store_id) f
inner join
(
select rental.rental_id, rental.inventory_id, payment.amount
from rental join payment
on rental.rental_id = payment.rental_id
)  c
on f.inventory_id = c.inventory_id
group by store_id
;

# * 7g. Write a query to display for each store its store ID, city, and country.


select address_id, city, country
from
(select address.address_id, address.city_id
from store join
address 
on store.address_id = address.address_id) st
join
(select city.city_id, city.city, country.country
from city join country
on city.country_id = country.country_id) ct
on st.city_id = ct.city_id;
# * 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)


select genre, sum(amount) as totalrevinue from
(select f.film_id,c.amount
from
(select inventory.inventory_id, inventory.film_id
from  inventory
) f
inner join
(
select rental.rental_id, rental.inventory_id, payment.amount
from rental join payment
on rental.rental_id = payment.rental_id
)  c
on f.inventory_id = c.inventory_id) ft
join
(select f.film_id, f.title, c.name as genre
from
(select title, film_id
from film) f
inner join
(
select film_category.film_id, category.category_id, category.name
from film_category join category
on film_category.category_id = category.category_id
)  c
on f.film_id = c.film_id) st
on ft.film_id = st.film_id
group by genre
order by totalrevinue desc limit 5
;



# * 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
# Use the solution from the problem above to create a view. 
# If you haven't solved 7h, you can substitute another query to create a view.
create view top_total_rev
as
(
select genre, sum(amount) as totalrevinue from
(select f.film_id,c.amount
from
(select inventory.inventory_id, inventory.film_id
from  inventory
) f
inner join
(
select rental.rental_id, rental.inventory_id, payment.amount
from rental join payment
on rental.rental_id = payment.rental_id
)  c
on f.inventory_id = c.inventory_id) ft
join
(select f.film_id, f.title, c.name as genre
from
(select title, film_id
from film) f
inner join
(
select film_category.film_id, category.category_id, category.name
from film_category join category
on film_category.category_id = category.category_id
)  c
on f.film_id = c.film_id) st
on ft.film_id = st.film_id
group by genre
order by totalrevinue desc limit 5
);


# * 8b. How would you display the view that you created in 8a?
select * from
top_total_rev;
# * 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
drop view top_total_rev;

## Uploading Homework

* To submit this homework using BootCampSpot:

  * Create a GitHub repository.
  * Upload your .sql file with the completed queries.
  * Submit a link to your GitHub repo through BootCampSpot.
