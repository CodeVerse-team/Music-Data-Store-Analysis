# Music-Data-Store-Analysis
Music Data Store Analysis

SQL Project: Music Store Database Analysis
This project demonstrates a comprehensive understanding of SQL, from basic to advanced queries, using a music store database. The queries are organized into three levels of difficulty: Easy, Moderate, and Advanced. Each query addresses a specific business question, showcasing skills in filtering, joining, grouping, and advanced window functions.
Project Overview
The project involves analyzing a music store database to extract meaningful insights, such as identifying top customers, popular genres, and artist performance. The queries are designed to solve real-world business problems, such as planning promotional events and understanding customer spending patterns.
Easy Questions
Q1: Senior Most Employee Based on Job Title
Find the employee with the highest job level.
SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1

Q2: Countries with the Most Invoices
Identify the countries with the highest number of invoices.
SELECT COUNT(*) AS invoice_count, billing_country
FROM invoice
GROUP BY billing_country
ORDER BY invoice_count DESC

Q3: Top 3 Invoice Totals
Retrieve the top three invoices with the highest totals.
SELECT * FROM invoice
ORDER BY total DESC
LIMIT 3

Q4: City with the Best Customers
Determine the city with the highest sum of invoice totals for a promotional music festival.
SELECT SUM(total) AS invoice_total, billing_city
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total DESC
LIMIT 1

Q5: Best Customer
Identify the customer who has spent the most money.
SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) AS total
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total DESC
LIMIT 1

Moderate Questions
Q1: Rock Music Listeners
Return the email, first name, last name, and genre of all rock music listeners, ordered alphabetically by email.
SELECT DISTINCT c.email, c.first_name, c.last_name
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
WHERE il.track_id IN (
    SELECT t.track_id FROM track t
    JOIN genre g ON t.genre_id = g.genre_id
    WHERE g.name LIKE 'Rock'
)
ORDER BY c.email

Q2: Top 10 Rock Bands
Identify the artists with the most rock tracks in the dataset.
SELECT a.artist_id, a.name, COUNT(a.artist_id) AS number_of_songs
FROM track t
JOIN album alb ON alb.album_id = t.album_id
JOIN artist a ON a.artist_id = alb.artist_id
JOIN genre g ON g.genre_id = t.genre_id
WHERE g.name LIKE 'Rock'
GROUP BY a.artist_id, a.name
ORDER BY number_of_songs DESC
LIMIT 10

Q3: Tracks Longer Than Average
Return track names and durations for songs longer than the average song length, ordered by duration (longest first).
SELECT name, milliseconds
FROM track
WHERE milliseconds > (
    SELECT AVG(milliseconds) AS avg_track_length
    FROM track
)
ORDER BY milliseconds DESC

Advanced Questions
Q1: Customer Spending on Top Artist
Find the amount spent by each customer on the best-selling artist.
WITH best_selling_artist AS (
    SELECT a.artist_id, a.name AS artist_name,
           SUM(il.unit_price * il.quantity) AS total_sales
    FROM invoice_line il
    JOIN track t ON t.track_id = il.track_id
    JOIN album alb ON alb.album_id = t.album_id
    JOIN artist a ON a.artist_id = alb.artist_id
    GROUP BY a.artist_id, a.name
    ORDER BY total_sales DESC
    LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name,
       SUM(il.unit_price * il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY amount_spent DESC

Q2: Most Popular Genre by Country
Identify the most popular music genre for each country based on purchase count, including ties.
WITH popular_genre AS (
    SELECT COUNT(il.quantity) AS purchases, c.country,
           g.name, g.genre_id,
           ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) AS RowNo
    FROM invoice_line il
    JOIN invoice i ON i.invoice_id = il.invoice_id
    JOIN customer c ON c.customer_id = i.customer_id
    JOIN track t ON t.track_id = il.track_id
    JOIN genre g ON g.genre_id = t.genre_id
    GROUP BY c.country, g.name, g.genre_id
    ORDER BY c.country ASC, purchases DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1

Q3: Top Customer by Country
Determine the customer(s) who spent the most on music in each country, including ties.
Method 1: Using Recursive CTE
WITH customer_with_country AS (
    SELECT c.customer_id, c.first_name, c.last_name, i.billing_country,
           SUM(i.total) AS total_spending
    FROM invoice i
    JOIN customer c ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, i.billing_country
),
country_max_spending AS (
    SELECT billing_country, MAX(total_spending) AS max_spending
    FROM customer_with_country
    GROUP BY billing_country
)
SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
FROM customer_with_country cc
JOIN country_max_spending ms ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY cc.billing_country

Method 2: Using Window Function
WITH customer_with_country AS (
    SELECT c.customer_id, c.first_name, c.last_name, i.billing_country,
           SUM(i.total) AS total_spending,
           ROW_NUMBER() OVER(PARTITION BY i.billing_country ORDER BY SUM(i.total) DESC) AS RowNo
    FROM invoice i
    JOIN customer c ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, i.billing_country
    ORDER BY i.billing_country ASC, total_spending DESC
)
SELECT * FROM customer_with_country WHERE RowNo <= 1

Conclusion
This project demonstrates proficiency in SQL through a range of queries that analyze a music store database. From simple aggregations to complex joins and window functions, the queries provide actionable insights for business decisions, such as identifying top customers, popular genres, and promotional opportunities.
