-- ============================================================
-- TASK 2: SALES AND CUSTOMER ANALYTICS SYSTEM
-- ============================================================

-- Create Database
CREATE DATABASE SalesAnalyticsDB;

USE SalesAnalyticsDB;

-- ============================================================
-- 1. CREATE TABLES
-- ============================================================

-- Customers Table
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    city VARCHAR(50)
);

-- Categories Table
CREATE TABLE Categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(50)
);

-- Products Table
CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category_id INT,
    price DECIMAL(10,2),
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

-- Sales Table
CREATE TABLE Sales (
    sale_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    quantity INT,
    sale_date DATE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- ============================================================
-- 2. INSERT SAMPLE DATA
-- ============================================================

-- Customers
INSERT INTO Customers VALUES
(1, 'Arun Kumar', 'arun@gmail.com', 'Madurai'),
(2, 'Priya S', 'priya@gmail.com', 'Chennai'),
(3, 'Rahul M', 'rahul@gmail.com', 'Coimbatore'),
(4, 'Divya R', 'divya@gmail.com', 'Madurai'),
(5, 'Karthik P', 'karthik@gmail.com', 'Trichy');

-- Categories
INSERT INTO Categories VALUES
(1, 'Electronics'),
(2, 'Clothing'),
(3, 'Books'),
(4, 'Accessories');

-- Products
INSERT INTO Products VALUES
(101, 'Laptop', 1, 55000.00),
(102, 'Smartphone', 1, 25000.00),
(103, 'Headphones', 1, 2000.00),
(104, 'T-Shirt', 2, 800.00),
(105, 'Jeans', 2, 1500.00),
(106, 'SQL Book', 3, 600.00),
(107, 'Python Book', 3, 750.00),
(108, 'Smart Watch', 4, 3500.00);

-- Sales
INSERT INTO Sales VALUES
(1, 1, 101, 1, '2026-09-01'),
(2, 2, 102, 2, '2026-09-01'),
(3, 3, 103, 3, '2026-09-02'),
(4, 1, 104, 4, '2026-09-02'),
(5, 4, 105, 2, '2026-09-03'),
(6, 5, 106, 5, '2026-09-03'),
(7, 2, 107, 3, '2026-09-04'),
(8, 3, 108, 2, '2026-09-04'),
(9, 1, 102, 1, '2026-09-05'),
(10, 4, 103, 4, '2026-09-05'),
(11, 5, 104, 2, '2026-09-06'),
(12, 2, 101, 1, '2026-09-06');

-- ============================================================
-- 3. BASIC SALES ANALYTICS
-- ============================================================

-- COUNT(): Find total number of sales transactions
SELECT COUNT(*) AS total_transactions
FROM Sales;


-- COUNT(): Find total number of customers
SELECT COUNT(*) AS total_customers
FROM Customers;


-- SUM(): Find total quantity of products sold
SELECT SUM(quantity) AS total_products_sold
FROM Sales;


-- AVG(): Find average product price
SELECT AVG(price) AS average_product_price
FROM Products;


-- MIN(): Find minimum product price
SELECT MIN(price) AS minimum_product_price
FROM Products;


-- MAX(): Find maximum product price
SELECT MAX(price) AS maximum_product_price
FROM Products;

-- ============================================================
-- 4. TOTAL SALES REPORT
-- ============================================================

-- Total sales amount
SELECT 
    SUM(P.price * S.quantity) AS total_sales
FROM Sales S
JOIN Products P
ON S.product_id = P.product_id;


-- Detailed Sales Report
SELECT
    S.sale_id,
    C.customer_name,
    P.product_name,
    P.price,
    S.quantity,
    (P.price * S.quantity) AS total_amount,
    S.sale_date
FROM Sales S
JOIN Customers C
ON S.customer_id = C.customer_id
JOIN Products P
ON S.product_id = P.product_id
ORDER BY S.sale_date;

-- ============================================================
-- 5. TOP CUSTOMERS BASED ON PURCHASE AMOUNT
-- ============================================================

SELECT
    C.customer_id,
    C.customer_name,
    SUM(P.price * S.quantity) AS total_purchase_amount
FROM Sales S
JOIN Customers C
ON S.customer_id = C.customer_id
JOIN Products P
ON S.product_id = P.product_id
GROUP BY C.customer_id, C.customer_name
ORDER BY total_purchase_amount DESC;


-- Top 3 Customers
SELECT
    C.customer_name,
    SUM(P.price * S.quantity) AS total_purchase_amount
FROM Sales S
JOIN Customers C
ON S.customer_id = C.customer_id
JOIN Products P
ON S.product_id = P.product_id
GROUP BY C.customer_id, C.customer_name
ORDER BY total_purchase_amount DESC
LIMIT 3;

-- ============================================================
-- 6. BEST-SELLING PRODUCTS
-- ============================================================

-- Products based on quantity sold
SELECT
    P.product_id,
    P.product_name,
    SUM(S.quantity) AS total_quantity_sold
FROM Sales S
JOIN Products P
ON S.product_id = P.product_id
GROUP BY P.product_id, P.product_name
ORDER BY total_quantity_sold DESC;


-- Products based on total sales amount
SELECT
    P.product_id,
    P.product_name,
    SUM(P.price * S.quantity) AS total_sales_amount
FROM Sales S
JOIN Products P
ON S.product_id = P.product_id
GROUP BY P.product_id, P.product_name
ORDER BY total_sales_amount DESC;

-- ============================================================
-- 7. CATEGORY-WISE SALES ANALYSIS
-- ============================================================

SELECT
    C.category_name,
    SUM(S.quantity) AS total_quantity_sold,
    SUM(P.price * S.quantity) AS total_sales_amount,
    AVG(P.price) AS average_product_price,
    MIN(P.price) AS minimum_price,
    MAX(P.price) AS maximum_price
FROM Sales S
JOIN Products P
ON S.product_id = P.product_id
JOIN Categories C
ON P.category_id = C.category_id
GROUP BY C.category_id, C.category_name
ORDER BY total_sales_amount DESC;

-- ============================================================
-- 8. CATEGORY-WISE NUMBER OF PRODUCTS SOLD
-- ============================================================

SELECT
    C.category_name,
    COUNT(S.sale_id) AS number_of_transactions,
    SUM(S.quantity) AS total_quantity_sold
FROM Sales S
JOIN Products P
ON S.product_id = P.product_id
JOIN Categories C
ON P.category_id = C.category_id
GROUP BY C.category_id, C.category_name
ORDER BY total_quantity_sold DESC;

-- ============================================================
-- 9. DAILY SALES REPORT
-- ============================================================

SELECT
    S.sale_date,
    COUNT(S.sale_id) AS total_transactions,
    SUM(P.price * S.quantity) AS daily_sales
FROM Sales S
JOIN Products P
ON S.product_id = P.product_id
GROUP BY S.sale_date
ORDER BY S.sale_date;

-- ============================================================
-- 10. COMPLETE ANALYTICS SUMMARY
-- ============================================================

SELECT
    COUNT(DISTINCT S.customer_id) AS total_customers,
    COUNT(S.sale_id) AS total_transactions,
    SUM(S.quantity) AS total_items_sold,
    SUM(P.price * S.quantity) AS total_sales,
    AVG(P.price * S.quantity) AS average_transaction_value,
    MIN(P.price * S.quantity) AS minimum_transaction_value,
    MAX(P.price * S.quantity) AS maximum_transaction_value
FROM Sales S
JOIN Products P
ON S.product_id = P.product_id;

-- ============================================================
-- END OF TASK 2
-- ============================================================