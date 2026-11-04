-- ShopBeta: partitioning demo (PostgreSQL)
-- MIT 8103 Advanced Database Systems - Portfolio 5
-- Splits a copy of the orders table into 3 partitions by a hash of customer_id,
-- as a single-server stand-in for sharding.

-- 1. Build the split table and copy the orders into it
CREATE TABLE orders_sharded (
    order_id     INT NOT NULL,
    customer_id  INT NOT NULL,
    order_date   TIMESTAMP NOT NULL,
    status       VARCHAR(20) NOT NULL,
    total_amount NUMERIC(12,2) NOT NULL,
    PRIMARY KEY (order_id, customer_id)
) PARTITION BY HASH (customer_id);

CREATE TABLE orders_shard_0 PARTITION OF orders_sharded FOR VALUES WITH (MODULUS 3, REMAINDER 0);
CREATE TABLE orders_shard_1 PARTITION OF orders_sharded FOR VALUES WITH (MODULUS 3, REMAINDER 1);
CREATE TABLE orders_shard_2 PARTITION OF orders_sharded FOR VALUES WITH (MODULUS 3, REMAINDER 2);

INSERT INTO orders_sharded
SELECT order_id, customer_id, order_date, status, total_amount FROM orders;

ANALYZE orders_sharded;

-- 2. Rows per shard
SELECT tableoid::regclass AS shard, COUNT(*) AS rows
FROM orders_sharded GROUP BY tableoid ORDER BY shard;

-- 3. A query using the shard key: only one shard is touched
EXPLAIN SELECT * FROM orders_sharded WHERE customer_id = 500;
