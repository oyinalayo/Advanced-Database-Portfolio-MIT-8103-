-- ============================================================
-- ShopBeta: Transactions and Concurrency (PostgreSQL)
-- ============================================================
-- PART 1: A successful transaction (COMMIT)
-- Placing an order = several steps that must all succeed together
-- ============================================================

-- 1a. Before: note the order count and the stock of product 1
SELECT COUNT(*) AS total_orders FROM orders;
UPDATE products SET stock_quantity = 10 WHERE product_id = 1;
SELECT product_id, name, stock_quantity FROM products WHERE product_id = 1;

-- 1b. The transaction (select from BEGIN to COMMIT and run it together)
BEGIN;

INSERT INTO orders (customer_id, address_id, status)
VALUES (1, 1, 'PENDING');

INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT currval(pg_get_serial_sequence('orders','order_id')),
       product_id, 2, price
FROM products WHERE product_id = 1;

UPDATE products SET stock_quantity = stock_quantity - 2
WHERE product_id = 1;

UPDATE orders
SET total_amount = (SELECT SUM(quantity * unit_price) FROM order_items
                    WHERE order_id = currval(pg_get_serial_sequence('orders','order_id')))
WHERE order_id = currval(pg_get_serial_sequence('orders','order_id'));

INSERT INTO payments (order_id, method, amount, status, reference, paid_at)
SELECT order_id, 'CARD', total_amount, 'SUCCESS', 'TXN-DEMO-001', NOW()
FROM orders
WHERE order_id = currval(pg_get_serial_sequence('orders','order_id'));

UPDATE orders SET status = 'PAID'
WHERE order_id = currval(pg_get_serial_sequence('orders','order_id'));

COMMIT;

-- 1c. After: the order count went up by 1 and stock went down by 2
SELECT COUNT(*) AS total_orders FROM orders;
SELECT product_id, name, stock_quantity FROM products WHERE product_id = 1;

-- ============================================================
-- PART 2: A failed transaction (ROLLBACK)
-- The customer tries to buy 50 units but only 8 are in stock.
-- The stock CHECK rule rejects it, so everything must be undone.
-- ============================================================

-- 2a. Before
SELECT COUNT(*) AS total_orders FROM orders;

-- 2b. Run these lines. The UPDATE will fail with an error.
BEGIN;

INSERT INTO orders (customer_id, address_id, status)
VALUES (2, 2, 'PENDING');

UPDATE products SET stock_quantity = stock_quantity - 50
WHERE product_id = 1;

-- 2c. The transaction is now broken. Undo everything:
ROLLBACK;

-- 2d. After: the order count is the same as before, so the new order was undone
SELECT COUNT(*) AS total_orders FROM orders;
SELECT product_id, name, stock_quantity FROM products WHERE product_id = 1;

-- ============================================================
-- PART 3: Concurrency problem - the lost update
-- Open TWO Query Tool tabs on shopbeta: Tab 1 and Tab 2.
-- Two customers each buy 1 unit of product 3 at the same time.
-- Stock starts at 10, so it should end at 8.
-- ============================================================

-- 3a. Setup (Tab 1)
UPDATE products SET stock_quantity = 10 WHERE product_id = 3;

-- 3b. WITHOUT protection. Follow this exact order:
--   [Tab 1] BEGIN;
--   [Tab 1] SELECT stock_quantity FROM products WHERE product_id = 3;   -- shows 10
--   [Tab 2] BEGIN;
--   [Tab 2] SELECT stock_quantity FROM products WHERE product_id = 3;   -- also shows 10
--   [Tab 1] UPDATE products SET stock_quantity = 9 WHERE product_id = 3;
--   [Tab 1] COMMIT;
--   [Tab 2] UPDATE products SET stock_quantity = 9 WHERE product_id = 3;
--   [Tab 2] COMMIT;
--   Then check (either tab):
SELECT stock_quantity FROM products WHERE product_id = 3;
--   Result: 9, but two units were sold. It should be 8. One sale was "lost".

-- ============================================================
-- PART 3 (fix): Control it with row locking (SELECT ... FOR UPDATE)
-- ============================================================

-- 3c. Setup again (Tab 1)
UPDATE products SET stock_quantity = 10 WHERE product_id = 3;

-- 3d. WITH protection. Follow this exact order:
--   [Tab 1] BEGIN;
--   [Tab 1] SELECT stock_quantity FROM products WHERE product_id = 3 FOR UPDATE;   -- shows 10
--   [Tab 2] BEGIN;
--   [Tab 2] SELECT stock_quantity FROM products WHERE product_id = 3 FOR UPDATE;   -- WAITS (keeps spinning)
--   [Tab 1] UPDATE products SET stock_quantity = 9 WHERE product_id = 3;
--   [Tab 1] COMMIT;
--   [Tab 2] now finishes and shows 9 (not 10)
--   [Tab 2] UPDATE products SET stock_quantity = 8 WHERE product_id = 3;
--   [Tab 2] COMMIT;
--   Then check:
SELECT stock_quantity FROM products WHERE product_id = 3;
--   Result: 8, which is correct.

-- ============================================================
-- PART 4: Isolation levels
-- Again use TWO tabs. Product 3 stock starts at 10.
-- ============================================================

-- 4a. Setup (Tab 1)
UPDATE products SET stock_quantity = 10 WHERE product_id = 3;

-- 4b. READ COMMITTED (PostgreSQL's default)
--   [Tab 1] BEGIN ISOLATION LEVEL READ COMMITTED;
--   [Tab 1] SELECT stock_quantity FROM products WHERE product_id = 3;   -- 10
--   [Tab 2] UPDATE products SET stock_quantity = 7 WHERE product_id = 3;
--   [Tab 1] SELECT stock_quantity FROM products WHERE product_id = 3;   -- 7 (changed inside the same transaction)
--   [Tab 1] COMMIT;

-- 4c. REPEATABLE READ
--   [Tab 1] UPDATE products SET stock_quantity = 10 WHERE product_id = 3;
--   [Tab 1] BEGIN ISOLATION LEVEL REPEATABLE READ;
--   [Tab 1] SELECT stock_quantity FROM products WHERE product_id = 3;   -- 10
--   [Tab 2] UPDATE products SET stock_quantity = 7 WHERE product_id = 3;
--   [Tab 1] SELECT stock_quantity FROM products WHERE product_id = 3;   -- still 10
--   [Tab 1] COMMIT;
--   [Tab 1] SELECT stock_quantity FROM products WHERE product_id = 3;   -- now 7
