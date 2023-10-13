CREATE DATABASE important_db;

DROP TABLE IF EXISTS items CASCADE;
CREATE TABLE items(
    id SERIAL PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    item_price NUMERIC(3, 2) NOT NULL
);

DROP TABLE IF EXISTS orders_items CASCADE;
CREATE TABLE orders_items(
    order_id INT NOT NULL,
    item_id INT NOT NULL
);

DROP TABLE IF EXISTS orders CASCADE;
CREATE TABLE orders(
    id SERIAL PRIMARY KEY,
    order_date DATE DEFAULT NOW() NOT NULL,
    customer_id INT NOT NULL
);

DROP TABLE IF EXISTS customers CASCADE;
CREATE TABLE customers(
    id SERIAL PRIMARY KEY,
    customer_phone VARCHAR(12) NOT NULL,
    customer_email VARCHAR(30)
);

ALTER TABLE orders_items
ADD CONSTRAINT pk_orders_items
PRIMARY KEY (order_id, item_id),
ADD CONSTRAINT fk_orders_items_items
FOREIGN KEY (item_id)
REFERENCES items(id),
ADD CONSTRAINT fk_orders_items_orders
FOREIGN KEY (order_id)
REFERENCES orders(id);

ALTER TABLE orders
ADD CONSTRAINT fk_orders_customers
FOREIGN KEY (customer_id)
REFERENCES customers(id);