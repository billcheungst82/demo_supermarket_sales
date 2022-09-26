
CREATE TABLE IF NOT EXISTS orders (
	id INT NOT NULL AUTO_INCREMENT,
    order_id VARCHAR(40) NOT NULL,
    order_date DATE,
    market VARCHAR(40),
    customer_id VARCHAR(40),
    customer_name VARCHAR(100),
    product_id VARCHAR(40),
    quantity INT, 
    discount DECIMAL(12,4),
    region VARCHAR(40),    
    state VARCHAR(40),
    country VARCHAR(60),
    city VARCHAR(60),
    postal_code VARCHAR(20), 
	order_priority VARCHAR(40), 
    ship_mode VARCHAR(40),
    ship_date DATE,
    shipping_cost DECIMAL(12,4),
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    updated_at TIMESTAMP NOT NULL ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (id) 
);