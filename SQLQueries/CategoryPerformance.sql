SELECT 
    c.category_name,
    COUNT(DISTINCT p.product_id) as product_count,
    SUM(oi.quantity) as total_units_sold,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) as category_revenue,
    AVG(p.list_price) as avg_list_price,
    AVG(oi.discount) as avg_discount_rate,
    AVG(oi.quantity * oi.list_price * (1 - oi.discount)) as avg_sale_value
FROM categories c
JOIN products p ON c.category_id = p.category_id
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 4
GROUP BY c.category_id, c.category_name
ORDER BY category_revenue DESC;