
DROP TABLE IF EXISTS orders_manual;

CREATE TABLE orders_manual (
    order_id INT PRIMARY KEY,
    customer_name TEXT,
    email TEXT,
    phone TEXT,
    payment_method TEXT,
    product_name TEXT,
    category TEXT,
    amount NUMERIC(10,2),
    quantity INT,
    discount NUMERIC(10,2),
    order_date TIMESTAMP,
    shipped_date TIMESTAMP
);

-- lets create other tables to practice in many ways 

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    customer_name TEXT,
    signup_date DATE,
    city TEXT
);



CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name TEXT,
    category TEXT,
    price NUMERIC
);


CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    product_id INT REFERENCES products(product_id),
    order_date TIMESTAMP,
    quantity INT,
    discount NUMERIC
);
