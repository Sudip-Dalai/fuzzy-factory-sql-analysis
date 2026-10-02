-- 07_indexes_explain.sql
-- Indexing and EXPLAIN. Tables are small (<= 473k rows), so wall-clock gains are minor;
-- the point is showing the plan change.

USE fuzzy_factory;

-- A. website_sessions(created_at)
-- BEFORE: type=ALL, key=NULL, rows ~468,531 (full table scan)
EXPLAIN
SELECT COUNT(*) FROM website_sessions
WHERE created_at >= '2014-03-01' AND created_at < '2014-04-01';

CREATE INDEX idx_sessions_created_at ON website_sessions (created_at);

-- AFTER: type=range, key=idx_sessions_created_at, rows ~29,086 (estimate; true count 15,669)
EXPLAIN
SELECT COUNT(*) FROM website_sessions
WHERE created_at >= '2014-03-01' AND created_at < '2014-04-01';

-- B. orders(user_id, created_at): supports per-customer lookups and the
-- PARTITION BY user_id ORDER BY created_at pattern.
-- BEFORE: type=ALL, key=NULL, rows ~32,448
EXPLAIN
SELECT order_id, created_at, price_usd FROM orders WHERE user_id = 24159;

CREATE INDEX idx_orders_user_created ON orders (user_id, created_at);

-- AFTER: type=ref, key=idx_orders_user_created, rows=3
EXPLAIN
SELECT order_id, created_at, price_usd FROM orders WHERE user_id = 24159;

-- C. List all indexes in the schema. InnoDB creates one automatically for each foreign key.
SELECT table_name, index_name,
       GROUP_CONCAT(column_name ORDER BY seq_in_index) AS indexed_columns
FROM information_schema.statistics
WHERE table_schema = 'fuzzy_factory'
GROUP BY table_name, index_name
ORDER BY table_name, index_name;
