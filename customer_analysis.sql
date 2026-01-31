-- =====================================================
-- CUSTOMER ANALYSIS
-- Sales Database
-- Author: Arda Kılıç
-- =====================================================


-- -----------------------------------------------------
-- Q1: Which customers generate the highest total revenue?
--
-- BUSINESS QUESTION:
-- Who are the most valuable customers in terms of revenue?
--
-- WHY IT MATTERS:
-- Helps identify high-value customers for retention,
-- loyalty programs, and targeted marketing.
--
-- APPROACH:
-- Join customers, orders, and order_items.
-- Aggregate total revenue per customer.
-- Rank customers by total revenue in descending order.
-- -----------------------------------------------------

select
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
from customers c
join orders o
    on c.customer_id = o.customer_id
join order_items oi
    on o.order_id = oi.order_id
group by
    c.customer_id,
    c.first_name,
    c.last_name
order by total_revenue DESC
limit 5;



-- -----------------------------------------------------
-- Q2: Which customers have never placed an order?
--
-- BUSINESS QUESTION:
-- Which registered customers have not made any purchases yet?
--
-- WHY IT MATTERS:
-- Identifies inactive or unengaged customers.
-- Useful for reactivation campaigns, onboarding improvements,
-- and checking data quality issues.
--
-- APPROACH:
-- Use customers as the main table.
-- LEFT JOIN orders to include customers without orders.
-- Filter rows where order_id is NULL to find customers
-- who have never placed an order.
-- -----------------------------------------------------

select
    c.customer_id,
    c.first_name,
    c.last_name
from customers c
left join orders o
    on c.customer_id = o.customer_id
where o.order_id IS NULL;



-- -----------------------------------------------------
-- Q3: Which customers have placed only one order?
--
-- BUSINESS QUESTION:
-- Which customers made exactly one purchase?
--
-- WHY IT MATTERS:
-- Identifies one-time customers with high churn risk.
-- Useful for retention strategies and follow-up campaigns.
--
-- APPROACH:
-- Join customers and orders.
-- Group by customer.
-- Count number of orders per customer.
-- Use HAVING to filter customers with exactly one order.
-- -----------------------------------------------------


select
	c.customer_id,
    c.first_name,
    c.last_name,
    count(o.order_id) as order_count
from customers c 
join orders o 
	on c.customer_id = o.customer_id
group by 
	c.customer_id,
    c.first_name,
    c.last_name
having order_count = 1;


-- -----------------------------------------------------
-- Q4: Which customers have placed the highest number of orders?
--
-- BUSINESS QUESTION:
-- Who are the most active customers by order count?
--
-- WHY IT MATTERS:
-- Identifies loyal and repeat customers.
-- Useful for VIP programs and loyalty strategies.
--
-- APPROACH:
-- Join customers and orders.
-- Group by customer.
-- Count orders per customer.
-- Order results by order count in descending order.
-- -----------------------------------------------------


select
	c.customer_id,
    c.first_name,
    c.last_name,
    count(o.order_id) as order_count
from customers c 
join orders o 
	on c.customer_id = o.customer_id
group by 
	c.customer_id,
       c.first_name,
       c.last_name
 order by order_count desc
limit 5;


-- -----------------------------------------------------
-- Q5: What is the average order value per customer?
--
-- BUSINESS QUESTION:
-- What is the average monetary value of orders placed by each customer?
--
-- WHY IT MATTERS:
-- Helps understand customer purchasing behavior.
-- Identifies high-value vs low-value customers.
-- Useful for pricing, promotions, and segmentation strategies.
--
-- APPROACH:
-- Join customers, orders, and order_items.
-- Calculate total revenue per order.
-- Aggregate order values per customer.
-- Compute average order value for each customer.
-- -----------------------------------------------------


select
	c.customer_id,
    c.first_name,
    c.last_name,
	sum(oi.quantity * oi.unit_price) 
    / count(distinct o.order_id) as averege_order_value
from customers c
join orders o
	on c.customer_id = o.customer_id
join order_items oi
	on o.order_id = oi.order_id
group by 
	c.customer_id,
    c.first_name,
    c.last_name;
    
-- -----------------------------------------------------
-- Q6: Which customers have not placed any orders in the last 6 months?
--
-- BUSINESS QUESTION:
-- Which customers have been inactive and have not made
-- any purchases in the last 6 months?
--
-- WHY IT MATTERS:
-- Identifies churn-risk customers.
-- Useful for reactivation campaigns and retention strategies.
-- Helps detect declining customer engagement.
--
-- APPROACH:
-- Use customers as the main table.
-- LEFT JOIN orders to include all customers.
-- Filter orders placed within the last 6 months.
-- Identify customers whose last order date is older than 6 months
-- or who have never placed an order.
-- -----------------------------------------------------

select
	c.customer_id,
    c.first_name,
    c.last_name,
    max(o.order_date) as last_order_date
from customers c 
left join orders o
	on c.customer_id = o.customer_id
group by 
	c.customer_id,
    c.first_name,
    c.last_name
having
    max(o.order_date) < DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
    OR max(o.order_date) IS NULL; 
  
 -- -----------------------------------------------------
-- Q7: How much of the total revenue is generated by top customers?
--
-- BUSINESS QUESTION:
-- What percentage of total revenue is generated by the top customers?
-- (e.g. Top 5 customers)
--
-- WHY IT MATTERS:
-- Reveals revenue concentration risk.
-- Helps understand dependency on a small group of customers.
-- Useful for strategic planning and risk management.
--
-- APPROACH:
-- Calculate total revenue across all customers.
-- Calculate total revenue generated by the top customers
-- ranked by revenue.
-- Compare top customer revenue to total revenue
-- to determine revenue concentration.
-- -----------------------------------------------------


select
	top5_total.top5_total_revenue,
    total_rev.total_revenue,
    top5_total.top5_total_revenue/total_rev.total_revenue as revenue_concentration_ratio
FROM
	(
	select 
		sum(customer_revenue) as top5_total_revenue
	from
	(
		select
			c.customer_id,
			sum(oi.quantity * oi.unit_price) as customer_revenue
		from customers c
		join orders o 
			on c.customer_id = o.customer_id
		join order_items oi
			on o.order_id = oi.order_id
		group by c.customer_id
		order by customer_revenue desc
		limit 5
	)top_customers 
)top5_total,   

(
	select
		sum(oi.quantity * oi.unit_price) as total_revenue
    from orders o
    join order_items oi
        on o.order_id = oi.order_id
) total_rev;


-- -----------------------------------------------------
-- Q8: What is the customer lifetime value (CLV)?
--
-- BUSINESS QUESTION:
-- How much total revenue does each customer generate
-- over their entire lifetime?
--
-- WHY IT MATTERS:
-- Helps identify the most valuable customers.
-- Useful for long-term retention and acquisition strategies.
-- Supports customer segmentation based on lifetime value.
--
-- APPROACH:
-- Join customers, orders, and order_items tables.
-- Calculate total revenue per customer by summing
-- quantity multiplied by unit price across all orders.
-- Group results by customer.
-- -----------------------------------------------------


select
	c.customer_id,
    c.first_name,
    c.last_name,
    sum(oi.quantity * oi.unit_price) as total_revenue_per_customer
from customers c
join orders o 
	on c.customer_id = o.customer_id
join order_items oi
	on o.order_id = oi.order_id
group by 
	c.customer_id,
    c.first_name,
    c.last_name
order by total_revenue_per_customer desc;


-- -----------------------------------------------------
-- Q9: New vs Returning Customers
--
-- BUSINESS QUESTION:
-- How many customers are new, and how many are returning customers?
--
-- WHY IT MATTERS:
-- Helps understand customer acquisition vs retention.
-- Shows whether growth is driven by new customers
-- or repeat purchases.
-- Useful for marketing and retention strategy decisions.
--
-- APPROACH:
-- Classify customers based on the number of orders:
-- - New customers: only one order
-- - Returning customers: more than one order
-- Aggregate customers by customer type.
-- -----------------------------------------------------

select
	customer_type,
    count(*) as customer_count
from
(
	select
		c.customer_id,
		count(o.order_id) as order_count,
		case
			when count(o.order_id) = 1 then 'New'
			when count(o.order_id) > 1 then 'Returning'
		end as customer_type
	from customers c
	join orders o 
		on c.customer_id = o.customer_id
	group by 
		c.customer_id
)customer_classification
group by customer_type;













