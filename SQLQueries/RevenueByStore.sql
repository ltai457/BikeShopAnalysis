SELECT 
    s.store_name,
    s.city,
    s.state,
    COUNT(o.order_id) as total_orders,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) as revenue,
    AVG(oi.quantity * oi.list_price * (1 - oi.discount)) as avg_order_value
FROM stores s
JOIN orders o ON s.store_id = o.store_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 4
GROUP BY s.store_id, s.store_name, s.city, s.state
ORDER BY revenue DESC;