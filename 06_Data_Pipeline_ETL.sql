-- Etape 6 : Optimisation Pipeline - Data Enginneering
 
CREATE SCHEMA IF NOT EXISTS staging;      -- le dossier pour les nettoyages
CREATE SCHEMA IF NOT EXISTS analytics;    -- le dossier pour les tables finales

-- Création de staging customers
CREATE OR REPLACE VIEW staging.stg_customers AS 
SELECT
    customer_id,
    UPPER(LEFT(first_name, 1)) || LOWER(SUBSTRING(first_name, 2)) AS first_name,
    UPPER(LEFT(last_name, 1)) || LOWER(SUBSTRING(last_name, 2)) AS last_name,
    LOWER(TRIM(email)) AS email,
    phone,
    UPPER(country) AS country,
    CAST(created_at AS DATE)  AS created_at,
    CASE 
        WHEN LOWER(CAST(is_active AS VARCHAR)) IN ('1','true','yes','active') THEN true 
        ELSE false    
    END AS is_active,
    CURRENT_TIMESTAMP AS processed_at
FROM customers
WHERE customer_id IS NOT NULL;

-- Création de staging orders
CREATE OR REPLACE VIEW staging.stg_orders AS
SELECT 
    order_id,
    customer_id,
    CAST(order_date AS DATE) AS order_date,
    LOWER(CAST(status AS VARCHAR)) AS status,
    CASE 
        WHEN total_amount < 0 THEN 0 
        ELSE total_amount 
    END AS total_amount,
    UPPER(shipping_country) AS shipping_country,
    CURRENT_TIMESTAMP AS processed_at
FROM orders
WHERE order_id IS NOT NULL;

-- Création de staging order_items 
CREATE OR REPLACE VIEW staging.stg_order_items AS
SELECT 
    order_item_id,
    order_id,
    product_id,
    CASE 
        WHEN quantity < 0 THEN 0
        ELSE quantity 
    END AS quantity,
    CASE 
        WHEN unit_price < 0 THEN 0
        ELSE unit_price 
    END AS unit_price,
    ROUND(quantity * unit_price, 2) AS line_item_amount,
    CURRENT_TIMESTAMP AS processed_at
FROM order_items
WHERE order_item_id IS NOT NULL; 

-- Création de staging products
CREATE OR REPLACE VIEW staging.stg_products AS
SELECT
    product_id, 
    seller_id, 
    UPPER(LEFT(name, 1)) || LOWER(SUBSTRING(name, 2)) AS name,
    CAST(category AS VARCHAR) AS category,
    CASE
        WHEN price < 0 THEN 0 
        ELSE price 
    END AS price,
    CAST(created_at AS DATE) AS created_at,
    CURRENT_TIMESTAMP AS processed_at
FROM products
WHERE product_id IS NOT NULL; 

-- Création de staging payments
CREATE OR REPLACE VIEW staging.stg_payments AS
SELECT
    payment_id,
    order_id,
    LOWER(CAST(payment_method AS VARCHAR)) AS payment_method,
    CASE
        WHEN amount < 0 THEN 0
        ELSE amount
    END AS amount, 
    LOWER(CAST(payment_status AS VARCHAR)) AS payment_status,
    CAST(payment_date AS DATE) AS payment_date,
    CURRENT_TIMESTAMP AS processed_at
FROM payments
WHERE payment_id IS NOT NULL; 

-- Création de staging returns
CREATE OR REPLACE VIEW staging.stg_returns AS
SELECT 
    return_id,
	order_id,
	product_id,
    LOWER(CAST(reason AS VARCHAR)) AS reason,
    CAST(return_date AS DATE) AS return_date,
    CASE 
        WHEN LOWER(CAST(refunded AS VARCHAR)) IN ('1','true','yes','active') THEN true
        ELSE false
        END AS refunded,
    CURRENT_TIMESTAMP AS processed_at 
FROM returns
WHERE return_id IS NOT NULL; 

-- Création de staging sellers
CREATE OR REPLACE VIEW staging.stg_sellers AS
SELECT
    seller_id,
    UPPER(LEFT(name, 1)) || LOWER(SUBSTRING(name, 2)) AS name,
    UPPER(country) AS country,
    CASE
        WHEN rating < 0 THEN 0
        ELSE rating
    END AS rating, 
    CAST(created_at AS DATE) AS created_at,
    CURRENT_TIMESTAMP AS processed_at
FROM sellers
WHERE seller_id IS NOT NULL; 

-- Création de staging shipments
CREATE OR REPLACE VIEW staging.stg_shipments AS
SELECT
    shipment_id,
	order_id,
    CAST(carrier AS VARCHAR) AS carrier,
    CAST(shipped_date AS DATE) AS shipped_date,
    CAST(delivered_date AS DATE) AS delivered_date,
    LOWER(CAST(status AS VARCHAR)) AS status,
    CURRENT_TIMESTAMP AS processed_at
FROM shipments
WHERE shipment_id IS NOT NULL;

-- Création de staging web_events
CREATE OR REPLACE VIEW staging.stg_web_events AS
SELECT
    event_id,
	customer_id,
	LOWER(CAST(event_type AS VARCHAR)) AS event_type,
    LOWER(CAST(page AS VARCHAR)) AS page,
    CAST(event_time AS DATE) AS event_time,
    session_id,
    CURRENT_TIMESTAMP AS processed_at
FROM web_events
WHERE event_id IS NOT NULL;


-- Dimension customers
CREATE OR REPLACE TABLE analytics.dim_customers AS 
SELECT * FROM staging.stg_customers;

-- Dimension products
CREATE OR REPLACE TABLE analytics.dim_products AS 
SELECT * FROM staging.stg_products;

-- Dimension sellers
CREATE OR REPLACE TABLE analytics.dim_sellers AS 
SELECT * FROM staging.stg_sellers;

-- DATA MART - ANALYTICS : Les tables finales (Star Schema)

CREATE OR REPLACE TABLE analytics.fct_sales AS
SELECT 
    oi.order_item_id,
    o.order_id,
    o.customer_id,
    oi.product_id,
    o.order_date,
    sh.delivered_date,
    DATEDIFF('day', o.order_date, sh.delivered_date) AS days_to_deliver,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS line_amount,
    CASE 
        WHEN r.return_id IS NOT NULL THEN TRUE 
        ELSE FALSE 
    END AS is_returned
FROM staging.stg_order_items oi
INNER JOIN staging.stg_orders o ON oi.order_id = o.order_id
LEFT JOIN staging.stg_shipments sh ON o.order_id = sh.order_id
LEFT JOIN staging.stg_returns r ON oi.order_id = r.order_id AND oi.product_id = r.product_id;

-- Validation des données
SELECT *
FROM analytics.fct_sales;


-- Optimisation des requêtes lentes (propose index & stratégie)
CREATE UNIQUE INDEX IF NOT EXISTS idx_cust_id ON customers (customer_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_prod_id ON products (product_id);
CREATE INDEX IF NOT EXISTS idx_fct_sales_order ON analytics.fct_sales (order_id);
CREATE INDEX IF NOT EXISTS idx_fct_sales_cust ON analytics.fct_sales (customer_id);

