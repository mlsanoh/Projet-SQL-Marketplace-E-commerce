-- Etape 1 : Création des tables dans le data Warehouse
DROP TABLE IF EXISTS returns;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS shipments;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS sellers;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS web_events;


CREATE TABLE customers (
    customer_id         BIGINT      PRIMARY KEY,
    first_name          VARCHAR,
    last_name           VARCHAR,
    email               VARCHAR,
    phone               VARCHAR,
    country             VARCHAR,
    created_at          TIMESTAMP,
    is_active           BOOLEAN
);

CREATE TABLE sellers (
    seller_id           BIGINT      PRIMARY KEY,
    name                VARCHAR,
    country             VARCHAR,
    rating              NUMERIC(2,1),
    created_at          TIMESTAMP
);

CREATE TABLE products (
    product_id          BIGINT      PRIMARY KEY,
    seller_id           BIGINT ,
    name                VARCHAR,
    category            VARCHAR,
    price               NUMERIC(10,2),
    created_at          TIMESTAMP,
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);

CREATE TABLE orders (
    order_id            BIGINT      PRIMARY KEY,
    customer_id         BIGINT,
    order_date          TIMESTAMP,
    status              VARCHAR,
    total_amount        NUMERIC(10,2),
    shipping_country    VARCHAR,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id       BIGINT      PRIMARY KEY,
    order_id            BIGINT,
    product_id          BIGINT,
    quantity            INTEGER,
    unit_price          NUMERIC(10,2),
    FOREIGN KEY (order_id)  REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE payments (
    payment_id         BIGINT       PRIMARY KEY,
    order_id           BIGINT,
    payment_method     VARCHAR,
    amount             NUMERIC(10,2),
    payment_status     VARCHAR,
    payment_date       TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE shipments (
    shipment_id        BIGINT        PRIMARY KEY,
    order_id           BIGINT,
    carrier            VARCHAR,
    shipped_date       TIMESTAMP,
    delivered_date     TIMESTAMP,
    status             VARCHAR,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE returns (
    return_id       BIGINT          PRIMARY KEY,
    order_id        BIGINT,
    product_id      BIGINT,
    reason          VARCHAR,
    return_date     TIMESTAMP,
    refunded        BOOLEAN,
    FOREIGN KEY (order_id)  REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE web_events (
    event_id        BIGINT         PRIMARY KEY,
    customer_id     BIGINT,
    event_type      VARCHAR,
    page            VARCHAR,
    event_time      TIMESTAMP,
    session_id      VARCHAR
);


-- Validation des données 
SELECT table_name
FROM information_schema.tables;