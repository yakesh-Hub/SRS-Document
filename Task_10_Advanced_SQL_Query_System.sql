-- ============================================================
-- TASK 3: ADVANCED SQL QUERY SYSTEM
-- ============================================================

USE SalesAnalyticsDB;

-- ============================================================
-- 1. SUBQUERY: PRODUCTS ABOVE AVERAGE PRICE
-- ============================================================

SELECT
    product_id,
    product_name,
    price
FROM Products
WHERE price > (
    SELECT AVG(price)
    FROM Products
)
ORDER BY price DESC;


-- ============================================================
-- 2. SUBQUERY: PRODUCTS BELOW AVERAGE PRICE
-- ============================================================

SELECT
    product_id,
    product_name,
    price
FROM Products
WHERE price < (
    SELECT AVG(price)
    FROM Products
)
ORDER BY price;


-- ============================================================
-- 3. FIND THE MOST EXPENSIVE PRODUCT
-- ============================================================

SELECT
    product_id,
    product_name,
    price
FROM Products
WHERE price = (
    SELECT MAX(price)
    FROM Products
);


-- ============================================================
-- 4. FIND THE CHEAPEST PRODUCT
-- ============================================================

SELECT
    product_id,
    product_name,
    price
FROM Products
WHERE price = (
    SELECT MIN(price)
    FROM Products
);


-- ============================================================
-- 5. FIND CUSTOMER WITH MAXIMUM PURCHASE
-- ============================================================

SELECT
    C.customer_id,
    C.customer_name,
    SUM(P.price * S.quantity) AS total_purchase
FROM Customers C
JOIN Sales S
ON C.customer_id = S.customer_id
JOIN Products P
ON S.product_id = P.product_id
GROUP BY C.customer_id, C.customer_name
HAVING SUM(P.price * S.quantity) = (
    SELECT MAX(customer_total)
    FROM (
        SELECT
            SUM(P2.price * S2.quantity) AS customer_total
        FROM Sales S2
        JOIN Products P2
        ON S2.product_id = P2.product_id
        GROUP BY S2.customer_id
    ) AS CustomerTotals
);


-- ============================================================
-- 6. FIND TOP 3 CUSTOMERS
-- ============================================================

SELECT
    C.customer_id,
    C.customer_name,
    SUM(P.price * S.quantity) AS total_purchase
FROM Customers C
JOIN Sales S
ON C.customer_id = S.customer_id
JOIN Products P
ON S.product_id = P.product_id
GROUP BY C.customer_id, C.customer_name
ORDER BY total_purchase DESC
LIMIT 3;


-- ============================================================
-- 7. CUSTOMERS WHO SPENT MORE THAN AVERAGE CUSTOMER PURCHASE
-- ============================================================

SELECT
    C.customer_id,
    C.customer_name,
    SUM(P.price * S.quantity) AS total_purchase
FROM Customers C
JOIN Sales S
ON C.customer_id = S.customer_id
JOIN Products P
ON S.product_id = P.product_id
GROUP BY C.customer_id, C.customer_name
HAVING SUM(P.price * S.quantity) > (
    SELECT AVG(customer_total)
    FROM (
        SELECT
            SUM(P2.price * S2.quantity) AS customer_total
        FROM Sales S2
        JOIN Products P2
        ON S2.product_id = P2.product_id
        GROUP BY S2.customer_id
    ) AS AverageCustomerPurchase
)
ORDER BY total_purchase DESC;


-- ============================================================
-- 8. FIND BEST-SELLING PRODUCT USING SUBQUERY
-- ============================================================

SELECT
    product_id,
    product_name,
    total_quantity
FROM (
    SELECT
        P.product_id,
        P.product_name,
        SUM(S.quantity) AS total_quantity
    FROM Products P
    JOIN Sales S
    ON P.product_id = S.product_id
    GROUP BY P.product_id, P.product_name
) AS ProductSales
WHERE total_quantity = (
    SELECT MAX(total_quantity)
    FROM (
        SELECT
            SUM(S2.quantity) AS total_quantity
        FROM Sales S2
        GROUP BY S2.product_id
    ) AS ProductTotals
);


-- ============================================================
-- 9. PRODUCTS THAT HAVE NEVER BEEN SOLD
-- ============================================================

SELECT
    P.product_id,
    P.product_name,
    P.price
FROM Products P
WHERE P.product_id NOT IN (
    SELECT DISTINCT product_id
    FROM Sales
);


-- ============================================================
-- 10. CUSTOMERS WHO HAVE MADE AT LEAST ONE PURCHASE
-- ============================================================

SELECT
    customer_id,
    customer_name
FROM Customers
WHERE customer_id IN (
    SELECT DISTINCT customer_id
    FROM Sales
);


-- ============================================================
-- 11. CUSTOMERS WHO HAVE NOT MADE ANY PURCHASE
-- ============================================================

SELECT
    customer_id,
    customer_name
FROM Customers
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id
    FROM Sales
);


-- ============================================================
-- 12. FIND PRODUCTS MORE EXPENSIVE THAN LAPTOP
-- ============================================================

SELECT
    product_id,
    product_name,
    price
FROM Products
WHERE price > (
    SELECT price
    FROM Products
    WHERE product_name = 'Laptop'
);


-- ============================================================
-- 13. CATEGORY WITH HIGHEST SALES
-- ============================================================

SELECT
    C.category_name,
    SUM(P.price * S.quantity) AS total_sales
FROM Categories C
JOIN Products P
ON C.category_id = P.category_id
JOIN Sales S
ON P.product_id = S.product_id
GROUP BY C.category_id, C.category_name
HAVING SUM(P.price * S.quantity) = (
    SELECT MAX(category_sales)
    FROM (
        SELECT
            SUM(P2.price * S2.quantity) AS category_sales
        FROM Categories C2
        JOIN Products P2
        ON C2.category_id = P2.category_id
        JOIN Sales S2
        ON P2.product_id = S2.product_id
        GROUP BY C2.category_id
    ) AS CategoryTotals
);


-- ============================================================
-- 14. CUSTOMER PURCHASE REPORT
-- ============================================================

SELECT
    C.customer_id,
    C.customer_name,
    COUNT(S.sale_id) AS total_orders,
    SUM(S.quantity) AS total_items,
    SUM(P.price * S.quantity) AS total_purchase,
    AVG(P.price * S.quantity) AS average_order_value,
    MIN(P.price * S.quantity) AS minimum_order,
    MAX(P.price * S.quantity) AS maximum_order
FROM Customers C
JOIN Sales S
ON C.customer_id = S.customer_id
JOIN Products P
ON S.product_id = P.product_id
GROUP BY C.customer_id, C.customer_name
ORDER BY total_purchase DESC;


-- ============================================================
-- 15. PRODUCT PERFORMANCE REPORT
-- ============================================================

SELECT
    P.product_id,
    P.product_name,
    C.category_name,
    P.price,
    SUM(S.quantity) AS quantity_sold,
    SUM(P.price * S.quantity) AS total_revenue,
    AVG(P.price * S.quantity) AS average_revenue
FROM Products P
JOIN Categories C
ON P.category_id = C.category_id
JOIN Sales S
ON P.product_id = S.product_id
GROUP BY
    P.product_id,
    P.product_name,
    C.category_name,
    P.price
ORDER BY total_revenue DESC;


-- ============================================================
-- 16. NESTED QUERY: CUSTOMERS WHO PURCHASED LAPTOP
-- ============================================================

SELECT
    customer_id,
    customer_name
FROM Customers
WHERE customer_id IN (
    SELECT customer_id
    FROM Sales
    WHERE product_id = (
        SELECT product_id
        FROM Products
        WHERE product_name = 'Laptop'
    )
);


-- ============================================================
-- 17. NESTED QUERY: CUSTOMERS WHO PURCHASED
--     PRODUCTS ABOVE AVERAGE PRICE
-- ============================================================

SELECT DISTINCT
    C.customer_id,
    C.customer_name
FROM Customers C
JOIN Sales S
ON C.customer_id = S.customer_id
WHERE S.product_id IN (
    SELECT product_id
    FROM Products
    WHERE price > (
        SELECT AVG(price)
        FROM Products
    )
);


-- ============================================================
-- 18. BUSINESS QUERY:
-- CUSTOMERS WHO PURCHASED MORE THAN 2 ITEMS
-- ============================================================

SELECT
    C.customer_id,
    C.customer_name,
    SUM(S.quantity) AS total_items
FROM Customers C
JOIN Sales S
ON C.customer_id = S.customer_id
GROUP BY C.customer_id, C.customer_name
HAVING SUM(S.quantity) > 2
ORDER BY total_items DESC;


-- ============================================================
-- 19. BUSINESS QUERY:
-- PRODUCTS WITH REVENUE ABOVE AVERAGE PRODUCT REVENUE
-- ============================================================

SELECT
    P.product_id,
    P.product_name,
    SUM(P.price * S.quantity) AS revenue
FROM Products P
JOIN Sales S
ON P.product_id = S.product_id
GROUP BY P.product_id, P.product_name
HAVING SUM(P.price * S.quantity) > (
    SELECT AVG(product_revenue)
    FROM (
        SELECT
            SUM(P2.price * S2.quantity) AS product_revenue
        FROM Products P2
        JOIN Sales S2
        ON P2.product_id = S2.product_id
        GROUP BY P2.product_id
    ) AS AverageRevenue
)
ORDER BY revenue DESC;


-- ============================================================
-- 20. ADVANCED SQL REPORT
-- ============================================================

SELECT
    C.customer_name,
    P.product_name,
    CAT.category_name,
    P.price,
    S.quantity,
    (P.price * S.quantity) AS purchase_amount,
    S.sale_date
FROM Customers C
JOIN Sales S
ON C.customer_id = S.customer_id
JOIN Products P
ON S.product_id = P.product_id
JOIN Categories CAT
ON P.category_id = CAT.category_id
WHERE P.price > (
    SELECT AVG(price)
    FROM Products
)
ORDER BY purchase_amount DESC;


-- ============================================================
-- END OF TASK 3
-- ============================================================