SELECT 
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(DISTINCT o.customer_id) as total_customers,
    COUNT(DISTINCT p.product_id) as total_products,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) as total_revenue,
    AVG(oi.quantity * oi.list_price * (1 - oi.discount)) as avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.order_status = 4; -- Completed orders only