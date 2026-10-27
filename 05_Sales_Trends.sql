-- Project: Global Superstore SQL Analysis
-- Database: MySQL 8.0
-- Purpose: Analyze monthly performance, growth, and seasonality.
-- Execution: Refer to README.md for setup instructions.

-- CTE Sales Trends

WITH Sales_Trends AS (
SELECT YEAR(order_date) AS order_year, 
MONTH(order_date) AS month_number,
MONTHNAME(order_date) AS MONTH_NAME, 
ROUND(SUM(sales),2) AS total_sales,
ROUND(SUM(profit),2) AS total_profit,
CONCAT(ROUND(
    SUM(profit) / NULLIF(SUM(sales), 0) * 100,
    2
),'%') AS profit_margin,
COUNT(order_id) AS no_of_Orders
FROM orders
GROUP BY YEAR(order_date), MONTHNAME(order_date), MONTH(order_date)
ORDER BY YEAR(order_date) ASC, MONTHNAME(order_date) ASC)

-- 1. Monthly Sales, Profit, and Order Trends

SELECT YEAR(order_date), 
MONTHNAME(order_date), 
ROUND(SUM(sales),2) total_sales, 
ROUND(SUM(profit),2)total_profit, 
COUNT(DISTINCT order_id) total_orders, 
SUM(quantity) quantity_sold,
CONCAT(ROUND(
    SUM(profit) / NULLIF(SUM(sales), 0) * 100,
    2
),'%') AS profit_margin
FROM orders
GROUP BY YEAR(order_date), MONTHNAME(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTHNAME(order_date) ASC;

-- 2. Month-over-Month (MoM) Sales Growth

WITH Sales_Trends AS (SELECT YEAR(order_date) AS order_year, 
MONTH(order_date) AS month_no,
MONTHNAME(order_date) MONTH_NAME, 
ROUND(SUM(sales),2) total_sales
FROM orders
GROUP BY YEAR(order_date), MONTHNAME(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTHNAME(order_date) ASC)

SELECT *,
LAG(total_sales, 1) OVER(ORDER BY order_year, month_no) prev_mon_sales,
total_sales-LAG(total_sales, 1) OVER(ORDER BY order_year, month_no) AS change_in_sales,
CONCAT(ROUND(
    (total_sales - LAG(total_sales) OVER (
        ORDER BY order_year, month_no
    ))
    / NULLIF(
        LAG(total_sales) OVER (
            ORDER BY order_year, month_no
        ), 0
    ) * 100,
    2),'%'
) AS mom_sales_growth_percentage
FROM Sales_trends;

-- 3. Month-over-Month (MoM) Profit Growth

WITH Sales_Trends AS (SELECT YEAR(order_date) AS order_year, 
MONTH(order_date) AS month_no,
MONTHNAME(order_date) MONTH_NAME, 
ROUND(SUM(profit),2)total_profit,
CONCAT(ROUND(
    SUM(profit) / NULLIF(SUM(sales), 0) * 100,
    2
),'%') AS profit_margin
FROM orders
GROUP BY YEAR(order_date), MONTHNAME(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTHNAME(order_date) ASC)

SELECT *,
LAG(total_profit, 1) OVER(ORDER BY order_year, month_no) prev_mon_sales,
ROUND(total_profit-LAG(total_profit, 1) OVER(ORDER BY order_year, month_no),'2') AS change_in_profit,
CONCAT(ROUND(
    (total_profit - LAG(total_profit) OVER (
        ORDER BY order_year, month_no
    ))
    / NULLIF(
        LAG(total_profit) OVER (
            ORDER BY order_year, month_no
        ), 0
    ) * 100,
    2),'%'
) AS mom_profit_growth_percentage
FROM Sales_trends;

-- 4. Rolling 3-Month Sales and Profit Analysis

WITH Sales_Trends AS (
SELECT YEAR(order_date) AS order_year, 
MONTH(order_date) AS month_number,
MONTHNAME(order_date) AS MONTH_NAME, 
ROUND(SUM(sales),2) AS total_sales,
ROUND(SUM(profit),2) AS total_profit,
CONCAT(ROUND(
    SUM(profit) / NULLIF(SUM(sales), 0) * 100,
    2
),'%') AS profit_margin
FROM orders
GROUP BY YEAR(order_date), MONTHNAME(order_date), MONTH(order_date)
ORDER BY YEAR(order_date) ASC, MONTHNAME(order_date) ASC)

SELECT
order_year,
month_name,
profit_margin,
total_sales,
ROUND(SUM(total_sales) OVER(ORDER BY MONTH_NAME ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) AS Rolling_Sales,
total_profit,
ROUND(SUM(total_profit) OVER(ORDER BY MONTH_NAME ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) AS Rolling_Profit

FROM Sales_trends
ORDER BY order_year ASC, month_number;

-- 5. Cumulative Sales and Profit Trends

WITH Sales_Trends AS (
SELECT YEAR(order_date) AS order_year, 
MONTH(order_date) AS month_number,
MONTHNAME(order_date) AS MONTH_NAME, 
ROUND(SUM(sales),2) AS total_sales,
ROUND(SUM(profit),2) AS total_profit,
CONCAT(ROUND(
    SUM(profit) / NULLIF(SUM(sales), 0) * 100,
    2
),'%') AS profit_margin
FROM orders
GROUP BY YEAR(order_date), MONTHNAME(order_date), MONTH(order_date)
ORDER BY YEAR(order_date) ASC, MONTHNAME(order_date) ASC)

SELECT
order_year,
month_name,
profit_margin,
total_sales,
ROUND(SUM(total_sales) OVER(ORDER BY order_year , MONTH_number ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),2) AS Cumulative_Sales,
total_profit,
ROUND(SUM(total_profit) OVER(ORDER BY order_year, month_number ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),2) AS Cumulative_Profit

FROM Sales_trends
ORDER BY order_year ASC, month_number;

-- 6. Monthly Seasonality Analysis
WITH Sales_Trends AS (
SELECT YEAR(order_date) AS order_year, 
MONTH(order_date) AS month_number,
MONTHNAME(order_date) AS MONTH_NAME, 
ROUND(SUM(sales),2) AS total_sales,
ROUND(SUM(profit),2) AS total_profit,
CONCAT(ROUND(
    SUM(profit) / NULLIF(SUM(sales), 0) * 100,
    2
),'%') AS profit_margin,
COUNT(DISTINCT order_id) AS no_of_Orders
FROM orders
GROUP BY YEAR(order_date), MONTHNAME(order_date), MONTH(order_date)
ORDER BY YEAR(order_date) ASC, MONTHNAME(order_date) ASC)

SELECT
order_year,
month_name,
month_number,
profit_margin,
ROUND(AVG(total_sales) OVER(PARTITION BY month_number),2) Avg_Monthly_Sales,
ROUND(AVG(total_profit) OVER(PARTITION BY month_number),2) Avg_Monthly_Profit,
MAX(total_sales) OVER(PARTITION BY month_number) Max_monthly_Sales,
MIN(total_sales) OVER(PARTITION BY month_number) Min_monthly_Sales,
No_of_Orders

FROM Sales_trends
ORDER BY order_year ASC, month_number;

-- 7. Best and Worst Performing Months

WITH Sales_Trends AS (
SELECT YEAR(order_date) AS order_year, 
MONTH(order_date) AS month_number,
MONTHNAME(order_date) AS MONTH_NAME, 
ROUND(SUM(sales),2) AS total_sales,
ROUND(SUM(profit),2) AS total_profit,
CONCAT(ROUND(
    SUM(profit) / NULLIF(SUM(sales), 0) * 100,
    2
),'%') AS profit_margin
FROM orders
GROUP BY YEAR(order_date), MONTHNAME(order_date), MONTH(order_date)
ORDER BY YEAR(order_date) ASC, MONTH(order_date) ASC, MONTHNAME(order_date))

, Sales_Benchmark AS ( SELECT *,
AVG(total_sales) OVER () AS avg_monthly_sales,
AVG(total_profit) OVER() AS avg_monthly_profit
FROM Sales_Trends)

SELECT
order_year,
month_name,
profit_margin,
total_sales,
total_profit,
DENSE_RANK() OVER(ORDER BY total_sales DESC) Rank_by_Sales,
DENSE_RANK() OVER(ORDER BY total_profit DESC) Rank_by_Profit,
CASE
WHEN total_sales>avg_monthly_sales
THEN 'High Sales ' 
WHEN total_sales=avg_monthly_sales
THEN 'Moderate Sales'
ELSE 'Low Sales'
END AS 'Sales Performance',

CASE
WHEN total_sales>avg_monthly_profit
THEN 'High Profit' 
WHEN total_sales=avg_monthly_profit
THEN 'Moderate Profit'
ELSE 'Low Profit'
END AS 'Profit Performance'

FROM Sales_Benchmark
ORDER BY Rank_by_Sales ASC;