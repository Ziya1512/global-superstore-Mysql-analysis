-- 1. Overall Business Performance

-- (a) Basic KPIs
SELECT CONCAT(ROUND(SUM(sales)/1000000,2),'M') AS Total_Sales,
CONCAT(ROUND(SUM(profit)/1000000,2),'M') AS Total_Profit,
COUNT(DISTINCT(order_id)) AS Total_order,
COUNT(DISTINCT(customer_id)) Total_Customers,
CONCAT('$',ROUND(AVG(sales))) AS AOV,
CONCAT('$',ROUND((AVG(discount)),2)) AS Avg_Discount_Amount
FROM orders;

-- (b) Sales Growth by Year
WITH Yearly_Sales AS(
SELECT YEAR(order_date) AS 'Year', 
ROUND(SUM(sales),2) AS total_sales
FROM orders
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date) ASC)

, Sales_Growth AS(
SELECT YEAR, total_sales,
LAG(total_sales) OVER(ORDER BY Year) AS Previous_Year_Sales
FROM Yearly_Sales
)

SELECT YEAR, TOTAL_SALES, PREVIOUS_YEAR_SALES, 
CONCAT(ROUND((TOTAL_SALES - PREVIOUS_YEAR_SALES)/NULLIF(PREVIOUS_YEAR_SALES,0)*100,2), '%') AS 'YoY_Growth'
FROM Sales_Growth
ORDER BY YEAR;

-- (c) Profit Growth YoY
WITH Yearly_Profit AS(
SELECT YEAR(order_date) AS 'Year', 
CONCAT(ROUND(SUM(profit)/1000,2),'K') AS total_profit
FROM orders
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date) ASC)

, Profit_Growth AS(
SELECT YEAR, total_profit,
LAG(total_profit) OVER(ORDER BY Year) AS Previous_Year_Profit
FROM Yearly_Profit
)

SELECT YEAR, TOTAL_Profit, PREVIOUS_YEAR_Profit, 
CONCAT(ROUND((TOTAL_Profit - PREVIOUS_YEAR_Profit)/NULLIF(PREVIOUS_YEAR_Profit,0)*100,2), '%') AS 'YoY_Growth'
FROM Profit_Growth
ORDER BY YEAR;

-- 2. Sales and Profit by Region

-- (a). Overall Region Analysis

SELECT DISTINCT Region,
ROUND(SUM(sales),2) AS Total_sales, 
ROUND(SUM(profit),2) AS Total_Profit, 
COUNT(DISTINCT order_id) AS Total_Orders, 
COUNT(DISTINCT customer_id) AS Total_Customers,
SUM(quantity) AS Quantity_Sold, 
ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin, 
ROUND(SUM(sales) / NULLIF((SELECT SUM(sales) FROM orders), 0) * 100,2) AS sales_contribution,
RANK() OVER(ORDER BY SUM(sales) DESC) AS Rank_Sales, 
RANK() OVER(ORDER BY SUM(profit) DESC) AS Rank_Profit
    FROM orders
    GROUP BY Region;
    
-- (b). YoY Region Sales Growth
WITH Yearly_Sales AS (
    SELECT
        Region,
        YEAR(order_date) AS Year,
        SUM(sales) AS Total_Sales
    FROM orders
    GROUP BY Region, YEAR(order_date)
),

Sales_Growth AS (
    SELECT
        Region,
        Year,
        Total_Sales,
        LAG(Total_Sales) OVER (
            PARTITION BY Region
            ORDER BY Year
        ) AS Previous_Year_Sales
    FROM Yearly_Sales
)

SELECT
    Region,
    Year,
    CONCAT(ROUND(Total_Sales / 1000, 2), 'K') AS Total_Sales,
    CONCAT(ROUND(Previous_Year_Sales / 1000, 2), 'K') AS Previous_Year_Sales,
    CONCAT(
        ROUND(
            (Total_Sales - Previous_Year_Sales)
            / NULLIF(Previous_Year_Sales, 0) * 100,
            2
        ),
        '%'
    ) AS YoY_Growth
FROM Sales_Growth
ORDER BY Region, Year;

-- (c). YoY Region Profit Growth
WITH Yearly_Profit AS (
    SELECT
        Region,
        YEAR(order_date) AS Year,
        SUM(profit) AS Total_Profit
    FROM orders
    GROUP BY Region, YEAR(order_date)
),

Profit_Growth AS (
    SELECT
        Region,
        Year,
        Total_Profit,
        LAG(Total_Profit) OVER (
            PARTITION BY Region
            ORDER BY Year
        ) AS Previous_Year_Profit
    FROM Yearly_Profit
)

SELECT
    Region,
    Year,
    CONCAT(ROUND(Total_Profit / 1000, 2), 'K') AS Total_Profit,
    CONCAT(ROUND(Previous_Year_Profit / 1000, 2), 'K') AS Previous_Year_Profit,
    CONCAT(
        ROUND(
            (Total_Profit - Previous_Year_Profit)
            / NULLIF(Previous_Year_Profit, 0) * 100,
            2
        ),
        '%'
    ) AS YoY_Growth
FROM Profit_Growth
ORDER BY Region, Year;


-- 3. Sales and Profit by Country

-- (a). Country-Wise Analysis

SELECT DISTINCT Country,
ROUND(SUM(sales),2) AS Total_sales, 
ROUND(SUM(profit),2) AS Total_Profit, 
COUNT(DISTINCT order_id) AS Total_Orders, 
COUNT(DISTINCT customer_id) AS Total_Customers,
SUM(quantity) AS Quantity_Sold, 
ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin, 
ROUND(SUM(sales) / NULLIF((SELECT SUM(sales) FROM orders), 0) * 100,2) AS sales_contribution,
RANK() OVER(ORDER BY SUM(sales) DESC) AS Rank_Sales, 
RANK() OVER(ORDER BY SUM(profit) DESC) AS Rank_Profit
    FROM orders
    GROUP BY Country;
    
-- (b). YoY Country-Wise Sales Growth

WITH Yearly_Sales AS (
    SELECT
        Country,
        YEAR(order_date) AS Year,
        SUM(sales) AS Total_Sales
    FROM orders
    GROUP BY Country, YEAR(order_date)
),

Sales_Growth AS (
    SELECT
        Country,
        Year,
        Total_Sales,
        LAG(Total_Sales) OVER (
            PARTITION BY Country
            ORDER BY Year
        ) AS Previous_Year_Sales
    FROM Yearly_Sales
)

SELECT
    Country,
    Year,
    CONCAT(ROUND(Total_Sales / 1000, 2), 'K') AS Total_Sales,
    CONCAT(ROUND(Previous_Year_Sales / 1000, 2), 'K') AS Previous_Year_Sales,
    CONCAT(
        ROUND(
            (Total_Sales - Previous_Year_Sales)
            / NULLIF(Previous_Year_Sales, 0) * 100,
            2
        ),
        '%'
    ) AS YoY_Growth
FROM Sales_Growth
ORDER BY Country, Year;

-- (c) YoY Country-Wise Profit Growth

WITH Yearly_Profit AS (
    SELECT
        Country,
        YEAR(order_date) AS Year,
        SUM(profit) AS Total_Profit
    FROM orders
    GROUP BY Country, YEAR(order_date)
),

Profit_Growth AS (
    SELECT
        Country,
        Year,
        Total_Profit,
        LAG(Total_Profit) OVER (
            PARTITION BY Country
            ORDER BY Year
        ) AS Previous_Year_Profit
    FROM Yearly_Profit
)

SELECT
    Country,
    Year,
    CONCAT(ROUND(Total_Profit / 1000, 2), 'K') AS Total_Profit,
    CONCAT(ROUND(Previous_Year_Profit / 1000, 2), 'K') AS Previous_Year_Profit,
    CONCAT(
        ROUND(
            (Total_Profit - Previous_Year_Profit)
            / NULLIF(Previous_Year_Profit, 0) * 100,
            2
        ),
        '%'
    ) AS YoY_Growth
FROM Profit_Growth
ORDER BY Country, Year;

-- 4. Market-Wise Analysis

SELECT market, CONCAT(ROUND(SUM(sales)/1000000,2),'M') AS Total_Sales, CONCAT(ROUND(SUM(profit)/1000,2),'K') AS Total_Profit,
COUNT(DISTINCT order_id) AS Total_Orders, COUNT(DISTINCT customer_id) AS Total_Customers,
RANK() OVER(ORDER BY SUM(sales) DESC) AS Rank_Sales, 
RANK() OVER(ORDER BY SUM(profit) DESC) AS Rank_Profit,
CONCAT(ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2),'%') AS profit_margin, 
CONCAT(ROUND(SUM(sales) / NULLIF((SELECT SUM(sales) FROM orders), 0) * 100,2),'%') AS sales_contribution
FROM orders
GROUP BY Market;

-- 5. Category-Wise Analysis

SELECT p.category, 
CONCAT(ROUND(SUM(o.sales)/1000000,2),'M') AS Total_Sales, 
CONCAT(ROUND(SUM(o.profit)/1000,2),'K') AS Total_Profit,
COUNT(DISTINCT o.order_id) AS Total_Orders, 
COUNT(DISTINCT o.customer_id) AS Total_Customers,
RANK() OVER(ORDER BY SUM(o.sales) DESC) AS Rank_Sales, 
RANK() OVER(ORDER BY SUM(o.profit) DESC) AS Rank_Profit,
CONCAT(ROUND(SUM(o.profit) / NULLIF(SUM(o.sales), 0) * 100, 2),'%') AS profit_margin,
CONCAT(ROUND(SUM(o.sales)/(SELECT SUM(sales) FROM orders) * 100,2),'%') AS Category_Contribution_Percentage
FROM products p JOIN orders o ON
p.product_id=o.product_id
GROUP BY p.category;

-- 6. Sales by Customer Segment
SELECT c.segment,
CONCAT(ROUND(SUM(o.sales)/1000000,2),'M') AS Total_Sales,
CONCAT(ROUND(SUM(o.profit)/1000,2),'K') AS Total_Profit,
COUNT(DISTINCT o.order_id) AS Total_Orders,
COUNT(DISTINCT o.customer_id) AS Total_Customers,
ROUND(AVG(o.sales),2) AS AOV,
RANK() OVER(ORDER BY SUM(o.sales) DESC) AS Sales_Rank,
RANK() OVER(ORDER BY SUM(o.profit) DESC) AS Profit_Rank,
CONCAT(ROUND(SUM(o.sales)/(SELECT SUM(sales) FROM orders)* 100,2),'%') AS Segment_Contribution_Percentage

FROM orders o JOIN customers c ON c.customer_id=o.customer_id
GROUP BY c.segment;

-- 7. Order Priority Analysis
SELECT order_priority,
CONCAT(ROUND(SUM(sales)/1000000,2),'M') AS Total_Sales,
CONCAT(ROUND(SUM(profit)/1000,2),'K') AS Total_Profit,
COUNT(DISTINCT order_id) AS Total_Orders,
COUNT(DISTINCT customer_id) AS Total_Customers,
ROUND(AVG(sales),2) AS AOV,
RANK() OVER(ORDER BY SUM(sales) DESC) AS Sales_Rank,
RANK() OVER(ORDER BY SUM(profit) DESC) AS Profit_Rank,
CONCAT(ROUND(SUM(sales)/(SELECT SUM(sales) FROM orders)* 100,2),'%') AS Segment_Contribution_Percentage
FROM orders
GROUP BY order_priority;

-- 8. Shipping Mode Analysis
-- (a). Overall Analysis (Shipping)
SELECT ship_mode,
CONCAT(ROUND(SUM(shipping_cost/1000),2),'K') AS Total_Shipping_Cost,
CONCAT(ROUND(SUM(sales)/1000000,2),'M') AS Total_Sales,
CONCAT(ROUND(SUM(profit)/1000,2),'K') AS Total_Profit,
COUNT(DISTINCT order_id) AS Total_Orders,
COUNT(DISTINCT customer_id) AS Total_Customers,
ROUND(AVG(sales),2) AS AOV,
RANK() OVER(ORDER BY SUM(sales) DESC) AS Sales_Rank,
RANK() OVER(ORDER BY SUM(profit) DESC) AS Profit_Rank,
CONCAT(ROUND(SUM(sales)/(SELECT SUM(sales) FROM orders)* 100,2),'%') AS Mode_Contribution_Percentage
FROM orders
GROUP BY ship_mode;

-- (b). Average Shipping Cost Distinct Order

WITH Order_Shipping AS (
    SELECT
        order_id,
        ship_mode,
        MAX(shipping_cost) AS order_shipping_cost
    FROM orders
    GROUP BY order_id, ship_mode
)
SELECT
    ship_mode,
    COUNT(*) AS Total_Orders,
    ROUND(AVG(order_shipping_cost), 2)
        AS Avg_Shipping_Cost_Per_Order
FROM Order_Shipping
GROUP BY ship_mode;

-- 9. Overall Profit Margin
SELECT
CONCAT(ROUND(SUM(sales)/1000000,2),'M') AS Total_Sales,
CONCAT(ROUND(SUM(profit)/1000,2),'K') AS Total_Profit,
CONCAT(ROUND(SUM(profit)/NULLIF(SUM(sales),0),2)*100,'%') AS Profit_Contribution_Percentage
FROM orders;

-- 10. Discount and Profitability Analysis

-- (a). Overall
WITH Discount_Analysis AS (
    SELECT
        CASE
            WHEN discount IS NULL THEN 'Unknown'
            WHEN discount = 0 THEN '0% - No Discount'
            WHEN discount <= 0.10 THEN '1-10%'
            WHEN discount <= 0.20 THEN '11-20%'
            WHEN discount <= 0.30 THEN '21-30%'
            ELSE 'Above 30%'
        END AS Discount_Band,
        discount,
        order_id,
        sales,
        profit
    FROM orders
)
SELECT
    Discount_Band,
    COUNT(*) AS Items,
    COUNT(DISTINCT order_id) AS Total_Orders,
    ROUND(AVG(discount) * 100, 2) AS Avg_Discount_Percentage,
    CONCAT(ROUND(SUM(sales)/1000000, 2),'M') AS Total_Sales,
    CONCAT(ROUND(SUM(profit)/1000, 2),'K') AS Total_Profit,
    CONCAT(ROUND(
        SUM(profit) / NULLIF(SUM(sales), 0) * 100,
        2
    ),'%') AS Profit_Margin_Percentage
FROM Discount_Analysis
GROUP BY Discount_Band
ORDER BY MIN(discount);

-- (b). Discount Impact by Product Category

SELECT
    p.category,
    CASE
        WHEN o.discount = 0 THEN '0% - No Discount'
        WHEN o.discount <= 0.10 THEN '1-10%'
        WHEN o.discount <= 0.20 THEN '11-20%'
        WHEN o.discount <= 0.30 THEN '21-30%'
        ELSE 'Above 30%'
    END AS Discount_Band,
    ROUND(SUM(o.sales), 2) AS Total_Sales,
    ROUND(SUM(o.profit), 2) AS Total_Profit,
    ROUND(AVG(o.discount) * 100, 2) AS Avg_Discount_Percentage,
    ROUND(
        SUM(o.profit) / NULLIF(SUM(o.sales), 0) * 100,
        2
    ) AS Profit_Margin_Percentage
FROM orders o
JOIN products p
    ON o.product_id = p.product_id
GROUP BY
    p.category,
    Discount_Band
ORDER BY
    p.category,
    MIN(o.discount);
    
-- 11. High-Sales, Low-Margin Business Areas

WITH Group_Performance AS (

    -- Regional performance
    SELECT
        'Region' AS Analysis_Level,
        region AS Group_Name,
        SUM(sales) AS Total_Sales,
        SUM(profit) AS Total_Profit
    FROM orders
    GROUP BY region

    UNION ALL

    -- Country performance
    SELECT
        'Country',
        country,
        SUM(sales),
        SUM(profit)
    FROM orders
    GROUP BY country

    UNION ALL

    -- Category performance
    SELECT
        'Category',
        p.category,
        SUM(o.sales),
        SUM(o.profit)
    FROM orders o
    JOIN products p
        ON o.product_id = p.product_id
    GROUP BY p.category
),

Business_Benchmark AS (
    SELECT
        SUM(sales) AS Business_Sales,
        SUM(profit) / NULLIF(SUM(sales), 0) * 100
            AS Overall_Profit_Margin
    FROM orders
),

Group_Averages AS (
    SELECT
        Analysis_Level,
        AVG(Total_Sales) AS Average_Group_Sales
    FROM Group_Performance
    GROUP BY Analysis_Level
),

Group_Metrics AS (
    SELECT
        gp.Analysis_Level,
        gp.Group_Name,
        gp.Total_Sales,
        gp.Total_Profit,

        gp.Total_Profit /
            NULLIF(gp.Total_Sales, 0) * 100
            AS Profit_Margin,

        gp.Total_Sales /
            NULLIF(bb.Business_Sales, 0) * 100
            AS Sales_Contribution,

        RANK() OVER (
            PARTITION BY gp.Analysis_Level
            ORDER BY gp.Total_Sales DESC
        ) AS Sales_Rank

    FROM Group_Performance gp
    CROSS JOIN Business_Benchmark bb
)

SELECT
    gm.Analysis_Level,
    gm.Group_Name,
    ROUND(gm.Total_Sales, 2) AS Total_Sales,
    ROUND(gm.Total_Profit, 2) AS Total_Profit,
    ROUND(gm.Profit_Margin, 2) AS Profit_Margin_Percentage,
    ROUND(gm.Sales_Contribution, 2) AS Sales_Contribution_Percentage,
    gm.Sales_Rank,
    ROUND(bb.Overall_Profit_Margin, 2) AS Overall_Margin_Benchmark,

    CASE
        WHEN gm.Total_Sales > ga.Average_Group_Sales
         AND gm.Profit_Margin < bb.Overall_Profit_Margin
            THEN 'HIGH SALES - LOW MARGIN'

        WHEN gm.Total_Sales > ga.Average_Group_Sales
         AND gm.Profit_Margin >= bb.Overall_Profit_Margin
            THEN 'HIGH SALES - HEALTHY MARGIN'

        WHEN gm.Total_Sales <= ga.Average_Group_Sales
         AND gm.Profit_Margin < bb.Overall_Profit_Margin
            THEN 'LOWER SALES - LOW MARGIN'

        ELSE 'LOWER SALES - HEALTHY MARGIN'
    END AS Business_Flag

FROM Group_Metrics gm
JOIN Group_Averages ga
    ON gm.Analysis_Level = ga.Analysis_Level
CROSS JOIN Business_Benchmark bb

ORDER BY
    CASE
        WHEN gm.Total_Sales > ga.Average_Group_Sales
         AND gm.Profit_Margin < bb.Overall_Profit_Margin
            THEN 1
        ELSE 2
    END,
    gm.Analysis_Level,
    gm.Sales_Rank;