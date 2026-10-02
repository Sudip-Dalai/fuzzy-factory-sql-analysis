-- 01_schema_ddl.sql
-- Creates the fuzzy_factory database and 5 typed tables with primary and foreign keys.
-- Order matters: parent tables first (products, website_sessions), children after.

CREATE DATABASE IF NOT EXISTS fuzzy_factory;
USE fuzzy_factory;

CREATE TABLE products (
    product_id   INT          NOT NULL PRIMARY KEY,
    created_at   DATETIME     NOT NULL,
    product_name VARCHAR(100) NOT NULL
);

CREATE TABLE website_sessions (
    website_session_id INT         NOT NULL PRIMARY KEY,
    created_at         DATETIME    NOT NULL,
    user_id            INT         NOT NULL,
    is_repeat_session  TINYINT     NOT NULL,
    utm_source         VARCHAR(20) NULL,
    utm_campaign       VARCHAR(30) NULL,
    utm_content        VARCHAR(30) NULL,
    device_type        VARCHAR(20) NOT NULL,
    http_referer       VARCHAR(60) NULL
);

CREATE TABLE orders (
    order_id           INT          NOT NULL PRIMARY KEY,
    created_at         DATETIME     NOT NULL,
    website_session_id INT          NOT NULL,
    user_id            INT          NOT NULL,
    primary_product_id INT          NOT NULL,
    items_purchased    TINYINT      NOT NULL,
    price_usd          DECIMAL(8,2) NOT NULL,
    cogs_usd           DECIMAL(8,2) NOT NULL,
    CONSTRAINT fk_orders_session FOREIGN KEY (website_session_id)
        REFERENCES website_sessions (website_session_id),
    CONSTRAINT fk_orders_product FOREIGN KEY (primary_product_id)
        REFERENCES products (product_id)
);

CREATE TABLE order_items (
    order_item_id   INT          NOT NULL PRIMARY KEY,
    created_at      DATETIME     NOT NULL,
    order_id        INT          NOT NULL,
    product_id      INT          NOT NULL,
    is_primary_item TINYINT      NOT NULL,
    price_usd       DECIMAL(8,2) NOT NULL,
    cogs_usd        DECIMAL(8,2) NOT NULL,
    CONSTRAINT fk_items_order   FOREIGN KEY (order_id)   REFERENCES orders (order_id),
    CONSTRAINT fk_items_product FOREIGN KEY (product_id) REFERENCES products (product_id)
);

CREATE TABLE order_item_refunds (
    order_item_refund_id INT          NOT NULL PRIMARY KEY,
    created_at           DATETIME     NOT NULL,
    order_item_id        INT          NOT NULL,
    order_id             INT          NOT NULL,
    refund_amount_usd    DECIMAL(8,2) NOT NULL,
    CONSTRAINT fk_refunds_item  FOREIGN KEY (order_item_id) REFERENCES order_items (order_item_id),
    CONSTRAINT fk_refunds_order FOREIGN KEY (order_id)      REFERENCES orders (order_id)
);
