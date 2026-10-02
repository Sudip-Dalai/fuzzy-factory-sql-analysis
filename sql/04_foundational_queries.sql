-- 04_foundational_queries.sql
-- Tier 1: multi-table JOINs, LEFT JOIN, GROUP BY, CASE WHEN.

USE fuzzy_factory;

-- Q1. Conversion rate and revenue per session by traffic channel (KPI 1, KPI 2)
-- LEFT JOIN keeps sessions that never ordered; an INNER JOIN would show 100% conversion.
SELECT
    CASE
        WHEN ws.utm_source IS NULL AND ws.http_referer IS NULL THEN 'direct_type_in'
        WHEN ws.utm_source IS NULL                              THEN 'organic_search'
        ELSE CONCAT(ws.utm_source, '_', ws.utm_campaign)
    END AS channel,
    COUNT(DISTINCT ws.website_session_id)                              AS sessions,
    COUNT(o.order_id)                                                  AS orders,
    ROUND(100 * COUNT(o.order_id) / COUNT(DISTINCT ws.website_session_id), 2) AS conv_rate_pct,
    ROUND(SUM(o.price_usd), 2)                                         AS revenue,
    ROUND(SUM(o.price_usd) / COUNT(DISTINCT ws.website_session_id), 2) AS revenue_per_session
FROM website_sessions ws
LEFT JOIN orders o
       ON o.website_session_id = ws.website_session_id
GROUP BY channel
ORDER BY sessions DESC;

-- Q2. Product profitability and refund rate (KPI 4, KPI 5)
SELECT
    p.product_name,
    COUNT(*)                                                     AS items_sold,
    SUM(CASE WHEN oi.is_primary_item = 1 THEN 1 ELSE 0 END)      AS as_primary,
    SUM(CASE WHEN oi.is_primary_item = 0 THEN 1 ELSE 0 END)      AS as_add_on,
    ROUND(SUM(oi.price_usd), 2)                                  AS revenue,
    ROUND(100 * (SUM(oi.price_usd) - SUM(oi.cogs_usd)) / SUM(oi.price_usd), 1) AS margin_pct,
    COUNT(r.order_item_refund_id)                                AS refunds,
    ROUND(100 * COUNT(r.order_item_refund_id) / COUNT(*), 2)     AS refund_rate_pct,
    ROUND(SUM(COALESCE(r.refund_amount_usd, 0)), 2)              AS refunded_usd
FROM order_items oi
JOIN products p
      ON p.product_id = oi.product_id
LEFT JOIN order_item_refunds r
      ON r.order_item_id = oi.order_item_id
GROUP BY p.product_id, p.product_name
ORDER BY revenue DESC;
