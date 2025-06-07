-- Advanced product ranking with multiple metrics
SELECT 
    p.product_name,
    b.brand_name,
    c.category_name,
    SUM(oi.quantity) as units_sold,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) as total_revenue,
    
    -- Ranking within category
    ROW_NUMBER() OVER (
        PARTITION BY c.category_name 
        ORDER BY SUM(oi.quantity * oi.list_price * (1 - oi.discount)) DESC
    ) as category_rank,
    
    -- Overall ranking
    DENSE_RANK() OVER (
        ORDER BY SUM(oi.quantity * oi.list_price * (1 - oi.discount)) DESC
    ) as overall_rank,
    
    -- Percentage of category revenue
    ROUND(
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) * 100.0 / 
        SUM(SUM(oi.quantity * oi.list_price * (1 - oi.discount))) OVER (
            PARTITION BY c.category_name
        ), 2
    ) as pct_of_category_revenue,
    
    -- Running total within category
    SUM(SUM(oi.quantity * oi.list_price * (1 - oi.discount))) OVER (
        PARTITION BY c.category_name 
        ORDER BY SUM(oi.quantity * oi.list_price * (1 - oi.discount)) DESC
        ROWS UNBOUNDED PRECEDING
    ) as running_total_in_category

FROM products p
JOIN brands b ON p.brand_id = b.brand_id
JOIN categories c ON p.category_id = c.category_id
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 4
GROUP BY p.product_id, p.product_name, b.brand_name, c.category_name
ORDER BY c.category_name, category_rank;