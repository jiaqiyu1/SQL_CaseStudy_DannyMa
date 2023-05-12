SELECT * FROM [dbo].[customer_orders]

-- replace 'null' with NULL in exclusions 

UPDATE [dbo].[customer_orders]
SET exclusions = 
	CASE WHEN exclusions ='null' THEN NULL
		 ELSE exclusions
	END 


-- replace 'null' with NULL in extras 

UPDATE [dbo].[customer_orders]
SET extras = 
	CASE WHEN extras ='null' THEN NULL
		 ELSE extras
	END 


--
SELECT 
exclusions,
PARSENAME(REPLACE(exclusions,',','.'),2),
PARSENAME(REPLACE(exclusions,',','.'),1)
FROM [dbo].[customer_orders]
WHERE order_id = 10 AND exclusions IS NOT NULL 


---------------------------------
