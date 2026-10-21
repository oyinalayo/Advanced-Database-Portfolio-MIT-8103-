-- ============================================================
-- ShopBeta: Synthetic data generation (PostgreSQL)
-- MIT 8103 Advanced Database Systems - Portfolio 2
-- WARNING: clears all existing rows (including the Portfolio 1 test rows)
-- All data below is made up for this project.
-- ============================================================

TRUNCATE deliveries, payments, order_items, orders, products,
         addresses, customers, sellers, categories RESTART IDENTITY CASCADE;

-- 1. Categories (8)
INSERT INTO categories (name) VALUES
 ('Electronics'),('Fashion'),('Home & Kitchen'),('Beauty'),
 ('Groceries'),('Sports'),('Books'),('Toys');

-- 2. Sellers (50): seller 1 is DevlonHub, the rest are generated
INSERT INTO sellers (business_name, email, phone, city)
VALUES ('DevlonHub', 'contact@devlonhub-example.com', '08000000000', 'Lagos');

INSERT INTO sellers (business_name, email, phone, city)
SELECT 'Seller ' || g,
       'seller' || g || '@example.com',
       '0800' || lpad(g::text, 7, '0'),
       (ARRAY['Lagos','Abuja','Port Harcourt','Ibadan','Kano'])[1 + (g % 5)]
FROM generate_series(2, 50) g;

-- 3. Customers (20,000)
INSERT INTO customers (first_name, last_name, email, phone, registered_at)
SELECT (ARRAY['Ade','Chi','Tolu','Ngozi','Emeka','Fatima','Bola','Kemi','Musa','Ife'])[1 + (g % 10)],
       (ARRAY['Okafor','Bello','Adeyemi','Eze','Ibrahim','Balogun','Nwosu','Lawal'])[1 + (g % 8)],
       'customer' || g || '@example.com',
       '0900' || lpad(g::text, 7, '0'),
       NOW() - random() * INTERVAL '730 days'
FROM generate_series(1, 20000) g;

-- 4. One address per customer (address_id will equal customer_id)
INSERT INTO addresses (customer_id, street, city, state, is_default)
SELECT customer_id,
       (1 + customer_id % 200) || ' Sample Street',
       (ARRAY['Ikeja','Lekki','Yaba','Surulere','Victoria Island'])[1 + (customer_id % 5)],
       'Lagos',
       TRUE
FROM customers;

-- 5. Products (5,000)
INSERT INTO products (seller_id, category_id, name, description, price, stock_quantity)
SELECT 1 + (g % 50),
       1 + (g % 8),
       'Product ' || g,
       'Sample description for product ' || g,
       round((500 + random() * 199500)::numeric, 2),
       floor(random() * 500)::int
FROM generate_series(1, 5000) g;

-- 6. Orders (200,000) spread over the last two years
INSERT INTO orders (customer_id, address_id, order_date, status)
SELECT c, c,
       NOW() - random() * INTERVAL '730 days',
       (ARRAY['PENDING','PAID','SHIPPED','DELIVERED','CANCELLED'])[1 + floor(random() * 5)::int]
FROM (SELECT 1 + floor(random() * 20000)::int AS c
      FROM generate_series(1, 200000)) t;

-- 7. Order items: 1 to 3 different products per order
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT o.order_id, p.product_id, 1 + (o.order_id % 3), p.price
FROM orders o
CROSS JOIN generate_series(1, 3) n
JOIN products p ON p.product_id = 1 + ((o.order_id * 7 + n * 13) % 5000)
WHERE n <= 1 + (o.order_id % 3);

-- 8. Fill in each order's total from its items
UPDATE orders o
SET total_amount = s.total
FROM (SELECT order_id, SUM(quantity * unit_price) AS total
      FROM order_items GROUP BY order_id) s
WHERE s.order_id = o.order_id;

-- 9. Payments for orders that have been paid, shipped or delivered
INSERT INTO payments (order_id, method, amount, status, reference, paid_at)
SELECT order_id,
       (ARRAY['CARD','TRANSFER','USSD','PAY_ON_DELIVERY'])[1 + floor(random() * 4)::int],
       total_amount,
       'SUCCESS',
       'REF' || lpad(order_id::text, 9, '0'),
       order_date + INTERVAL '5 minutes'
FROM orders
WHERE status IN ('PAID','SHIPPED','DELIVERED');

-- 10. Deliveries for shipped and delivered orders
INSERT INTO deliveries (order_id, courier_name, status, shipped_at, delivered_at)
SELECT order_id,
       (ARRAY['SwiftDispatch','LagosExpress','QuickMove'])[1 + floor(random() * 3)::int],
       CASE WHEN status = 'DELIVERED' THEN 'DELIVERED' ELSE 'IN_TRANSIT' END,
       order_date + INTERVAL '1 day',
       CASE WHEN status = 'DELIVERED' THEN order_date + INTERVAL '3 days' END
FROM orders
WHERE status IN ('SHIPPED','DELIVERED');

-- 11. Refresh PostgreSQL's statistics so execution plans are accurate
ANALYZE;

-- 12. Check: row counts per table
SELECT 'categories' AS table_name, COUNT(*) AS rows FROM categories
UNION ALL SELECT 'sellers',     COUNT(*) FROM sellers
UNION ALL SELECT 'customers',   COUNT(*) FROM customers
UNION ALL SELECT 'addresses',   COUNT(*) FROM addresses
UNION ALL SELECT 'products',    COUNT(*) FROM products
UNION ALL SELECT 'orders',      COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'payments',    COUNT(*) FROM payments
UNION ALL SELECT 'deliveries',  COUNT(*) FROM deliveries;
