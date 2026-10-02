-- 03_validation_checks.sql
-- Data-quality gate: run after loading. Expected results are in the comments.

USE fuzzy_factory;

-- Check 1: row counts
-- Expected: products 4 | website_sessions 472871 | orders 32313 | order_items 40025 | order_item_refunds 1731
SELECT 'products'           AS table_name, COUNT(*) AS row_count FROM products
UNION ALL SELECT 'website_sessions',       COUNT(*) FROM website_sessions
UNION ALL SELECT 'orders',                 COUNT(*) FROM orders
UNION ALL SELECT 'order_items',            COUNT(*) FROM order_items
UNION ALL SELECT 'order_item_refunds',     COUNT(*) FROM order_item_refunds;

-- Check 2: text 'NULL' converted to real NULLs
-- Expected: total_rows 472871 | utm_source_nulls 83328 | referer_nulls 39917 | leftover_text_null 0
SELECT COUNT(*)                  AS total_rows,
       SUM(utm_source IS NULL)   AS utm_source_nulls,
       SUM(http_referer IS NULL) AS referer_nulls,
       SUM(utm_source = 'NULL')  AS leftover_text_null
FROM website_sessions;

-- Check 3: revenue reconciles between orders and order_items
-- Expected: both 1938509.75
SELECT (SELECT ROUND(SUM(price_usd), 2) FROM orders)      AS orders_revenue,
       (SELECT ROUND(SUM(price_usd), 2) FROM order_items) AS items_revenue;

-- Check 4: one primary item per order
-- Expected: primary_items 32313 (equals order count)
SELECT SUM(is_primary_item) AS primary_items FROM order_items;

-- Check 5: refund total
-- Expected: total_refunds 1731 | total_refunded 85338.69
SELECT COUNT(*) AS total_refunds, ROUND(SUM(refund_amount_usd), 2) AS total_refunded
FROM order_item_refunds;
