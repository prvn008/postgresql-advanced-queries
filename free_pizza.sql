CREATE TABLE pizza_orders (
    order_id INT PRIMARY KEY,
    order_time TIMESTAMP,
    expected_delivery TIMESTAMP,
    actual_delivery TIMESTAMP,
    no_of_pizzas INT,
    price DECIMAL(10, 2)
);
select *from pizza_orders


SELECT
    TO_CHAR(order_time, 'Mon-YY') AS period,
    ROUND(100.0 * SUM(CASE WHEN actual_delivery > order_time + interval '30 minutes'
                           THEN 1 ELSE 0 END) / COUNT(*), 2) AS delayed_delivery_perc,
    SUM(CASE WHEN actual_delivery > order_time + interval '30 minutes'
             THEN no_of_pizzas ELSE 0 END) AS free_pizzas
FROM pizza_orders
GROUP BY TO_CHAR(order_time, 'Mon-YY')
  --       DATE_TRUNC('month', order_time)
ORDER BY delayed_delivery_perc ASC;


---------------------------------------------------------------------------
----------------------------------------------------------------------------

WITH monthly_stats AS (
    SELECT
        TO_CHAR(order_time, 'Mon-YY') AS period,
        ROUND(100.0 * SUM(CASE WHEN actual_delivery > order_time + interval '30 minutes'
                               THEN 1 ELSE 0 END) / COUNT(*), 2) AS delayed_delivery_perc,
        SUM(CASE WHEN actual_delivery > order_time + interval '30 minutes'
                 THEN no_of_pizzas ELSE 0 END) AS free_pizzas
    FROM pizza_orders
    GROUP BY TO_CHAR(order_time, 'Mon-YY')
)
SELECT
    period,
    delayed_delivery_perc,
    free_pizzas,
    CASE 
        WHEN free_pizzas > AVG(free_pizzas) OVER () THEN 'Above Average'
        ELSE 'Below Average'
    END AS free_pizza_status
FROM monthly_stats
ORDER BY delayed_delivery_perc ASC;


--max delivery mintues
select
AVG(EXTRACT(EPOCH FROM (actual_delivery - order_time)) / 60) AS avg_delivery_minutes
from 
pizza_orders;



--
SELECT 
    COUNT(*) AS total_orders,
    ROUND(AVG(EXTRACT(EPOCH FROM (actual_delivery - order_time)) / 60), 2) AS avg_delivery_minutes,
    ROUND(MAX(EXTRACT(EPOCH FROM (actual_delivery - order_time)) / 60), 2) AS max_delivery_minutes,
    ROUND(MIN(EXTRACT(EPOCH FROM (actual_delivery - order_time)) / 60), 2) AS min_delivery_minutes
FROM pizza_orders;



--2. On-time vs Late Deliveries (30-min threshold)
SELECT 
    SUM(CASE WHEN actual_delivery <= expected_delivery THEN 1 ELSE 0 END) AS on_time,
    SUM(CASE WHEN actual_delivery > expected_delivery THEN 1 ELSE 0 END) AS late,
    ROUND(100.0 * SUM(CASE WHEN actual_delivery > expected_delivery THEN 1 ELSE 0 END) / COUNT(*), 2) AS late_percentage
FROM pizza_orders;

--3. Monthly Average Delivery Time
SELECT 
    TO_CHAR(order_time, 'Mon-YYYY') AS month,
    ROUND(AVG(EXTRACT(EPOCH FROM (actual_delivery - order_time)) / 60), 2) AS avg_delivery_minutes
FROM pizza_orders
GROUP BY TO_CHAR(order_time, 'Mon-YYYY')
ORDER BY MIN(order_time);


--5. Revenue Insights
SELECT 
        COUNT(*) AS no_of_pizzas,
    SUM(price) AS total_revenue,
    ROUND(AVG(price), 2) AS avg_order_value,
    SUM(no_of_pizzas) AS total_pizzas,
    ROUND(AVG(no_of_pizzas), 2) AS avg_pizzas_per_order
FROM pizza_orders;


--6. Top 5 Largest Orders (by no_of_pizzas)
SELECT 
    order_id, order_time, no_of_pizzas, price
FROM pizza_orders
ORDER BY no_of_pizzas DESC
LIMIT 100;

