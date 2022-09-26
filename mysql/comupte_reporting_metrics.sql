USE demo_sales;
DELIMITER //
DROP PROCEDURE IF EXISTS comupte_reporting_metrics;
CREATE PROCEDURE comupte_reporting_metrics(
	p_date_agg_type VARCHAR(16),
    p_date_agg VARCHAR(16),
    p_start_date DATE,
    p_end_date DATE)
BEGIN
SET SQL_SAFE_UPDATES = 0;
/*
The Stored Procedure does the following:
1. Create a temp table of the specified start and end, compute the KPI metrics
2. Remove from demo_sales.reporting_metrics of the p_date_agg_type and the p_date_agg
3. Insert into demo_sales.reporting_metrics the temp table from (1)
*/
/*
SET @p_date_agg_type = 'month';
SET @p_date_agg = '2012-01-01';
SET @p_start_date = '2012-01-01';
SET @p_end_date = '2012-01-31';
*/
DROP TEMPORARY TABLE IF EXISTS tmp_metrics;
CREATE TEMPORARY TABLE tmp_metrics 
AS 
SELECT 
	p_date_agg_type AS date_agg_type,
    p_date_agg AS order_date_agg,
    DATEDIFF(p_end_date, p_start_date)+1 AS num_days,
    p_start_date AS date_start,
    p_end_date AS date_end,
    a.market,
    a.region,
    a.state,
    a.country,
    a.city,
    b.segment,
    b.category,
    b.subcategory,
    COUNT(DISTINCT a.order_id) AS order_cnt,
    SUM(a.quantity * b.unit_price) AS revenue,
    COUNT(DISTINCT a.customer_id) AS customer_cnt,
    SUM(shipping_cost) AS shipping_cost,
    COUNT(DISTINCT CASE WHEN order_priority = 'Critical' THEN order_id END) AS critical_orders,
	CAST(NULL AS UNSIGNED) AS new_customer_cnt
FROM demo_sales.orders a
LEFT JOIN demo_sales.product_info b
ON a.product_id = b.product_id
WHERE a.order_date >= p_start_date
AND a.order_date <= p_end_date
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13;

DROP TEMPORARY TABLE IF EXISTS tmp_new_cust;
CREATE TEMPORARY TABLE tmp_new_cust AS 
SELECT 
	market,
    region,
    state,
    country,
    city,
    COUNT(DISTINCT customer_id) AS new_customer_cnt
FROM demo_sales.customer_info
WHERE order_date_first >= p_start_date
AND order_date_first <= p_end_date
GROUP BY 1,2,3,4,5;

UPDATE tmp_metrics a
LEFT JOIN tmp_new_cust b
ON a.market = b.market
AND a.region = b.region
AND a.state = b.state
AND a.country = b.country 
AND a.city = b.city
SET a.new_customer_cnt = b.new_customer_cnt;

DELETE 
FROM demo_sales.reporting_metrics 
WHERE date_agg_type = p_date_agg_type 
AND date_agg = p_date_agg;

INSERT INTO demo_sales.reporting_metrics (
date_agg_type,
date_agg,
num_days,
date_start,
date_end,
market,
region,
state,
country,
city,
segment,
category,
subcategory,
order_cnt,
revenue,
customer_cnt,
shipping_cost,
critical_orders,
new_customer_cnt
)
SELECT 
	date_agg_type,
	order_date_agg,
	num_days,
	date_start,
	date_end,
	market,
	region,
	state,
	country,
	city,
	segment,
	category,
	subcategory,
	order_cnt,
	revenue,
	customer_cnt,
	shipping_cost,
	critical_orders,
	new_customer_cnt
FROM tmp_metrics;
SET SQL_SAFE_UPDATES = 1;

END //
DELIMITER ;

/*

USE demo_sales;
CALL comupte_reporting_metrics('Month', '2012-01-01', '2012-01-01', '2012-01-31');
CALL comupte_reporting_metrics('Month', '2012-02-01', '2012-02-01', '2012-02-29');
CALL comupte_reporting_metrics('Month', '2012-03-01', '2012-03-01', '2012-03-31');
CALL comupte_reporting_metrics('Month', '2012-04-01', '2012-04-01', '2012-04-30');
CALL comupte_reporting_metrics('Month', '2012-05-01', '2012-05-01', '2012-05-31');
CALL comupte_reporting_metrics('Month', '2012-06-01', '2012-06-01', '2012-06-30');
CALL comupte_reporting_metrics('Month', '2012-07-01', '2012-07-01', '2012-07-31');
CALL comupte_reporting_metrics('Month', '2012-08-01', '2012-08-01', '2012-08-31');
CALL comupte_reporting_metrics('Month', '2012-09-01', '2012-09-01', '2012-09-30');
CALL comupte_reporting_metrics('Month', '2012-10-01', '2012-10-01', '2012-10-31');
CALL comupte_reporting_metrics('Month', '2012-11-01', '2012-11-01', '2012-11-30');
CALL comupte_reporting_metrics('Month', '2012-12-01', '2012-12-01', '2012-12-31');

CALL comupte_reporting_metrics('Quarter', '2012-Q1', '2012-01-01', '2012-03-31');
CALL comupte_reporting_metrics('Quarter', '2012-Q2', '2012-04-01', '2012-06-30');
CALL comupte_reporting_metrics('Quarter', '2012-Q3', '2012-07-01', '2012-09-30');
CALL comupte_reporting_metrics('Quarter', '2012-Q4', '2012-10-01', '2012-12-31');

CALL comupte_reporting_metrics('Month', '2013-01-01', '2013-01-01', '2013-01-31');
CALL comupte_reporting_metrics('Month', '2013-02-01', '2013-02-01', '2013-02-28');
CALL comupte_reporting_metrics('Month', '2013-03-01', '2013-03-01', '2013-03-31');
CALL comupte_reporting_metrics('Month', '2013-04-01', '2013-04-01', '2013-04-30');
CALL comupte_reporting_metrics('Month', '2013-05-01', '2013-05-01', '2013-05-31');
CALL comupte_reporting_metrics('Month', '2013-06-01', '2013-06-01', '2013-06-30');
CALL comupte_reporting_metrics('Month', '2013-07-01', '2013-07-01', '2013-07-31');
CALL comupte_reporting_metrics('Month', '2013-08-01', '2013-08-01', '2013-08-31');
CALL comupte_reporting_metrics('Month', '2013-09-01', '2013-09-01', '2013-09-30');
CALL comupte_reporting_metrics('Month', '2013-10-01', '2013-10-01', '2013-10-31');
CALL comupte_reporting_metrics('Month', '2013-11-01', '2013-11-01', '2013-11-30');
CALL comupte_reporting_metrics('Month', '2013-12-01', '2013-12-01', '2013-12-31');

CALL comupte_reporting_metrics('Quarter', '2013-Q1', '2013-01-01', '2013-03-31');
CALL comupte_reporting_metrics('Quarter', '2013-Q2', '2013-04-01', '2013-06-30');
CALL comupte_reporting_metrics('Quarter', '2013-Q3', '2013-07-01', '2013-09-30');
CALL comupte_reporting_metrics('Quarter', '2013-Q4', '2013-10-01', '2013-12-31');

*/
SELECT * 
FROM demo_sales.reporting_metrics
WHERE date_agg_type IN ('Quarter', 'Month')