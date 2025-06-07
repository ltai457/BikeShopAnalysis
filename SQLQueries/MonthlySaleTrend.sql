SELECT 
    EXTRACT(YEAR FROM CAST(order_date AS DATE)) as year,
    EXTRACT(MONTH FROM CAST(order_date AS DATE)) as month,
    COUNT(DISTINCT o.order_id) as orders,
    COUNT(DISTINCT o.customer_id) as unique_customers,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) as monthly_revenue,
    AVG(oi.quantity * oi.list_price * (1 - oi.discount)) as avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 4
GROUP BY EXTRACT(YEAR FROM CAST(order_date AS DATE)), 
         EXTRACT(MONTH FROM CAST(order_date AS DATE))
ORDER BY year, month;