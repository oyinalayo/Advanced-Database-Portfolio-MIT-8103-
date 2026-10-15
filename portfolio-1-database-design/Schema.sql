-- ============================================================
-- ShopBeta: Relational Schema (PostgreSQL)
-- MIT 8103 Advanced Database Systems - Portfolio 1
-- Run in pgAdmin Query Tool against the database named shopbeta
-- ============================================================

DROP TABLE IF EXISTS deliveries   CASCADE;
DROP TABLE IF EXISTS payments     CASCADE;
DROP TABLE IF EXISTS order_items  CASCADE;
DROP TABLE IF EXISTS orders       CASCADE;
DROP TABLE IF EXISTS products     CASCADE;
DROP TABLE IF EXISTS addresses    CASCADE;
DROP TABLE IF EXISTS customers    CASCADE;
DROP TABLE IF EXISTS sellers      CASCADE;
DROP TABLE IF EXISTS categories   CASCADE;

-- Product categories (self-reference allows sub-categories, e.g. Electronics > Phones)
CREATE TABLE categories (
    category_id        SERIAL PRIMARY KEY,
    name               VARCHAR(80) NOT NULL UNIQUE,
    parent_category_id INT REFERENCES categories(category_id) ON DELETE SET NULL
);

-- Businesses that list products on the marketplace
CREATE TABLE sellers (
    seller_id     SERIAL PRIMARY KEY,
    business_name VARCHAR(120) NOT NULL,
    email         VARCHAR(120) NOT NULL UNIQUE,
    phone         VARCHAR(20),
    city          VARCHAR(60)  NOT NULL,
    registered_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE customers (
    customer_id   SERIAL PRIMARY KEY,
    first_name    VARCHAR(60)  NOT NULL,
    last_name     VARCHAR(60)  NOT NULL,
    email         VARCHAR(120) NOT NULL UNIQUE,
    phone         VARCHAR(20),
    registered_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- A customer can save several delivery addresses
CREATE TABLE addresses (
    address_id  SERIAL PRIMARY KEY,
    customer_id INT         NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    street      VARCHAR(150) NOT NULL,
    city        VARCHAR(60)  NOT NULL,
    state       VARCHAR(60)  NOT NULL,
    is_default  BOOLEAN      NOT NULL DEFAULT FALSE
);

CREATE TABLE products (
    product_id     SERIAL PRIMARY KEY,
    seller_id      INT           NOT NULL REFERENCES sellers(seller_id),
    category_id    INT           NOT NULL REFERENCES categories(category_id),
    name           VARCHAR(150)  NOT NULL,
    description    TEXT,
    price          NUMERIC(12,2) NOT NULL CHECK (price >= 0),
    stock_quantity INT           NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    is_active      BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    order_id     SERIAL PRIMARY KEY,
    customer_id  INT           NOT NULL REFERENCES customers(customer_id),
    address_id   INT           NOT NULL REFERENCES addresses(address_id),
    order_date   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status       VARCHAR(20)   NOT NULL DEFAULT 'PENDING'
                 CHECK (status IN ('PENDING','PAID','SHIPPED','DELIVERED','CANCELLED')),
    total_amount NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (total_amount >= 0)
);

-- Junction table: resolves the many-to-many between orders and products
CREATE TABLE order_items (
    order_id   INT           NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INT           NOT NULL REFERENCES products(product_id),
    quantity   INT           NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),  -- price at time of purchase
    PRIMARY KEY (order_id, product_id)
);

CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    order_id   INT           NOT NULL REFERENCES orders(order_id),
    method     VARCHAR(20)   NOT NULL CHECK (method IN ('CARD','TRANSFER','USSD','PAY_ON_DELIVERY')),
    amount     NUMERIC(12,2) NOT NULL CHECK (amount > 0),
    status     VARCHAR(20)   NOT NULL DEFAULT 'INITIATED'
               CHECK (status IN ('INITIATED','SUCCESS','FAILED','REFUNDED')),
    reference  VARCHAR(60)   NOT NULL UNIQUE,
    paid_at    TIMESTAMP
);

CREATE TABLE deliveries (
    delivery_id  SERIAL PRIMARY KEY,
    order_id     INT         NOT NULL UNIQUE REFERENCES orders(order_id),  -- one delivery per order
    courier_name VARCHAR(80),
    status       VARCHAR(20) NOT NULL DEFAULT 'PROCESSING'
                 CHECK (status IN ('PROCESSING','IN_TRANSIT','DELIVERED','FAILED')),
    shipped_at   TIMESTAMP,
    delivered_at TIMESTAMP,
    CHECK (delivered_at IS NULL OR shipped_at IS NULL OR delivered_at >= shipped_at)
);
