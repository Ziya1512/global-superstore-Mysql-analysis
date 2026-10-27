-- Project: Global Superstore SQL Analysis
-- Database: MySQL 8.0
-- Purpose: Evaluate customer value, RFM segments, and repeat purchases.
-- Execution: Refer to README.md for setup instructions.

-- Important: Temporary tables and session variables exist within the current MySQL session. If you open a new connection, rerun the setup section before executing the analytical queries.

-- 0. Temporary Customer Analysis Tables

DROP TEMPORARY TABLE IF EXISTS tmp_customer_rfm;
DROP TEMPORARY TABLE IF EXISTS tmp_customer_metrics;
DROP TEMPORARY TABLE IF EXISTS tmp_customer_order_summary;

SET @analysis_date = (
    SELECT MAX(order_date)
    FROM orders
);

-- (a). Customer Order Summary

CREATE TEMPORARY TABLE tmp_customer_order_summary AS
SELECT
    customer_id,
    order_id,
    MIN(order_date) AS order_date,
    SUM(sales) AS order_sales,
    SUM(profit) AS order_profit,
    SUM(quantity) AS order_quantity
FROM orders
GROUP BY customer_id, order_id;

-- (b). Customer Metrics

CREATE TEMPORARY TABLE tmp_customer_metrics AS
SELECT
    c.customer_id,
    c.customer_name,
    c.segment,

    COUNT(co.order_id) AS total_orders,

    COALESCE(SUM(co.order_sales), 0) AS lifetime_sales,
    COALESCE(SUM(co.order_profit), 0) AS lifetime_profit,
    COALESCE(SUM(co.order_quantity), 0) AS total_quantity,

    AVG(co.order_sales) AS avg_order_value,

    MIN(co.order_date) AS first_order_date,
    MAX(co.order_date) AS last_order_date,

    ROUND(
        SUM(co.order_profit)
        / NULLIF(SUM(co.order_sales), 0) * 100,
        2
    ) AS lifetime_profit_margin,

    DATEDIFF(
      @analysis_date, 
        MAX(co.order_date)
    ) AS days_since_last_order

FROM customers c
LEFT JOIN tmp_customer_order_summary co
    ON c.customer_id = co.customer_id
GROUP BY
    c.customer_id,
    c.customer_name,
    c.segment;
    
-- (c). RFM Customer Segmentation

CREATE TEMPORARY TABLE tmp_customer_rfm AS

SELECT
    s.*,

 CASE
    WHEN s.R_Score >= 4
     AND s.F_Score >= 4
     AND s.M_Score >= 4
        THEN 'Champions'

    WHEN s.R_Score <= 2
     AND s.F_Score >= 4
     AND s.M_Score >= 4
        THEN 'High-Value At Risk'

    WHEN s.R_Score <= 2
     AND s.F_Score >= 3
        THEN 'At-Risk Customers'

    WHEN s.F_Score >= 4
     AND s.M_Score >= 3
        THEN 'Loyal Customers'

    WHEN s.F_Score <= 2
     AND s.M_Score <= 2
        THEN 'Low-Engagement Customers'

    WHEN s.R_Score >= 4
     AND s.F_Score <= 2
        THEN 'Recent / Low-Frequency Customers'

    ELSE 'Potential / Developing Customers'
END AS customer_rfm_segment

FROM (
    SELECT
        m.*,
-- Reverse the recency ordering so more recent purchases receive higher scores.
        NTILE(5) OVER (
            ORDER BY days_since_last_order DESC
        ) AS R_Score,

        NTILE(5) OVER (
            ORDER BY total_orders ASC
        ) AS F_Score,

        NTILE(5) OVER (
            ORDER BY lifetime_sales ASC
        ) AS M_Score

    FROM tmp_customer_metrics m
    WHERE total_orders > 0
) s;

-- 1. Customer Ranking and Lifetime Value

SELECT
    customer_id,
    customer_name,
    segment AS business_segment,

    total_orders,
    ROUND(lifetime_sales, 2) AS lifetime_sales,
    ROUND(lifetime_profit, 2) AS lifetime_profit,
    lifetime_profit_margin,
    total_quantity,
    ROUND(avg_order_value, 2) AS avg_order_value,

    first_order_date,
    last_order_date,
    days_since_last_order,

    RANK() OVER (
        ORDER BY lifetime_sales DESC
    ) AS sales_rank,

    RANK() OVER (
        ORDER BY lifetime_profit DESC
    ) AS profit_rank,

    RANK() OVER (
        ORDER BY total_orders DESC
    ) AS order_count_rank

FROM tmp_customer_metrics
WHERE total_orders > 0
ORDER BY sales_rank, customer_id;


-- 2. Customer-Level RFM Results

SELECT
    customer_id,
    customer_name,
    segment AS business_segment,

    total_orders,
    ROUND(lifetime_sales, 2) AS lifetime_sales,
    days_since_last_order,

    R_Score,
    F_Score,
    M_Score,

    CONCAT(R_Score, F_Score, M_Score) AS RFM_Code,

    customer_rfm_segment

FROM tmp_customer_rfm
ORDER BY
    M_Score DESC,
    F_Score DESC,
    R_Score DESC;
    
-- 3. RFM Segment Performance Summary

SELECT
    customer_rfm_segment,

    COUNT(*) AS total_customers,

    ROUND(AVG(days_since_last_order), 1)
        AS avg_days_since_last_order,

    ROUND(AVG(total_orders), 2)
        AS avg_orders_per_customer,

    ROUND(SUM(lifetime_sales), 2)
        AS total_sales,

    ROUND(SUM(lifetime_profit), 2)
        AS total_profit,

    CONCAT(ROUND(
        SUM(lifetime_profit)
        / NULLIF(SUM(lifetime_sales), 0) * 100,
        2
    ),'%') AS profit_margin_percentage,

    CONCAT(ROUND(
        SUM(lifetime_sales)
        / NULLIF(
            (SELECT SUM(lifetime_sales)
             FROM tmp_customer_metrics),
            0
        ) * 100,
        2
    ),'%') AS sales_contribution_percentage

FROM tmp_customer_rfm
GROUP BY customer_rfm_segment
ORDER BY total_sales DESC;



-- 4. One-Time vs Repeat Customer Analysis

SET @total_customers = (
    SELECT COUNT(*)
    FROM tmp_customer_metrics
);

SET @total_sales = (
    SELECT SUM(lifetime_sales)
    FROM tmp_customer_metrics
);

SELECT
    CASE
        WHEN total_orders = 0
            THEN 'No Purchases'
        WHEN total_orders = 1
            THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END AS purchase_status,

    COUNT(*) AS total_customers,

    ROUND(
        COUNT(*) * 100.0
        / NULLIF(@total_customers, 0),
        2
    ) AS customer_share_percentage,

    SUM(total_orders) AS total_orders,

    ROUND(
        AVG(total_orders),
        2
    ) AS avg_orders_per_customer,

    ROUND(
        SUM(lifetime_sales),
        2
    ) AS total_sales,

    ROUND(
        SUM(lifetime_sales) * 100.0
        / NULLIF(@total_sales, 0),
        2
    ) AS sales_contribution_percentage

FROM tmp_customer_metrics

GROUP BY purchase_status

ORDER BY total_customers DESC;

-- 5. Repeat Purchase Behavior by Business Segment

SELECT
    segment AS business_segment,

    COUNT(*) AS purchasing_customers,

    SUM(
        CASE
            WHEN total_orders >= 2 THEN 1
            ELSE 0
        END
    ) AS repeat_customers,

    ROUND(
        SUM(
            CASE
                WHEN total_orders >= 2 THEN 1
                ELSE 0
            END
        ) * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS repeat_customer_rate_percentage,

    SUM(
        CASE
            WHEN total_orders = 1 THEN 1
            ELSE 0
        END
    ) AS one_time_customers,

    ROUND(AVG(total_orders), 2)
        AS avg_orders_per_customer

FROM tmp_customer_metrics
WHERE total_orders > 0
GROUP BY segment
ORDER BY repeat_customer_rate_percentage DESC;

-- 6. Customer Purchase Frequency Distribution

SET @total_purchasing_customers = (
    SELECT COUNT(*)
    FROM tmp_customer_metrics
    WHERE total_orders > 0
);



WITH Frequency_Groups AS (
    SELECT
        customer_id,
        total_orders,
        lifetime_sales,

        CASE
            WHEN total_orders = 1 THEN '1 Order'
            WHEN total_orders BETWEEN 2 AND 3 THEN '2-3 Orders'
            WHEN total_orders BETWEEN 4 AND 5 THEN '4-5 Orders'
            ELSE '6+ Orders'
        END AS purchase_frequency_group

    FROM tmp_customer_metrics
    WHERE total_orders > 0
)
SELECT
    purchase_frequency_group,

    COUNT(*) AS total_customers,

    ROUND(AVG(total_orders), 2)
        AS avg_orders_per_customer,

    ROUND(AVG(lifetime_sales), 2)
        AS avg_lifetime_sales,

CONCAT(ROUND(
    COUNT(*) * 100.0
    / NULLIF(@total_purchasing_customers, 0),
    2),'%'
) AS customer_share_percentage

FROM Frequency_Groups
GROUP BY purchase_frequency_group
ORDER BY
    CASE purchase_frequency_group
        WHEN '1 Order' THEN 1
        WHEN '2-3 Orders' THEN 2
        WHEN '4-5 Orders' THEN 3
        WHEN '6+ Orders' THEN 4
    END;
    
-- 7. Time Between Customer Purchases

WITH Purchase_History AS (
    SELECT
        customer_id,
        order_id,
        order_date,

        LAG(order_date) OVER (
            PARTITION BY customer_id
            ORDER BY order_date, order_id
        ) AS previous_order_date

    FROM tmp_customer_order_summary
),

Purchase_Gaps AS (
    SELECT
        customer_id,
        order_id,

        DATEDIFF(
            order_date,
            previous_order_date
        ) AS days_between_orders

    FROM Purchase_History
    WHERE previous_order_date IS NOT NULL
)

SELECT
    m.customer_id,
    m.customer_name,
    m.segment AS business_segment,
    m.total_orders,

    COUNT(pg.days_between_orders) AS number_of_purchase_gaps,

    ROUND(AVG(pg.days_between_orders), 1)
        AS avg_days_between_purchases,

    MIN(pg.days_between_orders)
        AS shortest_gap_days,

    MAX(pg.days_between_orders)
        AS longest_gap_days

FROM tmp_customer_metrics m
JOIN Purchase_Gaps pg
    ON m.customer_id = pg.customer_id

GROUP BY
    m.customer_id,
    m.customer_name,
    m.segment,
    m.total_orders

ORDER BY avg_days_between_purchases DESC;

-- 8. Repeat Purchase Rate by Acquisition Year

SELECT
    YEAR(first_order_date) AS acquisition_year,

    COUNT(*) AS customers_acquired,

    SUM(
        CASE
            WHEN total_orders >= 2 THEN 1
            ELSE 0
        END
    ) AS customers_with_repeat_purchases,

    ROUND(
        SUM(
            CASE
                WHEN total_orders >= 2 THEN 1
                ELSE 0
            END
        ) * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS repeat_customer_rate_percentage,

    ROUND(AVG(total_orders), 2)
        AS avg_orders_per_customer

FROM tmp_customer_metrics
WHERE total_orders > 0
GROUP BY YEAR(first_order_date)
ORDER BY acquisition_year;
