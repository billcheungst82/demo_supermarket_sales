DROP TABLE IF EXISTS reporting_metrics;
CREATE TABLE IF NOT EXISTS reporting_metrics (
	id INT NOT NULL AUTO_INCREMENT,
    date_agg_type VARCHAR(20) NOT NULL,
    date_agg VARCHAR(20) NOT NULL,
    num_days INT,
    date_start DATE,
    date_end DATE,
	market VARCHAR(40),
    region VARCHAR(40),
    state VARCHAR(40),
    country VARCHAR(40),
    city VARCHAR(40),
    segment VARCHAR(100),
    category VARCHAR(100),
    subcategory VARCHAR(100),
    order_cnt INT,
    revenue DECIMAL(16,4),
    customer_cnt INT,
    shipping_cost DECIMAL(16,4),
    critical_orders INT,
    new_customer_cnt INT, -- "DUPLICATE FOR low hierachy 
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    updated_at TIMESTAMP ON UPDATE CURRENT_TIMESTAMP DEFAULT NULL,
	PRIMARY KEY (id) 
);