-- Olist e-commerce analysis
-- Devraj Sahu
-- MySQL 8. Data: Olist Brazilian E-Commerce dataset (Kaggle)

-- Q1: Is the business still growing?
-- monthly orders + revenue, and % change vs the previous month
-- I left out 2016 and Sep 2018 onwards. Only a handful of orders in those
-- months, so the growth % was coming out crazy (one month showed 29,000%)
WITH monthly AS (
    SELECT DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
           COUNT(DISTINCT o.order_id) AS orders,
           ROUND(SUM(oi.price), 2)    AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp >= '2017-01-01'
      AND o.order_purchase_timestamp <  '2018-09-01'
    GROUP BY 1
)
SELECT month, orders, revenue,
       ROUND(100 * (revenue - LAG(revenue) OVER (ORDER BY month))
             / LAG(revenue) OVER (ORDER BY month), 1) AS mom_growth_pct
FROM monthly
ORDER BY month;


-- Q2: Which categories bring in the most money?
-- category names are in Portuguese, so I join the translation table for English.
-- some products have no category at all, those show up as 'unknown'

SELECT COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
       COUNT(DISTINCT oi.order_id) AS orders,
       ROUND(SUM(oi.price), 2)     AS revenue,
       ROUND(AVG(oi.price), 2)     AS avg_price
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN category_translation t ON p.product_category_name = t.product_category_name
GROUP BY 1
ORDER BY revenue desc
LIMIT 10;



-- Q3: Do late deliveries hurt reviews?
-- late = delivered after the estimated date the customer was shown
-- bad review = 1 or 2 stars

SELECT CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
            THEN 'Late' ELSE 'On time' END AS delivery_status,
       COUNT(*)                                  AS orders,
       ROUND(AVG(r.review_score), 2)             AS avg_review,
       ROUND(100 * AVG(r.review_score <= 2), 1)  AS pct_bad_reviews
FROM orders o
JOIN reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY 1;



-- Q4: Which states get the worst delivery?
-- only states with 500+ orders, the small ones jump around too much to trust

SELECT c.customer_state AS state,
       COUNT(*) AS orders,
       ROUND(100 * AVG(o.order_delivered_customer_date > o.order_estimated_delivery_date), 1) AS late_pct,
       ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 1) AS avg_days
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY 1
HAVING COUNT(*) >= 500
ORDER BY late_pct DESC;



-- Q5: Do customers come back?
-- have to use customer_unique_id here. customer_id is different on every
-- order, so with that one nobody would ever look like a repeat customer

WITH per_customer AS (
    SELECT c.customer_unique_id,
           COUNT(DISTINCT o.order_id) AS n_orders
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY 1
)
SELECT COUNT(*)                          AS customers,
       ROUND(100 * AVG(n_orders > 1), 2) AS repeat_customer_pct
FROM per_customer;



-- Q6: How much do the top sellers matter?
-- top 20 sellers and the % of total revenue each one brings in

SELECT seller_id,
       ROUND(SUM(price), 2) AS revenue,
       ROUND(100 * SUM(price) / SUM(SUM(price)) OVER (), 2) AS pct_of_total,
       RANK() OVER (ORDER BY SUM(price) DESC) AS revenue_rank
FROM order_items
GROUP BY seller_id
ORDER BY revenue_rank
LIMIT 20;