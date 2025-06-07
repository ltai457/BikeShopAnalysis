-- Analyze customer purchasing behavior
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.city,
    c.state,
    COUNT(DISTINCT o.order_id) as total_orders,
    SUM(oi.quantity) as total_items_purchased,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) as total_spent,
    AVG(oi.quantity * oi.list_price * (1 - oi.discount)) as avg_order_value,
    MIN(CAST(o.order_date AS DATE)) as first_order_date,
    MAX(CAST(o.order_date AS DATE)) as last_order_date
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 4
GROUP BY c.customer_id, c.first_name, c.last_name, c.city, c.state
ORDER BY total_spent DESC;