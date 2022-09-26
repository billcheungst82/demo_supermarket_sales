USE demo_sales;
DELIMITER //
DROP PROCEDURE IF EXISTS comupte_daily_new_users;
CREATE PROCEDURE comupte_daily_new_users(p_date DATE)
BEGIN

/*
The Stored Procedure does the following:
1. Get new users from p_date - 3days to p_date and insert to demo_sales.customer_info
2. Compute all customers' new profile an update to demo_sales.customer_info
*/
	/* #1a Get last 3 days new users (customer_ids' dont appear in demo_sales.customer_info) */
  	DROP TEMPORARY TABLE IF EXISTS tmp_new_cust;
	CREATE TEMPORARY TABLE tmp_new_cust 
	AS 
	SELECT 
		a.customer_id,
		MIN(a.order_date) AS order_date_first,
		MAX(a.order_date) AS order_date_last,
		MAX(a.customer_name) AS customer_name,
        MAX(a.market) AS market,
        MAX(a.region) AS region,
        MAX(a.state) AS state,
		MAX(a.country) AS country,
		MAX(a.city) AS city
	FROM demo_sales.orders a
	LEFT JOIN demo_sales.customer_info b
	ON a.customer_id = b.customer_id
	WHERE a.order_date <= p_date
	AND a.order_date > DATE_ADD(p_date,INTERVAL -3 DAY)
	AND b.customer_id IS NULL
	GROUP BY 1;

	/* #1b Insert above to demo_sales.customer_info */
	INSERT INTO demo_sales.customer_info (
	customer_id,
	customer_name,
    market,
    region,
    state,
	country,
	city,
	insert_by
	)
	SELECT 
		customer_id,
		customer_name,
		market,
		region,
		state,
		country,
		city,
		CONCAT('CALL ', 'comupte_daily_new_users(', p_date, ');') AS insert_by
	FROM tmp_new_cust;

	/* #2 Get all customer profile based on p_date */
 	DROP TEMPORARY TABLE IF EXISTS tmp_cust_profile;
	CREATE TEMPORARY TABLE tmp_cust_profile 
	AS 
	SELECT 
		a.customer_id,
		MIN(a.order_date) AS order_date_first,
		MAX(a.order_date) AS order_date_last,
		SUM(b.unit_price * a.quantity) AS ttl_spending,
		COUNT(DISTINCT a.order_id) AS ttl_order_cnt,
		SUM(CASE WHEN a.order_date <= p_date AND a.order_date > DATE_ADD(p_date,INTERVAL -30 DAY) THEN b.unit_price*a.quantity ELSE 0 END) AS prev_30d_spending,
		SUM(CASE WHEN a.order_date <= p_date AND a.order_date > DATE_ADD(p_date,INTERVAL -90 DAY) THEN b.unit_price*a.quantity ELSE 0 END) AS prev_90d_spending,
		SUM(CASE WHEN a.order_date <= p_date AND a.order_date > DATE_ADD(p_date,INTERVAL -365 DAY) THEN b.unit_price*a.quantity ELSE 0 END) AS prev_365d_spending
	FROM demo_sales.orders a
	LEFT JOIN demo_sales.product_info b
	ON a.product_id = b.product_id
	WHERE a.order_date <= p_date
	GROUP BY 1;
    
    CREATE INDEX cid_idx ON tmp_cust_profile (customer_id);  
    
	/* #2 Update customer profiles in demo_sales.customer_info */
	SET SQL_SAFE_UPDATES = 0;
	UPDATE demo_sales.customer_info a
	JOIN tmp_cust_profile b
	ON a.customer_id = b.customer_id
	SET a.order_date_first = b.order_date_first,
	a.order_date_last = b.order_date_last,
	a.ttl_spending = b.ttl_spending,
	a.ttl_order_cnt = b.ttl_order_cnt,
	a.prev_30d_spending = b.prev_30d_spending,
	a.prev_90d_spending = b.prev_90d_spending,
	a.prev_365d_spending = b.prev_365d_spending;
	SET SQL_SAFE_UPDATES = 1;
END //

DELIMITER ;