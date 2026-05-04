-- Etape 2: - Chargement des données dans les tables

INSERT INTO customers (customer_id, first_name, last_name, email, phone, country, created_at, is_active)
SELECT
  row_number() OVER () AS customer_id,
  'Name' || g,
  'Surname' || g,
  CASE WHEN random() < 0.05 THEN NULL ELSE 'user' || g || '@mail.com' END,
  NULL,
  (['FR','US','DE','UK','ES'])[CAST(floor(random()*5)+1 AS BIGINT)],
  NOW() - INTERVAL (floor(random()*1000)) DAY,
  random() > 0.1
FROM range(200000) AS t(g);


INSERT INTO sellers (seller_id, name, country, rating, created_at)
SELECT
  row_number() OVER () AS seller_id,
  'Seller ' || g,
  (['FR','US','DE','UK','ES'])[CAST(floor(random()*5)+1 AS BIGINT)],
  round(random()*5,1),
  NOW() - INTERVAL (floor(random()*1000)) DAY
FROM range(10000) AS t(g);


INSERT INTO products (product_id, seller_id, name, category, price, created_at)
SELECT
  row_number() OVER () AS product_id,
  CAST(floor(random()*10000)+1 AS BIGINT),
  'Product ' || g,
  (['Electronics','Fashion','Home','Sports','Beauty'])[CAST(floor(random()*5)+1 AS BIGINT)],
  round(random()*500,2),
  NOW() - INTERVAL (floor(random()*1000)) DAY
FROM range(50000) AS t(g);


INSERT INTO orders (order_id, customer_id, order_date, status, total_amount, shipping_country)
SELECT
  row_number() OVER () AS order_id,
  CAST(floor(random()*200000)+1 AS BIGINT),
  NOW() - INTERVAL (floor(random()*365)) DAY,
  (['created','paid','shipped','delivered','cancelled'])[CAST(floor(random()*5)+1 AS BIGINT)],
  round(random()*1000,2),
  (['FR','US','DE','UK','ES'])[CAST(floor(random()*5)+1 AS BIGINT)]
FROM range(1000000) AS t(g);


INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price)
SELECT
  row_number() OVER () AS order_item_id,
  floor(random()*1000000)+1 AS order_id,
  floor(random()*50000)+1 AS product_id,
  CAST(floor(random()*5)+1 AS BIGINT) AS quantity,
  round(random()*200,2) AS unit_price
FROM range(1,2000000);


INSERT INTO payments (payment_id, order_id, payment_method, amount, payment_status, payment_date)
SELECT
  row_number() OVER () AS payment_id,
  o.order_id,
  (['card','paypal','bank_transfer','apple_pay'])[CAST(floor(random()*4)+1 AS BIGINT)],
  round(random()*1000,2),
  (['success','failed','pending'])[CAST(floor(random()*3)+1 AS BIGINT)],
  NOW() - INTERVAL (floor(random()*365)) DAY
FROM orders o;


INSERT INTO shipments (shipment_id, order_id, carrier, shipped_date, delivered_date, status)
SELECT
  row_number() OVER () AS shipment_id,
  o.order_id,
  (['DHL','UPS','FedEx'])[CAST(floor(random()*3)+1 AS BIGINT)],
  o.order_date + INTERVAL (floor(random()*5)) DAY,
  o.order_date + INTERVAL (floor(random()*10)) DAY,
  (['in_transit','delivered','lost'])[CAST(floor(random()*3)+1 AS BIGINT)]
FROM orders o;


INSERT INTO returns (return_id, order_id, product_id, reason, return_date, refunded)
SELECT
  row_number() OVER () AS return_id,
  o.order_id,
  CAST(floor(random()*50000)+1 AS BIGINT),
  (['damaged','wrong_item','not_satisfied','size_issue'])[CAST(floor(random()*4)+1 AS BIGINT)],
  o.order_date + INTERVAL (floor(random()*30)) DAY,
  random() > 0.4
FROM orders o
WHERE random() < 0.1;


INSERT INTO web_events (event_id, customer_id, event_type, page, event_time, session_id)
SELECT
  row_number() OVER () AS event_id,
  CAST(floor(random()*200000)+1 AS BIGINT) AS customer_id,
  (['view','click','add_to_cart','purchase'])[CAST(floor(random()*4)+1 AS BIGINT)] AS event_type,
  (['home','product','checkout','search'])[CAST(floor(random()*4)+1 AS BIGINT)] AS page,
  NOW() - INTERVAL (floor(random()*30)) DAY AS event_time,
  md5(random()::VARCHAR) AS session_id
FROM range(2000000);


-- Validation des données 
SELECT 'customers' AS table_name, COUNT(*) AS nombre_lignes
FROM customers
UNION
SELECT 'sellers' AS table_name, COUNT(*) AS nombre_lignes
FROM sellers
UNION
SELECT 'products' AS table_name, COUNT(*) AS nombre_lignes
FROM products
UNION
SELECT 'orders' AS table_name, COUNT(*) AS nombre_lignes
FROM orders;
SELECT 'order_items' AS table_name, COUNT(*) AS nombre_lignes
FROM order_items;
SELECT 'payments' AS table_name, COUNT(*) AS nombre_lignes
FROM payments;
SELECT 'shipments' AS table_name, COUNT(*) AS nombre_lignes
FROM shipments;
SELECT 'returns' AS table_name, COUNT(*) AS nombre_lignes
FROM returns;


-- Validation des données
SELECT 'customers' AS table_name, COUNT(*) AS nombre_lignes FROM customers
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'payments', COUNT(*) FROM payments
UNION ALL
SELECT 'shipments', COUNT(*) FROM shipments
UNION ALL
SELECT 'returns', COUNT(*) FROM returns;


-- Validation des données
SELECT * FROM customers LIMIT 5;
SELECT * FROM sellers LIMIT 5;
SELECT * FROM products LIMIT 5;
SELECT * FROM orders LIMIT 5;
SELECT * FROM order_items LIMIT 5;
SELECT * FROM payments LIMIT 5;
SELECT * FROM shipments LIMIT 5;
SELECT * FROM returns  LIMIT 5;




