-- 05_intermediate_queries.sql
-- Tier 2: CTEs, a subquery, date-based cohort grouping.

USE fuzzy_factory;

-- Q3. Monthly conversion trend (orders attributed to the month of their SESSION).
-- First month (2012-03) and last month (2015-03) are partial: data runs 2012-03-19 to 2015-03-19.
WITH session_orders AS (
    SELECT ws.website_session_id,
           DATE_FORMAT(ws.created_at, '%Y-%m') AS ym,
           o.order_id,
           o.price_usd
    FROM website_sessions ws
    LEFT JOIN orders o
           ON o.website_session_id = ws.website_session_id
)
SELECT ym                                              AS month,
       COUNT(*)                                        AS sessions,
       COUNT(order_id)                                 AS orders,
       ROUND(100 * COUNT(order_id) / COUNT(*), 2)      AS conv_rate_pct,
       ROUND(SUM(price_usd), 2)                        AS revenue,
       ROUND(SUM(price_usd) / COUNT(*), 2)             AS revenue_per_session
FROM session_orders
GROUP BY ym
ORDER BY ym;

-- Q4. 90-day repeat purchase rate by quarterly acquisition cohort.
-- The subquery drops customers acquired in the last 90 days of data,
-- who have not had a full 90 days to reorder.
WITH first_orders AS (
    SELECT user_id,
           MIN(created_at) AS first_order_at
    FROM orders
    GROUP BY user_id
),
repeat_flags AS (
    SELECT f.user_id,
           CONCAT(YEAR(f.first_order_at), '-Q', QUARTER(f.first_order_at)) AS cohort,
           MAX(CASE WHEN o.created_at >  f.first_order_at
                     AND o.created_at <= f.first_order_at + INTERVAL 90 DAY
                    THEN 1 ELSE 0 END) AS repeated_90d
    FROM first_orders f
    JOIN orders o
      ON o.user_id = f.user_id
    WHERE f.first_order_at <= (SELECT MAX(created_at) FROM orders) - INTERVAL 90 DAY
    GROUP BY f.user_id, cohort
)
SELECT cohort,
       COUNT(*)                                   AS new_customers,
       SUM(repeated_90d)                          AS repeat_buyers_90d,
       ROUND(100 * SUM(repeated_90d) / COUNT(*), 2) AS repeat_rate_pct
FROM repeat_flags
GROUP BY cohort
ORDER BY cohort;
