SELECT 
    p.product_name,
    b.brand_name,
    c.category_name,
    p.list_price,
    SUM(oi.quantity) as units_sold,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) as total_revenue,
    AVG(oi.discount) as avg_discount_rate,
    COUNT(DISTINCT oi.order_id) as order_frequency
FROM products p
JOIN brands b ON p.brand_id = b.brand_id
JOIN categories c ON p.category_id = c.category_id
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 4
GROUP BY p.product_id, p.product_name, b.brand_name, c.category_name, p.list_price
ORDER BY total_revenue DESC
LIMIT 20;