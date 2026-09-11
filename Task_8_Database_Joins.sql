-- Task 1: Database Relationship Analysis using Joins
-- Customer, Product, Orders and Payment tables
-- Compatible with MySQL

CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;

-- Drop tables so the script can be re-run
DROP TABLE IF EXISTS Payment;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS Customer;

-- 1. CUSTOMER TABLE
CREATE TABLE Customer (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(15),
    city VARCHAR(50)
);

-- 2. PRODUCT TABLE
CREATE TABLE Product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0
);

-- 3. ORDERS TABLE
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    order_date DATE NOT NULL,
    quantity INT NOT NULL,
    order_status VARCHAR(30),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

-- 4. PAYMENT TABLE
CREATE TABLE Payment (
    payment_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_date DATE,
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(30),
    payment_status VARCHAR(30),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

-- SAMPLE DATA
INSERT INTO Customer VALUES
(1, 'Arun Kumar', 'arun@gmail.com', '9876543210', 'Chennai'),
(2, 'Priya S', 'priya@gmail.com', '9876543211', 'Madurai'),
(3, 'Karthik R', 'karthik@gmail.com', '9876543212', 'Coimbatore'),
(4, 'Divya M', 'divya@gmail.com', '9876543213', 'Trichy'),
(5, 'Rahul P', 'rahul@gmail.com', '9876543214', 'Salem');

INSERT INTO Product VALUES
(101, 'Wireless Mouse', 'Electronics', 599.00, 50),
(102, 'Mechanical Keyboard', 'Electronics', 1499.00, 30),
(103, 'USB-C Cable', 'Accessories', 299.00, 100),
(104, 'Laptop Stand', 'Accessories', 899.00, 25),
(105, 'Bluetooth Speaker', 'Electronics', 1999.00, 20);

INSERT INTO Orders VALUES
(1001, 1, 101, '2026-09-01', 2, 'Delivered'),
(1002, 1, 102, '2026-09-02', 1, 'Shipped'),
(1003, 2, 103, '2026-09-03', 3, 'Delivered'),
(1004, 3, 105, '2026-09-04', 1, 'Processing'),
(1005, 4, 104, '2026-09-05', 2, 'Delivered');

INSERT INTO Payment VALUES
(501, 1001, '2026-09-01', 1198.00, 'UPI', 'Paid'),
(502, 1002, '2026-09-02', 1499.00, 'Card', 'Paid'),
(503, 1003, '2026-09-03', 897.00, 'UPI', 'Paid'),
(504, 1004, '2026-09-04', 1999.00, 'Cash on Delivery', 'Pending'),
(505, 1005, '2026-09-05', 1798.00, 'Card', 'Paid');

-- =========================================================
-- TASK 1: DATABASE RELATIONSHIP ANALYSIS USING JOINS
-- =========================================================

-- A. INNER JOIN
-- Shows only customers/orders/products that have matching records.
SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.order_date,
    p.product_id,
    p.product_name,
    o.quantity,
    p.price,
    (o.quantity * p.price) AS order_total
FROM Customer c
INNER JOIN Orders o ON c.customer_id = o.customer_id
INNER JOIN Product p ON o.product_id = p.product_id;

-- B. INNER JOIN WITH PAYMENT
-- Complete order details including payment information.
SELECT
    c.customer_id,
    c.customer_name,
    c.email,
    o.order_id,
    o.order_date,
    p.product_name,
    p.category,
    o.quantity,
    p.price,
    (o.quantity * p.price) AS order_total,
    pay.payment_method,
    pay.payment_status,
    pay.payment_date
FROM Customer c
INNER JOIN Orders o ON c.customer_id = o.customer_id
INNER JOIN Product p ON o.product_id = p.product_id
INNER JOIN Payment pay ON o.order_id = pay.order_id
ORDER BY o.order_date;

-- C. LEFT JOIN
-- Shows all customers, including customers who have not placed orders.
SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.order_date,
    p.product_name,
    o.quantity,
    p.price
FROM Customer c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
LEFT JOIN Product p ON o.product_id = p.product_id
ORDER BY c.customer_id;

-- D. RIGHT JOIN
-- Shows all products, including products that have not been ordered.
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    o.order_id,
    o.order_date,
    o.quantity
FROM Orders o
RIGHT JOIN Product p ON o.product_id = p.product_id
ORDER BY p.product_id;

-- E. CUSTOMER PURCHASE HISTORY
-- Displays each customer's purchased products and total amount.
SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.order_date,
    p.product_name,
    p.category,
    o.quantity,
    p.price,
    (o.quantity * p.price) AS purchase_amount,
    o.order_status
FROM Customer c
INNER JOIN Orders o ON c.customer_id = o.customer_id
INNER JOIN Product p ON o.product_id = p.product_id
ORDER BY c.customer_id, o.order_date;

-- F. CUSTOMER-WISE PURCHASE SUMMARY
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders,
    COALESCE(SUM(o.quantity * p.price), 0) AS total_purchase_amount
FROM Customer c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
LEFT JOIN Product p ON o.product_id = p.product_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_purchase_amount DESC;

-- G. MULTI-TABLE SALES REPORT
SELECT
    c.customer_name,
    c.city,
    p.product_name,
    p.category,
    SUM(o.quantity) AS total_quantity,
    SUM(o.quantity * p.price) AS total_sales,
    COUNT(DISTINCT o.order_id) AS number_of_orders
FROM Customer c
INNER JOIN Orders o ON c.customer_id = o.customer_id
INNER JOIN Product p ON o.product_id = p.product_id
GROUP BY c.customer_id, c.customer_name, c.city,
         p.product_id, p.product_name, p.category
ORDER BY total_sales DESC;

-- H. PAYMENT REPORT
SELECT
    o.order_id,
    c.customer_name,
    p.product_name,
    pay.amount,
    pay.payment_method,
    pay.payment_status,
    pay.payment_date
FROM Payment pay
INNER JOIN Orders o ON pay.order_id = o.order_id
INNER JOIN Customer c ON o.customer_id = c.customer_id
INNER JOIN Product p ON o.product_id = p.product_id
ORDER BY pay.payment_date;

-- I. UNPAID / PENDING PAYMENTS
SELECT
    o.order_id,
    c.customer_name,
    p.product_name,
    pay.amount,
    pay.payment_method,
    pay.payment_status
FROM Payment pay
INNER JOIN Orders o ON pay.order_id = o.order_id
INNER JOIN Customer c ON o.customer_id = c.customer_id
INNER JOIN Product p ON o.product_id = p.product_id
WHERE pay.payment_status <> 'Paid';

-- J. ORDERS WITH CUSTOMER, PRODUCT AND PAYMENT DETAILS
SELECT
    o.order_id,
    o.order_date,
    c.customer_name,
    c.city,
    p.product_name,
    p.category,
    o.quantity,
    p.price,
    o.quantity * p.price AS total_amount,
    o.order_status,
    pay.payment_method,
    pay.payment_status
FROM Orders o
JOIN Customer c ON o.customer_id = c.customer_id
JOIN Product p ON o.product_id = p.product_id
LEFT JOIN Payment pay ON o.order_id = pay.order_id
ORDER BY o.order_id;
