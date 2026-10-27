-- DATA QUALITY CHECKS

-- 1. Row Count of each table

SELECT 'orders' AS table_name,
       COUNT(*) AS total_rows
FROM orders

UNION ALL

SELECT 'customers', COUNT(*)
FROM customers

UNION ALL

SELECT 'products', COUNT(*)
FROM products;

-- 2. Checks for Duplicate Row_id, Customer_id and Product_id

SELECT row_id, COUNT(*) AS 'count_oF_id'
FROM orders
GROUP BY row_id
HAVING COUNT(*)>1;

SELECT customer_id, COUNT(*) AS 'count of id'
FROM customers
GROUP BY customer_id
HAVING COUNT(*)>1;

SELECT product_id, COUNT(*) AS 'count_oF_id'
FROM products
GROUP BY product_id
HAVING COUNT(*)>1;

-- 3. Checks for Null cells

SELECT
    SUM(sales IS NULL) AS null_sales,
    SUM(profit IS NULL) AS null_profit,
    SUM(customer_id IS NULL) AS null_customer_id,
    SUM(product_id IS NULL) AS null_product_id,
    SUM(order_date IS NULL) AS null_order_date
FROM orders;

SELECT
    SUM(customer_id IS NULL) AS null_id,
    SUM(customer_name IS NULL) AS null_name,
    SUM(total_orders IS NULL) AS null_totalorders,
    SUM(segment IS NULL) AS null_segment
    FROM customers;

SELECT
SUM(product_id IS NULL) AS null_id,
SUM(product_name IS NULL) AS null_name,
SUM(category IS NULL) AS null_category,
SUM(subcategory IS NULL) AS null_subcategory,
SUM(cost IS NULL) AS null_cost
FROM products;

-- 4. unmatched ids
SELECT  o.customer_id, COUNT(*) AS 'unmatched_id'
FROM customers c LEFT JOIN orders o ON c.customer_id=o.customer_id
WHERE c.customer_id IS NULL
GROUP BY o.customer_id;

SELECT o.product_id, COUNT(*) AS 'unmatched-id'
FROM products p LEFT JOIN orders o ON o.product_id=p.product_id
WHERE p.product_id IS NULL
GROUP BY o.product_id;

-- 5. invalid date checks

SELECT order_id, order_date, ship_date
FROM orders
WHERE ship_date<order_date;

-- 6. Inconsistent order count
WITH actual_counts AS (
    SELECT customer_id,
           COUNT(DISTINCT order_id) AS actual_orders
    FROM orders
    GROUP BY customer_id
)
SELECT c.customer_id,
       c.total_orders AS stored_orders,
       ROW_NUMBER() OVER(),
       COALESCE(a.actual_orders, 0) AS actual_orders
FROM customers c
LEFT JOIN actual_counts a
    ON c.customer_id = a.customer_id
WHERE c.total_orders IS NULL
   OR c.total_orders <> COALESCE(a.actual_orders, 0);

-- 7. Invalid Numbers

SELECT row_id, sales, profit, quantity, discount, shipping_cost
FROM orders
WHERE quantity < 0
   OR shipping_cost < 0
   OR discount < 0
   OR discount > 1;
   
-- 8. Inconsistent Values

SELECT DISTINCT category
FROM products
WHERE category <> TRIM(category)
   OR BINARY category <> BINARY UPPER(category);

SELECT DISTINCT subcategory
FROM products
WHERE subcategory <> TRIM(subcategory)
   OR BINARY subcategory <> BINARY UPPER(subcategory);

SELECT DISTINCT ship_mode
FROM orders
WHERE ship_mode <> TRIM(ship_mode)
   OR BINARY ship_mode <> BINARY UPPER(ship_mode);
   
-- 9. Outliers

WITH RankedSales AS (
    SELECT
        row_id,
        order_id,
        sales,
        ROW_NUMBER() OVER (ORDER BY sales) AS rn,
        COUNT(*) OVER () AS total_rows
    FROM orders
    WHERE sales IS NOT NULL
),
Quartiles AS (
    SELECT
        MAX(CASE
            WHEN rn = CEIL(total_rows * 0.25)
            THEN sales
        END) AS q1,
        MAX(CASE
            WHEN rn = CEIL(total_rows * 0.75)
            THEN sales
        END) AS q3
    FROM RankedSales
)
SELECT
    r.row_id,
    r.order_id,
    r.sales,
    q.q1,
    q.q3,
    q.q3 - q.q1 AS iqr
FROM RankedSales r
CROSS JOIN Quartiles q
WHERE r.sales < q.q1 - 1.5 * (q.q3 - q.q1)
   OR r.sales > q.q3 + 1.5 * (q.q3 - q.q1)
ORDER BY r.sales DESC;
