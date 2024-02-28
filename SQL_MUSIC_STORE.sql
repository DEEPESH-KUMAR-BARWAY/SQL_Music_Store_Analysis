/* Question Set 1 - Easy */

/* Q1: Who is the senior most employee based on job title? */

SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1;


/* Q2: Which countries have the most Invoices? */

SELECT COUNT(*) AS c, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY c DESC;


/* Q3: What are top 3 values of total invoice? */

SELECT total 
FROM invoice
ORDER BY total DESC
LIMIT 3;


/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT billing_city, SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;


/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT customer.customer_id, first_name, last_name, SUM(total) AS total_spending
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_spending DESC
LIMIT 1;


/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

SELECT DISTINCT email, first_name, last_name, genre.name AS Genre
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoiceline ON invoiceline.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoiceline.track_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name = 'Rock'
ORDER BY email;


/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT artist.artist_id, artist.name, COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name = 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;


/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT name, milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length
	FROM track
)
ORDER BY milliseconds DESC;


/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY artist.artist_id
	ORDER BY total_sales DESC
	LIMIT 1
)
SELECT customer.first_name, customer.last_name, best_selling_artist.artist_name, SUM(invoice_line.unit_price * invoice_line.quantity) AS amount_spent
FROM invoice_line
JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
JOIN customer ON customer.customer_id = invoice.customer_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN best_selling_artist ON best_selling_artist.artist_id = artist.artist_id
GROUP BY customer.customer_id
ORDER BY amount_spent DESC;


/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

WITH Genre_Sales_Per_Country AS (
	SELECT customer.country, genre.name AS top_genre, COUNT(*) AS genre_sales
	FROM invoice
	JOIN customer ON invoice.customer_id = customer.customer_id
	JOIN invoiceline ON invoice.invoice_id = invoiceline.invoice_id
	JOIN track ON invoiceline.track_id = track.track_id
	JOIN genre ON track.genre_id = genre.genre_id
	GROUP BY customer.country, genre.name
),
Max_Genre_Sales_Per_Country AS (
	SELECT country, MAX(genre_sales) AS max_genre_sales
	FROM Genre_Sales_Per_Country
	GROUP BY country
)
SELECT Genre_Sales_Per_Country.country, Genre_Sales_Per_Country.top_genre
FROM Genre_Sales_Per_Country
JOIN Max_Genre_Sales_Per_Country ON Genre_Sales_Per_Country.country = Max_Genre_Sales_Per_Country.country
WHERE Genre_Sales_Per_Country.genre_sales = Max_Genre_Sales_Per_Country.max_genre_sales
ORDER BY Genre_Sales_Per_Country.country;


/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

WITH Customer_Spending_Per_Country AS (
	SELECT customer.country, customer.first_name, customer.last_name, SUM(invoice.total) AS total_spent
	FROM invoice
	JOIN customer ON invoice.customer_id = customer.customer_id
	GROUP BY customer.country, customer.first_name, customer.last_name
),
Max_Spending_Per_Country AS (
	SELECT country, MAX(total_spent) AS max_spending
	FROM Customer_Spending_Per_Country
	GROUP BY country
)
SELECT Customer_Spending_Per_Country.country, Customer_Spending_Per_Country.first_name, Customer_Spending_Per_Country.last_name, Customer_Spending_Per_Country.total_spent
FROM Customer_Spending_Per_Country
JOIN Max_Spending_Per_Country ON Customer_Spending_Per_Country.country = Max_Spending_Per_Country.country
WHERE Customer_Spending_Per_Country.total_spent = Max_Spending_Per_Country.max_spending
ORDER BY Customer_Spending_Per_Country.country;
