-- KPI Analysis

-- Total number of orders placed
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;
    
-- Total revenue generated from pizza sales
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
    
-- Average order placed
SELECT
    ROUND(SUM(pizzas.price * order_details.quantity) / COUNT(DISTINCT order_details.order_id),
            2) AS average_order
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id;
    
-- Prodcut Performance

-- The top 3 most ordered pizza types based on revenue
SELECT 
    pizza_types.name,
    (pizzas.price * order_details.quantity) AS revenue
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
    join pizza_types
    on pizza_types.pizza_type_id=pizzas.pizza_type_id
ORDER BY revenue DESC
LIMIT 3;

-- The top 5 pizzas by quantity sold
SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS total_quantity
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.name
ORDER BY total_quantity DESC
LIMIT 3;

-- Category and size analysis

-- Which pizza category generates the highest revenue?
SELECT 
    pizza_types.category,
    round(sum(pizzas.price * order_details.quantity),2) AS revenue
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
    join pizza_types
    on pizza_types.pizza_type_id=pizzas.pizza_type_id
    group by pizza_types.category
ORDER BY revenue DESC
;

-- Which pizza size generates the highest revenue?
SELECT 
    pizzas.size,
    round(sum(pizzas.price * order_details.quantity),2) AS revenue
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
   
    group by pizzas.size
ORDER BY revenue DESC
;

-- Time Analysis

-- What are the peak order hours?
SELECT 
    HOUR(orders.order_time) AS order_hour,
    SUM(order_details.quantity) AS pizzas_sold
FROM orders
JOIN order_details
ON orders.order_id = order_details.order_id
GROUP BY order_hour
ORDER BY pizzas_sold DESC
limit 5;

-- Which days of the week have the highest sales?
SELECT 
    DAYNAME(order_date) AS day_of_week,
    ROUND(SUM(od.quantity * p.price), 2) AS total_sales
FROM
    orders AS o
        JOIN
    order_details AS od ON o.order_id = od.order_id
        JOIN
    pizzas AS p ON od.pizza_id = p.pizza_id
GROUP BY day_of_week
ORDER BY total_sales DESC
LIMIT 3;

-- More Insights

-- Rank pizzas based on revenue using a window function.
WITH pizza_revenue AS (
    SELECT
        pt.name AS pizza_name,
        SUM(od.quantity * p.price) AS revenue
    FROM order_details od
    JOIN pizzas p
        ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt
        ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.name
)
SELECT
    pizza_name,
    revenue,
    RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM pizza_revenue;

-- Find the top 3 pizzas in each category using ROW_NUMBER()
WITH pizza_sales AS (
    SELECT
        pt.category,
        pt.name AS pizza_name,
        SUM(od.quantity) AS total_quantity,
        ROW_NUMBER() OVER (
            PARTITION BY pt.category
            ORDER BY SUM(od.quantity) DESC
        ) AS rn
    FROM pizza_types pt
    JOIN pizzas p
        ON pt.pizza_type_id = p.pizza_type_id
    JOIN order_details od
        ON p.pizza_id = od.pizza_id
    GROUP BY pt.category, pt.name
)

SELECT
    category,
    pizza_name,
    total_quantity
FROM pizza_sales
WHERE rn <= 3
ORDER BY category, total_quantity DESC;

