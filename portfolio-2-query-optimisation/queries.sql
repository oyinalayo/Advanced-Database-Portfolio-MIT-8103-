-- ============================================================
-- ShopBeta: Queries and optimisation (PostgreSQL)
-- MIT 8103 Advanced Database Systems - Portfolio 2
-- Run AFTER generate_data.sql. Run one numbered block at a time
-- (select the block, then press the play button) and screenshot the result.
-- ============================================================

-- Reset: remove any indexes from earlier runs so the "before" tests are fair
DROP INDEX IF EXISTS idx_orders_customer_id;
DROP INDEX IF EXISTS idx_orders_status_date;
DROP INDEX IF EXISTS idx_order_items_product_id;

-- ============================================================
-- PART A: Business queries (with results)
-- ============================================================

-- A1. How many orders are in each status?
SELECT status, COUNT(*) AS number_of_orders
FROM orders
GROUP BY status
ORDER BY number_of_orders DESC;

-- A2. Top 5 sellers by revenue
SELECT s.business_name,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
JOIN sellers  s ON s.seller_id  = p.seller_id
GROUP BY s.business_name
ORDER BY revenue DESC
LIMIT 5;

-- A3. Revenue per category from delivered orders
SELECT c.name AS category,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id   = o.order_id
JOIN products    p  ON p.product_id  = oi.product_id
JOIN categories  c  ON c.category_id = p.category_id
WHERE o.status = 'DELIVERED'
GROUP BY c.name
ORDER BY revenue DESC;

-- ============================================================
-- PART B: Execution plans before and after indexing
-- EXPLAIN ANALYZE runs the query and shows how PostgreSQL did it
-- ============================================================

-- ---------- Query 1: find all orders for one customer ----------
-- B1 BEFORE (no index on orders.customer_id)
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM orders WHERE customer_id = 500;

-- Create the index
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
ANALYZE orders;

-- B1 AFTER
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM orders WHERE customer_id = 500;

-- ---------- Query 2: delivered orders in the last 30 days ----------
-- B2 BEFORE
EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*), SUM(total_amount)
FROM orders
WHERE status = 'DELIVERED'
  AND order_date >= NOW() - INTERVAL '30 days';

-- Create a composite index (status first, then date)
CREATE INDEX idx_orders_status_date ON orders(status, order_date);
ANALYZE orders;

-- B2 AFTER
EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*), SUM(total_amount)
FROM orders
WHERE status = 'DELIVERED'
  AND order_date >= NOW() - INTERVAL '30 days';

-- ---------- Query 3: customers who bought one product (join) ----------
-- B3 BEFORE
EXPLAIN (ANALYZE, BUFFERS)
SELECT o.order_id, o.order_date, c.first_name, c.last_name, oi.quantity
FROM order_items oi
JOIN orders    o ON o.order_id    = oi.order_id
JOIN customers c ON c.customer_id = o.customer_id
WHERE oi.product_id = 123;

-- Create the index
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
ANALYZE order_items;

-- B3 AFTER
EXPLAIN (ANALYZE, BUFFERS)
SELECT o.order_id, o.order_date, c.first_name, c.last_name, oi.quantity
FROM order_items oi
JOIN orders    o ON o.order_id    = oi.order_id
JOIN customers c ON c.customer_id = o.customer_id
WHERE oi.product_id = 123;

-- ============================================================
-- PART C: List the indexes that now exist
-- ============================================================
SELECT tablename, indexname
FROM pg_indexes
WHERE schemaname = 'public' AND indexname LIKE 'idx_%'
ORDER BY tablename;
