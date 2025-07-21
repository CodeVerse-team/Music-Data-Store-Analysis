# EASY QUESTIONS

Q1: Who is the senior most employee based on job Title?

```sql
select * from employee
ORDER BY levels desc
limit 1
```

Q2: Which Countries have the most Invoices?

```sql
select count(*) as ascd, billing_country
from invoice
group by billing_country
order by ascd desc
```

Q3 What are the Top 3 values of total invoice?

```sql
Select * from invoice
order by total desc
limit 3
```

Q4 Which City has the best customers? We would like to throw a promotional Music Festival in the City we made the most money, write a query that returns one city that has the hightes sum of invoice totals, Return both the City name and sum of all invoice totals.

```sql
select sum(total) as invoice_total, billing_city
from invoice
group by billing_city
order by invoice_total desc
```

Q5 Who is the Best Customer? The Customers who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money.