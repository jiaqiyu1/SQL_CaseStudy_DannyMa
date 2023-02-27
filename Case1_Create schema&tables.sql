/*
Create schema and tables, insert values for the tables
*/

----------------------------------------------------
CREATE SCHEMA dannys_diner;


CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');



  ------------------------------------------------------------

/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

--------------------------------------------------------------
-- 1. What is the total amount each customer spent at the restaurant?


-- create a subquery at first and name it 'sub'
-- use created subquery INNER JOIN sales table 

SELECT s.customer_id,SUM(sub.TotalSalesAmount) AS total_salesamount
FROM (
	SELECT 
		s.customer_id, 
		m.price, 
		COUNT(s.order_date) AS quantity,
		m.price* COUNT(s.order_date) AS TotalSalesAmount
	FROM dbo.sales s
	INNER JOIN dbo.menu m
	ON s.product_id = m.product_id
	GROUP BY customer_id,m.price
	) sub

INNER JOIN dbo.sales s
ON sub.customer_id = s.customer_id
GROUP BY s.customer_id

----------------------------------------------------------------------
-- 2. How many days has each customer visited the restaurant?


-- use CAST function to combine Month and Day and change it to string from integer
-- DISTINCT reduce duplicate 

SELECT 
customer_id,
COUNT(DISTINCT(CAST(MONTH(order_date) AS VARCHAR)+CAST(DAY(order_date) AS VARCHAR))) AS times
FROM dbo.sales
GROUP BY customer_id

SELECT *
FROM dbo.sales s
INNER JOIN dbo.menu m
ON s.product_id = m.product_id

--------------------------------------------------------------------------
-- 3. What was the first item from the menu purchased by each customer?

-- used ROW_NUMBER to create index for each customer
--create CTE 
-- fetch first row of each customer ( where RowNumberEachCustomer=1) 

WITH fetch_rows AS
(
	SELECT *,
	ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS RowNumberEachCustomer
	FROM 
		(SELECT 
			s.customer_id, 
			m.product_name,
			s.order_date
		FROM [dbo].[sales] s
			INNER JOIN [dbo].[menu] m
				ON s.product_id = m.product_id

		) AS sales_menu
)

SELECT *
FROM fetch_rows
WHERE RowNumberEachCustomer = 1;

----------------------------------------------------------------------------------

--4. What is the most purchased item on the menu and how many times was it purchased by all customers?

-- create temp table sales left join menu #temp_sales_menu 

DROP TABLE IF EXISTS #temp_sales_menu 

SELECT 
	s.customer_id, 
	m.product_name,
	s.order_date
	INTO #temp_sales_menu

FROM [dbo].[sales] s
	INNER JOIN [dbo].[menu] m
		ON s.product_id = m.product_id


-- create temp table #order_times
DROP TABLE IF EXISTS #order_times

SELECT *,
COUNT(product_name) OVER (PARTITION BY product_name) AS total_ordered_times_each_product
	INTO #order_times
FROM #temp_sales_menu

-- pick up the max order_times by subquery 
SELECT DISTINCT product_name,total_ordered_times_each_product
FROM #order_times
WHERE total_ordered_times_each_product IN 
	(SELECT 
		MAX(total_ordered_times_each_product)
	FROM #order_times)
----------------------------------------------------------------------------------
-- 5. Which item was the most popular for each customer?

--create a temp table for how many times of each product had been ordered by each customer
DROP TABLE IF EXISTS  #order_times_each_customer_table

SELECT *,
COUNT(product_name) OVER (PARTITION BY customer_id, product_name) AS ordered_times_each_customer
	INTO #order_times_each_customer_table
FROM #temp_sales_menu;

SELECT *
FROM #order_times_each_customer_table

--create a temp table for the largest ordered product by each customer 

DROP TABLE IF EXISTS #max_ordered_table

SELECT
	customer_id, 
	product_name, 
	MAX(ordered_times_each_customer) AS max_ordered_times_each_customer

	INTO #max_ordered_table

	FROM #order_times_each_customer_table
	GROUP BY customer_id, product_name
	ORDER BY customer_id, max_ordered_times_each_customer DESC
--create a tmep table for get rownumber 

DROP TABLE IF EXISTS #favourite_table

SELECT 
	customer_id,
	product_name,
	max_ordered_times_each_customer,
	ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY customer_id DESC) AS rownumber

	INTO #favourite_table

FROM #max_ordered_table
	

SELECT 
	customer_id,
	product_name
FROM #favourite_table
WHERE 
	(rownumber = 1 AND customer_id IN ('A','C') )
	OR customer_id = 'B'

-----------------------------------------------------------------------------
-- 6. Which item was purchased first by the customer after they became a member?

--create CTE to combine 3 tables
WITH CTE_sales_member_menu AS 
(
    SELECT 
		s.customer_id, 
		s.order_date,
		s.product_id,
		m.product_name,
		m.price, 
		mem.join_date
    FROM [dbo].[sales] s
    INNER JOIN  [dbo].[menu] m ON s.product_id = m.product_id
    INNER JOIN [dbo].[members] mem ON mem.customer_id = s.customer_id
)	

--create rownumber 

SELECT 
	customer_id,
	join_date,
	order_date,
	product_name,
	ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS rownumber
	INTO #rownumbertable
FROM CTE_sales_member_menu
WHERE order_date >= join_date

-- rownumber =1 
SELECT 
	customer_id,
	product_name
FROM #rownumbertable
WHERE rownumber = 1

------------------------------------------------------------------

-- 7. Which item was purchased just before the customer became a member?

-- create a temp table to combine 3 tables

DROP TABLE IF EXISTS #sales_member_menu
SELECT 
	s.customer_id, 
	s.order_date,
	s.product_id,
	m.product_name,
	m.price, 
	mem.join_date
INTO #sales_member_menu
FROM [dbo].[sales] s
INNER JOIN  [dbo].[menu] m ON s.product_id = m.product_id
INNER JOIN [dbo].[members] mem ON mem.customer_id = s.customer_id


-- create a temp table for rownumber

DROP TABLE IF EXISTS #rownumbertable2;

SELECT 
	customer_id,
	join_date,
	order_date,
	product_name,
	ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) AS rownumber
INTO #rownumbertable2
FROM #sales_member_menu
WHERE order_date IN (
	SELECT DATEADD(DAY, -2, join_date)
	FROM #sales_member_menu
	UNION 
	SELECT join_date
	FROM #sales_member_menu
);

select 
product_name
FROM #rownumbertable2

-------------------------------------------------------------------------

