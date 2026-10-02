-- 02_load_data.sql
-- Loads the CSVs. EDIT THE FOLDER PATH below to where you saved the files
-- (forward slashes, no quotes from "Copy as path").
-- Requires local_infile enabled on the server (SET GLOBAL local_infile = 1;)
-- and OPT_LOCAL_INFILE=1 in the MySQL Workbench connection (Advanced > Others).
-- The CSVs use Windows line endings, hence '\r\n'.
-- Load order follows the foreign keys.

USE fuzzy_factory;

LOAD DATA LOCAL INFILE 'C:/path/to/products.csv'
INTO TABLE products
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- Cleaning step: the file stores missing values as the literal text 'NULL'.
-- NULLIF converts them to real NULLs at load time.
LOAD DATA LOCAL INFILE 'C:/path/to/website_sessions.csv'
INTO TABLE website_sessions
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(website_session_id, created_at, user_id, is_repeat_session,
 @utm_source, @utm_campaign, @utm_content, device_type, @http_referer)
SET utm_source   = NULLIF(@utm_source,   'NULL'),
    utm_campaign = NULLIF(@utm_campaign, 'NULL'),
    utm_content  = NULLIF(@utm_content,  'NULL'),
    http_referer = NULLIF(@http_referer, 'NULL');

LOAD DATA LOCAL INFILE 'C:/path/to/orders.csv'
INTO TABLE orders
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/path/to/order_items.csv'
INTO TABLE order_items
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/path/to/order_item_refunds.csv'
INTO TABLE order_item_refunds
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;
