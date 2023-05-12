-- 1. How many pizzas were ordered?

SELECT COUNT(*) AS Total_pizza_orders
FROM [dbo].[customer_orders]

-----------------------------------------------------
--2. How many unique customer orders were made?
SELECT 
	COUNT(DISTINCT order_id) AS Unique_customer_orders
FROM [dbo].[customer_orders]

-----------------------------------------------------------

-- 3. How many successful orders were delivered by each runner?

--- replace 'null' with NULL in runner_orders table and update 

UPDATE runner_orders
SET cancellation = 
	CASE WHEN cancellation= 'null' OR cancellation ='' THEN REPLACE(cancellation,'null',NULL)
		ELSE cancellation
	END 



SELECT 
	runner_id,
	COUNT(DISTINCT order_id) AS total_successful_orders
FROM [dbo].[runner_orders]
WHERE cancellation IS NULL --> sucessfully delivered 
GROUP BY runner_id

--------------------------------------------------------------
-- 4. How many of each type of pizza was delivered?


SELECT 
	pizza.pizza_name,
	COUNT(customer.order_id) AS ordered_times
FROM [dbo].[customer_orders] customer
INNER JOIN [dbo].[runner_orders] runner
	ON customer.order_id = runner.order_id 
INNER JOIN [dbo].[pizza_names] pizza
	ON customer.pizza_id = pizza.pizza_id
WHERE runner.cancellation IS NULL 
GROUP BY pizza.pizza_name


-------------------------------------------------------
-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT 
	customer.customer_id,
	pizza.pizza_name,
	SUM(customer.order_id ) OVER (PARTITION BY customer_id,pizza_name) 
FROM [dbo].[customer_orders] customer
INNER JOIN [dbo].[pizza_names] pizza
	ON customer.pizza_id = pizza.pizza_id
--GROUP BY customer.customer_id, 	pizza.pizza_name






6. What was the maximum number of pizzas delivered in a single order?
7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
8. How many pizzas were delivered that had both exclusions and extras?
9. What was the total volume of pizzas ordered for each hour of the day?
10. What was the volume of orders for each day of the week?
