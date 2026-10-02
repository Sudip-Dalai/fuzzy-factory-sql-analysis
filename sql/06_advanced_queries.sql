-- 06_advanced_queries.sql
-- Tier 3: window functions (LAG, running total, moving average, DENSE_RANK, ROW_NUMBER) and a self-join.

USE fuzzy_factory;

-- Q5. Monthly revenue with MoM growth, running total, 3-month moving average.
-- Partial months (2012-03, 2015-03) excluded. Orders attributed by ORDER date here.
WITH monthly AS (
    SELECT DATE_FORMAT(created_at, '%Y-%m') AS month,
           SUM(price_usd)                   AS revenue
    FROM orders
    WHERE created_at >= '2012-04-01'
      AND created_at <  '2015-03-01'
    GROUP BY month
)
SELECT month,
       ROUND(revenue, 2) AS revenue,
       ROUND(100 * (revenue - LAG(revenue) OVER (ORDER BY month))
                 / LAG(revenue) OVER (ORDER BY month), 1)                 AS mom_growth_pct,
       ROUND(SUM(revenue) OVER (ORDER BY month), 2)                       AS running_revenue,
       ROUND(AVG(revenue) OVER (ORDER BY month
                                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_3m
FROM monthly
ORDER BY month;

-- Q6. Channel revenue share and rank within each year (2015 is a partial year).
WITH channel_year AS (
    SELECT YEAR(o.created_at) AS yr,
           CASE
               WHEN ws.utm_source IS NULL AND ws.http_referer IS NULL THEN 'direct_type_in'
               WHEN ws.utm_source IS NULL                              THEN 'organic_search'
               ELSE CONCAT(ws.utm_source, '_', ws.utm_campaign)
           END AS channel,
           COUNT(*)           AS orders,
           SUM(o.price_usd)   AS revenue
    FROM orders o
    JOIN website_sessions ws
      ON ws.website_session_id = o.website_session_id
    GROUP BY yr, channel
)
SELECT yr,
       channel,
       orders,
       ROUND(revenue, 2)                                              AS revenue,
       ROUND(100 * revenue / SUM(revenue) OVER (PARTITION BY yr), 1)  AS pct_of_year,
       DENSE_RANK() OVER (PARTITION BY yr ORDER BY revenue DESC)      AS rank_in_year
FROM channel_year
ORDER BY yr, rank_in_year;

-- Q7. Time from first to second order: ROW_NUMBER + self-join.
WITH numbered AS (
    SELECT user_id,
           order_id,
           created_at,
           ROW_NUMBER() OVER (PARTITION BY user_id
                              ORDER BY created_at, order_id) AS order_seq
    FROM orders
)
SELECT COUNT(*)                                                     AS repeat_customers,
       ROUND(AVG(DATEDIFF(o2.created_at, o1.created_at)), 1)        AS avg_days_to_2nd_order,
       MIN(DATEDIFF(o2.created_at, o1.created_at))                  AS min_days,
       MAX(DATEDIFF(o2.created_at, o1.created_at))                  AS max_days,
       SUM(CASE WHEN DATEDIFF(o2.created_at, o1.created_at) <= 30 THEN 1 ELSE 0 END)                 AS within_30d,
       SUM(CASE WHEN DATEDIFF(o2.created_at, o1.created_at) BETWEEN 31 AND 90 THEN 1 ELSE 0 END)     AS days_31_90,
       SUM(CASE WHEN DATEDIFF(o2.created_at, o1.created_at) > 90 THEN 1 ELSE 0 END)                  AS over_90d
FROM numbered o1
JOIN numbered o2
  ON  o2.user_id   = o1.user_id
  AND o1.order_seq = 1
  AND o2.order_seq = 2;
