-- Project: Global Superstore SQL Analysis
-- Database: MySQL 8.0
-- Purpose: Evaluate product and subcategory performance,
-- profitability, and sales contribution.
-- Execution: Refer to README.md for setup instructions.

-- TEMP TABLE tmp_product_metrics

DROP TEMPORARY TABLE IF EXISTS tmp_product_metrics;

-- sales variable
SET @overall_sales = (SELECT SUM(sales) FROM orders);

CREATE TEMPORARY TABLE tmp_product_metrics AS 
SELECT 
p.product_id, p.product_name, p.category, p.subcategory, 
ROUND(SUM(o.sales),2) AS total_sales, ROUND(SUM(o.profit),2) AS total_profit,
SUM(o.quantity) AS quantity_sold, COUNT(DISTINCT o.customer_id) AS total_customers,
COUNT(DISTINCT order_id) AS total_orders,
ROUND(AVG(o.discount),2) AS avg_discount,
ROUND(
    SUM(o.profit) / NULLIF(SUM(o.sales), 0) * 100,
    2
) AS profit_margin,
    ROUND(
        SUM(sales)
        / NULLIF(@overall_sales, 0) * 100,
        2
    ) AS sales_contribution,
    DENSE_RANK() OVER(ORDER BY SUM(o.sales) DESC) AS Rank_by_Sales,
    DENSE_RANK() OVER(ORDER BY SUM(o.profit) DESC) AS Rank_by_Profit
FROM products p LEFT JOIN orders o ON p.product_id=o.product_id
GROUP BY p.product_id,
    p.product_name,
    p.category,
    p.subcategory;


-- 1. Subcategory Performance Analysis
SELECT 
subcategory, category, ROUND(SUM(total_sales),2) AS total_sales, ROUND(SUM(total_profit),2) AS total_profit, 
SUM(total_orders) AS total_orders, SUM(total_customers) AS total_customers, 
SUM(quantity_sold) AS quantity_sold,
RANK() OVER(ORDER BY SUM(total_sales) DESC) AS Rank_by_Sales,
RANK() OVER(ORDER BY SUM(total_profit) DESC) AS Rank_by_Profit,
CONCAT(ROUND(SUM(total_sales)/NULLIF((@overall_sales),0) * 100,2),'%') AS Sales_Contribution,
CONCAT(
        ROUND(
            SUM(total_profit) / NULLIF(SUM(total_sales), 0) * 100,
            2
        ), '%'
    ) AS profit_margin 
    FROM tmp_product_metrics
GROUP by subcategory, category;

-- 2. Overall Product Performance

SELECT
    product_id,
    product_name,
    total_sales,
    total_profit,
    quantity_sold,
    total_orders,
    avg_discount,
    CONCAT(profit_margin, '%'),
    CONCAT(sales_contribution,'%'),
    Rank_by_Sales,
    Rank_by_Profit
FROM tmp_product_metrics
ORDER BY total_sales DESC;
    
-- 3. Top 10 Products by Sales, Profit and Profit Margin

-- (a). Rank by Sales

SELECT 
product_name, 
category, 
subcategory, 
total_sales, 
total_profit,
CONCAT(profit_margin,'%') AS profit_margin,
quantity_sold,
Rank_by_Sales, 
Rank_by_Profit
FROM tmp_product_metrics
ORDER BY total_sales DESC LIMIT 10;

-- (b). Rank by Profit

SELECT 
product_name, 
category, 
subcategory, 
total_sales, 
total_profit,
CONCAT(profit_margin,'%') AS profit_margin,
quantity_sold,
Rank_by_Sales,
Rank_by_Profit
FROM tmp_product_metrics
ORDER BY total_profit DESC LIMIT 10;

-- (c). Rank by Profit Margin

SELECT 
product_name, 
category, 
subcategory, 
total_sales, 
total_profit,
CONCAT(profit_margin,'%') AS profit_margin,
quantity_sold,
Rank_by_Sales,
Rank_by_Profit,
DENSE_RANK() OVER(ORDER BY profit_margin DESC) AS Rank_by_Margin
FROM tmp_product_metrics
ORDER BY CAST(REPLACE(profit_margin, '%', '') AS DECIMAL(10,2)) DESC;

-- 4. Underperforming and Loss-Making Products

SELECT product_id, 
product_name, 
total_orders,
total_sales, 
total_profit, 
quantity_sold,
avg_discount,
CONCAT(profit_margin,'%') AS profit_margin, 
CONCAT(sales_contribution, '%') AS sales_contribution, 
DENSE_RANK() OVER(ORDER BY total_profit ASC) AS Rank_by_Loss,
DENSE_RANK() OVER(ORDER BY profit_margin ASC) AS Rank_by_Margin

FROM tmp_product_metrics
ORDER BY total_profit ASC;

-- 5. Product-Level Business Opportunity Analysis

WITH product_benchmark AS(
SELECT *,
AVG(total_sales) OVER() AS avg_product_sales,
SUM(total_profit) OVER() /NULLIF(SUM(total_sales) OVER(),0) * 100 AS overall_profit_margin
FROM tmp_product_metrics)

SELECT 
product_id, 
product_name, 
total_orders,
total_sales, 
total_profit, 
quantity_sold,
avg_discount,
CONCAT(profit_margin,'%') AS profit_margin, 
CONCAT(sales_contribution, '%') AS sales_contribution,
ROUND(avg_product_sales,2) AS avg_product_sales,
CONCAT(ROUND(overall_profit_margin,2), '%') AS overall_profit_margin,

CASE 
WHEN total_sales>avg_product_sales
THEN 'High Sales'
ELSE 'Low Sales'
END AS Sales_Performance,

CASE 
WHEN profit_margin >= overall_profit_margin
THEN 'Healthy Margin'
ELSE 'Low Margin'
END AS margin_performance,

CASE
WHEN total_sales>avg_product_sales
AND profit_margin <= overall_profit_margin
THEN 'Improve Profit Margin'

WHEN total_sales<avg_product_sales
AND profit_margin >= overall_profit_margin
THEN 'Grow Sales'

WHEN total_sales>avg_product_sales
AND profit_margin > overall_profit_margin
THEN 'Strong Performer'

ELSE 'Review Product'

END AS 'Business oppourtunity'

FROM product_benchmark
ORDER BY total_sales DESC;

-- 6. Product Sales Contribution and Pareto Analysis

WITH Ranked_Products AS (
    SELECT
        *,

        ROW_NUMBER() OVER (
            ORDER BY total_sales DESC, product_id
        ) AS product_position,

        SUM(total_sales) OVER (
            ORDER BY total_sales DESC, product_id
            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND CURRENT ROW
        ) AS cumulative_sales,

        SUM(total_sales) OVER () AS overall_sales,

        COUNT(*) OVER () AS total_products

    FROM tmp_product_metrics
)
-- Product-Level Business Opportunity Analysis

SELECT 
*,
ROUND(
        cumulative_sales
        / NULLIF(overall_sales, 0) * 100,
        2
    ) AS cumulative_sales_contribution_percentage,
     ROUND(
        product_position
        / NULLIF(total_products, 0) * 100,
        2
    ) AS cumulative_product_share_percentage
FROM Ranked_Products;
