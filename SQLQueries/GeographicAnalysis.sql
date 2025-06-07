-- Revenue by state/city
SELECT 
    c.state,
    c.city,
    COUNT(DISTINCT c.customer_id) as customer_count,
    COUNT(DISTINCT o.order_id) as total_orders,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) as total_revenue,
    AVG(oi.quantity * oi.list_price * (1 - oi.discount)) as avg_order_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 4
GROUP BY c.state, c.city
HAVING COUNT(DISTINCT o.order_id) >= 5  -- Only cities with 5+ orders
ORDER BY total_revenue DESC
LIMIT 15;