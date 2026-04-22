-- ============================================================
-- GadgetZone Ltd. - Database Setup Script
-- File: gadgetzone-db.sql
-- Author: Syed Ridhwan Ahmed
-- Purpose: Create database, tables, users, and sample data
--          for the GadgetZone e-commerce platform
-- Usage: sudo mysql -u root -p < gadgetzone-db.sql
-- ============================================================

-- ============================================================
-- 1. DATABASE SETUP
-- ============================================================

-- Drop and recreate for a clean setup
DROP DATABASE IF EXISTS gadgetzone;
CREATE DATABASE gadgetzone
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE gadgetzone;

-- ============================================================
-- 2. TABLE DEFINITIONS
-- ============================================================

-- Categories Table
CREATE TABLE categories (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(50)  NOT NULL,
    description TEXT
);

-- Products Table
CREATE TABLE products (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    category_id  INT,
    name         VARCHAR(100)   NOT NULL,
    price        DECIMAL(10,2)  NOT NULL,
    stock        INT            DEFAULT 0,
    description  TEXT,
    created_at   TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
);

-- Users Table (for future authentication)
CREATE TABLE users (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    username      VARCHAR(50)  UNIQUE NOT NULL,
    email         VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders Table
CREATE TABLE orders (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    user_id      INT,
    total_amount DECIMAL(10,2) NOT NULL,
    status       ENUM('pending','paid','shipped','delivered','cancelled') DEFAULT 'pending',
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Order Items Table
CREATE TABLE order_items (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    order_id    INT            NOT NULL,
    product_id  INT            NOT NULL,
    quantity    INT            NOT NULL,
    price       DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id)   REFERENCES orders(id)   ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
);

-- ============================================================
-- 3. SAMPLE DATA
-- ============================================================

-- Insert Categories
INSERT INTO categories (name, description) VALUES
('Laptops',     'High-performance laptops and ultrabooks'),
('Accessories', 'Keyboards, mice, hubs, and peripherals'),
('Audio',       'Headphones, earbuds, and speakers'),
('Monitors',    'Displays and gaming monitors'),
('Storage',     'SSDs, HDDs, and external drives'),
('Wearables',   'Smartwatches and fitness trackers'),
('Cameras',     'Webcams and action cameras');

-- Insert Products
INSERT INTO products (category_id, name, price, stock, description) VALUES
(1, 'UltraBook Pro 15"',           1299.99,  25, '15-inch laptop with 32GB RAM, 1TB SSD, Intel Core i7'),
(2, 'Wireless Mouse MX Master',      79.99, 100, 'Ergonomic wireless mouse with 3-month battery life'),
(2, 'Mechanical Keyboard RGB',       149.99,  50, 'RGB backlit mechanical keyboard with blue switches'),
(2, 'USB-C Hub 7-in-1',              49.99,  75, '7-port USB-C hub with HDMI, Ethernet, and SD card reader'),
(3, 'Noise Cancelling Headphones',  199.99,  30, 'Wireless over-ear headphones with 30h battery life'),
(6, 'Smart Watch Pro',              249.99,  45, 'Fitness tracker with heart rate monitor and GPS'),
(7, '4K Webcam',                     89.99,  60, 'Ultra HD webcam with autofocus and built-in microphone'),
(5, 'External SSD 1TB',             119.99,  40, 'Portable SSD with USB 3.2, up to 1050MB/s read speed'),
(4, 'Gaming Monitor 27" 144Hz',     329.99,  20, '27-inch QHD gaming monitor with 1ms response time'),
(2, 'Laptop Stand Ergonomic',        39.99, 120, 'Aluminum adjustable laptop stand for better posture');

-- ============================================================
-- 4. USER PERMISSIONS
-- ============================================================

-- Web application user (VM1 Web Server - 192.168.56.10)
-- IMPORTANT: Replace IP below if your VM1 has a different address
CREATE USER IF NOT EXISTS 'webuser'@'192.168.56.10'
    IDENTIFIED BY 'GadgetZone2024!';
GRANT SELECT, INSERT, UPDATE, DELETE
    ON gadgetzone.*
    TO 'webuser'@'192.168.56.10';

-- Localhost user (for local testing only)
CREATE USER IF NOT EXISTS 'webuser'@'localhost'
    IDENTIFIED BY 'GadgetZone2024!';
GRANT SELECT, INSERT, UPDATE, DELETE
    ON gadgetzone.*
    TO 'webuser'@'localhost';

-- Apply all privilege changes
FLUSH PRIVILEGES;

-- ============================================================
-- 5. VERIFICATION QUERIES
-- ============================================================

SELECT '==============================' AS '';
SELECT '  GadgetZone DB Setup Complete' AS '';
SELECT '==============================' AS '';

SELECT 'Tables Created:' AS Status;
SHOW TABLES;

SELECT 'Product Inventory:' AS Status;
SELECT
    p.id,
    c.name AS category,
    p.name AS product,
    p.price,
    p.stock
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
ORDER BY c.name, p.name;

SELECT 'Web User Permissions:' AS Status;
SELECT User, Host FROM mysql.user WHERE User = 'webuser';

SELECT 'Setup Complete - Ready for GadgetZone!' AS '';
