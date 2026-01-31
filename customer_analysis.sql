-- =====================================================
-- EXPLORATORY DATA ANALYSIS
-- Sales Database
-- Author: Arda Bora Kılıç
-- =====================================================


-- -----------------------------------------------------
-- Q1: How many customers are there in total?
-- -----------------------------------------------------
SELECT 
    COUNT(customer_id) AS total_customers
FROM customers;


-- -----------------------------------------------------
-- Q2: How many orders are there in total?
-- -----------------------------------------------------
SELECT
    COUNT(order_id) AS total_orders
FROM orders;


-- -----------------------------------------------------
-- Q3: How many unique customers have placed at least one order?
-- -----------------------------------------------------
SELECT
    COUNT(DISTINCT customer_id) AS unique_customers
FROM orders;


-- -----------------------------------------------------
-- Q4: Who are the top 5 customers by number of orders?
-- -----------------------------------------------------
SELECT 
    o.customer_id,
    c.first_name,
    c.last_name,
    COUNT(o.order_id) AS order_count
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY 
    o.customer_id,
    c.first_name,
    c.last_name
ORDER BY order_count DESC
LIMIT 5;


-- -----------------------------------------------------
-- Q5: Which customers have never placed an order?
-- -----------------------------------------------------
SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customers c
LEFT JOIN orders o 
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


-- -----------------------------------------------------
-- Q6: Which customers placed orders in 2019?
-- -----------------------------------------------------
SELECT DISTINCT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_date >= '2019-01-01'
  AND o.order_date < '2020-01-01';


-- -----------------------------------------------------
-- Q7: What is the total number of items sold?
-- -----------------------------------------------------
SELECT 
    SUM(quantity) AS total_items_sold
FROM order_items;


-- -----------------------------------------------------
-- Q8: What is the total revenue?
-- -----------------------------------------------------
SELECT 
    SUM(quantity * unit_price) AS total_revenue
FROM order_items;


-- -----------------------------------------------------
-- Q9: Which products generate the highest revenue?
-- -----------------------------------------------------
SELECT
    product_id,
    SUM(quantity * unit_price) AS product_revenue
FROM order_items
GROUP BY product_id
ORDER BY product_revenue DESC
LIMIT 5;


-- -----------------------------------------------------
-- Q10: Are there any products that have never been sold?
-- -----------------------------------------------------
SELECT 
    p.product_id
FROM products p
LEFT JOIN order_items oi 
    ON p.product_id = oi.product_id
WHERE oi.order_id IS NULL;


-- -----------------------------------------------------
-- Q11: In which years were orders placed?
-- -----------------------------------------------------
SELECT
    YEAR(order_date) AS order_year,
    COUNT(order_id) AS order_count
FROM orders
GROUP BY order_year
ORDER BY order_year;


-- -----------------------------------------------------
-- Q12: How many orders are placed each month?
-- -----------------------------------------------------
SELECT 	
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    COUNT(order_id) AS order_count
FROM orders
GROUP BY 
    order_year,
    order_month
ORDER BY 
    order_year,
    order_month;


-- -----------------------------------------------------
-- Q13: What is the total revenue by month?
-- -----------------------------------------------------
SELECT 
    YEAR(o.order_date) AS order_year,
    MONTH(o.order_date) AS order_month,
    SUM(oi.quantity * oi.unit_price) AS monthly_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY 
    order_year,
    order_month
ORDER BY 
    order_year,
    order_month;


-- -----------------------------------------------------
-- Q14: Which month has the highest total revenue?
-- -----------------------------------------------------
SELECT 
    YEAR(o.order_date) AS order_year,
    MONTH(o.order_date) AS order_month,
    SUM(oi.quantity * oi.unit_price) AS monthly_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY 
    order_year,
    order_month
ORDER BY monthly_revenue DESC
LIMIT 1;
