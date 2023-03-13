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

--------------------------------------------------------------------------------------------------------------
-- 1. What is the total amount each customer spent at the restaurant?

SELECT 
	sales.customer_id,
	SUM(menu.price) AS total_amount
FROM [dbo].[sales] sales
	INNER JOIN [dbo].[menu] menu
		ON sales.product_id = menu.product_id
GROUP BY sales.customer_id


------------------------------------------------------------------------
-- 2. How many days has each customer visited the restaurant?


-- use CAST function to combine Month and Day and change it to string from integer
-- DISTINCT reduce duplicate 

SELECT 
customer_id,
COUNT(DISTINCT(CAST(MONTH(order_date) AS VARCHAR)+CAST(DAY(order_date) AS VARCHAR))) AS times
FROM [dbo].[sales]
GROUP BY customer_id

---------------------------------------------------------------------------------
-- 3. What was the first item from the menu purchased by each customer?

WITH fetch_rows AS
(
	SELECT *,
	RANK() OVER (PARTITION BY customer_id ORDER BY order_date) AS order_rank
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

SELECT DISTINCT customer_id,product_name
FROM fetch_rows
WHERE order_rank= 1;


-----------------------------------------------------------------------------------

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

--Solution 1

-- create temp table sales inner join menu #temp_sales_menu 

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



-- Solution2 ( more concise) 
SELECT
	TOP 1 -- just pick up the first row 
	menu.product_name,
	COUNT(*) AS total_purchases -- calculate all rows of a table
FROM [dbo].[sales] sales
	INNER JOIN [dbo].[menu] menu
		ON sales.product_id = menu.product_id
GROUP BY menu.product_name
ORDER BY total_purchases DESC



-------------------------------------------------------------------------------

-- 5. Which item was the most popular for each customer?


-- Create a temporary table to store the item counts for each customer and product combination

DROP TABLE IF EXISTS #customer_items
SELECT
  sales.customer_id,
  menu.product_name,
  COUNT(*) AS item_quantity
INTO #customer_items
FROM [dbo].[sales] sales
INNER JOIN [dbo].[menu] menu
  ON sales.product_id = menu.product_id
GROUP BY sales.customer_id, menu.product_name;

-- Create a temporary table to store the ranked items for each customer

DROP TABLE IF EXISTS #ranked_customer_items

SELECT
  customer_id,
  product_name,
  item_quantity,
  RANK() OVER (
    PARTITION BY customer_id
    ORDER BY item_quantity DESC
  ) AS item_rank
INTO #ranked_customer_items
FROM #customer_items;

-- Select the top-ranked item for each customer

SELECT
  customer_id,
  product_name,
  item_quantity
FROM #ranked_customer_items
WHERE item_rank = 1;



--------------------------------------------------------------
-- 6. Which item was purchased first by the customer after they became a member?
	--and what date was it? (including the date they joined)

--create rownumber 

DROP TABLE IF EXISTS #rownumbertable

SELECT 
	customer_id,
	join_date,
	order_date,
	product_name,
	ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS rownumber
	INTO #rownumbertable
FROM #sales_member_menu
WHERE order_date >= join_date

-- rownumber =1 
SELECT 
	customer_id,
	order_date,
	product_name
FROM #rownumbertable
WHERE rownumber = 1

-----------------------------------------------------------

-- 7. Which item(s) was purchased just before the customer became a member and when?

-- create a temp table for rownumber

DROP TABLE IF EXISTS #rownumbertable2;

SELECT 
	customer_id,
	join_date,
	order_date,
	product_name,
	RANK() OVER (PARTITION BY customer_id ORDER BY order_date DESC) AS order_rank
INTO #rownumbertable2
FROM #sales_member_menu
WHERE order_date < join_date

select * from #rownumbertable2

select 
customer_id,
order_date,
product_name
FROM #rownumbertable2
WHERE order_rank =1

-- 8. What is the total items and amount spent for each member before they became a member?


--creat a temp table for total_ordered_times & total_amount

DROP TABLE IF EXISTS #total_times_amount

SELECT 
	customer_id,
    product_name,
    price,
COUNT(product_name) OVER (PARTITION BY customer_id) AS total_ordered_times,
SUM(COUNT(product_name)*price) OVER (PARTITION BY customer_id) AS total_amount
INTO #total_times_amount

FROM #sales_member_menu
WHERE order_date < join_date
GROUP BY customer_id,product_name,price

--show the final result
SELECT 
DISTINCT customer_id,
total_ordered_times,
total_amount
FROM #total_times_amount


---------------------------------------------------

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?


--create a temp table to calculate ponts from 3 merged table (LEFT JOIN)

DROP TABLE IF EXISTS #points

SELECT 
*,
	CASE
	WHEN product_name ='sushi'THEN price*20
	ELSE price*10
	END AS calculated_points
INTO #points
FROM 
(    SELECT 
		s.customer_id, 
		s.order_date,
		s.product_id,
		m.product_name,
		m.price, 
		mem.join_date
    FROM [dbo].[sales] s
    LEFT JOIN  [dbo].[menu] m ON s.product_id = m.product_id
    LEFT JOIN [dbo].[members] mem ON mem.customer_id = s.customer_id
)	AS smm


--summarize data
SELECT 
customer_id,
SUM(calculated_points) AS total_points
FROM #points
GROUP BY customer_id
ORDER BY total_points DESC

------------------------------------------------------------

-- 10. In the first week after a customer joins the program (including their join date)
--     they earn 2x points on all items, not just sushi
--     how many points do customer A and B have at the end of January?

WITH member_info AS (
    SELECT 
        sales.customer_id,
        order_date,
        join_date,
        product_name,
        price,
        CASE
			WHEN product_name = 'sushi' THEN 2
            WHEN order_date BETWEEN join_date AND DATEADD(DAY, 6, join_date) THEN 2
            ELSE 1
        END AS point_multiplier
    FROM sales
    INNER JOIN menu
        ON sales.product_id = menu.product_id
    INNER JOIN members
        ON sales.customer_id = members.customer_id
    WHERE order_date <= EOMONTH('2021-01-31')
)

SELECT 
    customer_id,
    SUM(price * 10 * point_multiplier) AS points 
FROM member_info
GROUP BY customer_id;



