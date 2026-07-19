-- ============================================================
-- SLA BREACH & COST IMPACT ANALYSIS
-- Dataset: Olist Brazilian E-Commerce Public Dataset
-- ============================================================


-- ============================================================
-- SCHEMA SETUP
-- ============================================================

CREATE TABLE orders (
    order_id VARCHAR PRIMARY KEY,
    customer_id VARCHAR,
    order_status VARCHAR,
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE order_items (
    order_id VARCHAR,
    order_item_id INT,
    product_id VARCHAR,
    seller_id VARCHAR,
    shipping_limit_date TIMESTAMP,
    price NUMERIC,
    freight_value NUMERIC
);

CREATE TABLE products (
    product_id VARCHAR PRIMARY KEY,
    product_category_name VARCHAR,
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

CREATE TABLE sellers (
    seller_id VARCHAR PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR,
    seller_state VARCHAR
);

CREATE TABLE customers (
    customer_id VARCHAR PRIMARY KEY,
    customer_unique_id VARCHAR,
    customer_zip_code_prefix INT,
    customer_city VARCHAR,
    customer_state VARCHAR
);

CREATE TABLE category_translation (
    product_category_name VARCHAR,
    product_category_name_english VARCHAR
);


-- ============================================================
-- INITIAL DATA EXPLORATION
-- ============================================================

SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_items;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM sellers;
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM category_translation;

SELECT * FROM orders LIMIT 5;
SELECT * FROM order_items LIMIT 5;


-- ============================================================
-- DATA CLEANING
-- ============================================================

-- Keep only orders that were actually delivered — an order that
-- never arrived has no meaningful "delay" to measure.
DELETE FROM orders
WHERE order_delivered_customer_date IS NULL;

-- Delay in days: positive = late, negative = early, zero = on time.
ALTER TABLE orders
ADD COLUMN delivery_delay_days INT;
UPDATE orders
SET delivery_delay_days =
DATE(order_delivered_customer_date) - DATE(order_estimated_delivery_date);

-- Simple binary breach flag, used for breach rate / breach count metrics.
ALTER TABLE orders
ADD COLUMN sla_breached_flag INT;
UPDATE orders
SET sla_breached_flag =
CASE
    WHEN delivery_delay_days > 0 THEN 1
    ELSE 0
END;


-- ============================================================
-- CORE VIEWS
-- ============================================================

-- One row per order: total order value (all items + freight combined).
CREATE VIEW order_value AS
SELECT
    order_id,
    SUM(price + freight_value) AS total_order_value
FROM order_items
GROUP BY order_id;

-- One row per order: estimated financial cost of the delay.
-- Cost model: 2% of order value per day late (assumed penalty rate,
-- used as a stand-in for real refund/support-cost data).
CREATE VIEW sla_cost_impact AS
SELECT
    o.order_id,
    o.delivery_delay_days,
    o.sla_breached_flag,
    ov.total_order_value,
    CASE
        WHEN o.delivery_delay_days > 0
        THEN ov.total_order_value * 0.02 * o.delivery_delay_days  -- 2% penalty per day late
        ELSE 0
    END AS estimated_delay_cost
FROM orders o
JOIN order_value ov ON o.order_id = ov.order_id;

-- One "primary" item per order (highest-priced), used to attach
-- seller/product/category detail without duplicating order-level
-- values across every line item in a multi-item order.
CREATE VIEW primary_order_item AS
SELECT DISTINCT ON (order_id)
    order_id,
    product_id,
    seller_id
FROM order_items
ORDER BY order_id, price DESC;

-- Final analysis-ready table: one row per order, consolidating
-- delay, breach flag, cost, seller state, customer state, and
-- product category. This is the table imported into Power BI.
CREATE VIEW sla_final AS
SELECT
    o.order_id,
    o.order_purchase_timestamp,
    o.delivery_delay_days,
    o.sla_breached_flag,
    sci.estimated_delay_cost,
    s.seller_state,
    c.customer_state,
    ct.product_category_name_english
FROM orders o
JOIN sla_cost_impact sci ON o.order_id = sci.order_id
JOIN primary_order_item poi ON o.order_id = poi.order_id
JOIN sellers s ON poi.seller_id = s.seller_id
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON poi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name;


-- ============================================================
-- ANALYSIS QUERIES
-- ============================================================

-- Total orders in the final analysis table
SELECT COUNT(DISTINCT order_id)
FROM sla_final;

-- Total breached orders
SELECT
    COUNT(DISTINCT order_id) AS breached_orders
FROM orders
WHERE delivery_delay_days > 0;

-- SLA breach rate (::NUMERIC cast avoids integer-division truncation)
SELECT
    ROUND(
        COUNT(DISTINCT CASE
            WHEN delivery_delay_days > 0 THEN order_id
        END)::NUMERIC
        /
        COUNT(DISTINCT order_id),
        4
    ) AS sla_breach_rate
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

-- Average delay across all delivered orders (punctuality overall)
SELECT
    ROUND(AVG(delivery_delay_days), 2) AS avg_delay_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

-- Average delay among breached orders only (severity when we fail)
SELECT
    ROUND(AVG(delivery_delay_days), 2) AS avg_delay_breached
FROM orders
WHERE delivery_delay_days > 0;

-- Total delay cost among breached orders
SELECT
    ROUND(SUM(estimated_delay_cost), 2) AS total_delay_cost_breached
FROM sla_final
WHERE sla_breached_flag = 1;

-- Average cost per breached order
SELECT
    ROUND(
        SUM(estimated_delay_cost)
        /
        COUNT(DISTINCT order_id),
        2
    ) AS cost_per_breached_order
FROM sla_final
WHERE sla_breached_flag = 1;

-- Total delay cost across all orders
SELECT
    ROUND(SUM(estimated_delay_cost), 2) AS total_delay_cost
FROM sla_final;


-- ============================================================
-- VALIDATION CHECKS
-- Expected: 96476 orders, ~257769.71 total delay cost
-- ============================================================

SELECT COUNT(*) FROM sla_final;
SELECT ROUND(SUM(estimated_delay_cost), 2) AS total_delay_cost FROM sla_final;