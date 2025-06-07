-- Create a pivot-style analysis of sales by store and category
SELECT 
    s.store_name,
    s.city,
    
    -- Revenue by category (pivot-like aggregation)
    SUM(CASE WHEN c.category_name = 'Mountain Bikes' 
        THEN oi.quantity * oi.list_price * (1 - oi.discount) ELSE 0 END) as mountain_bikes_revenue,
        
    SUM(CASE WHEN c.category_name = 'Road Bikes' 
        THEN oi.quantity * oi.list_price * (1 - oi.discount) ELSE 0 END) as road_bikes_revenue,
        
    SUM(CASE WHEN c.category_name = 'Electric Bikes' 
        THEN oi.quantity * oi.list_price * (1 - oi.discount) ELSE 0 END) as electric_bikes_revenue,
        
    SUM(CASE WHEN c.category_name = 'Cruisers Bicycles' 
        THEN oi.quantity * oi.list_price * (1 - oi.discount) ELSE 0 END) as cruisers_revenue,
        
    -- Units sold by category
    SUM(CASE WHEN c.category_name = 'Mountain Bikes' 
        THEN oi.quantity ELSE 0 END) as mountain_bikes_units,
        
    SUM(CASE WHEN c.category_name = 'Road Bikes' 
        THEN oi.quantity ELSE 0 END) as road_bikes_units,
    
    -- Total store metrics
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) as total_store_revenue,
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(DISTINCT o.customer_id) as unique_customers

FROM stores s
JOIN orders o ON s.store_id = o.store_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
WHERE o.order_status = 4
GROUP BY s.store_id, s.store_name, s.city
ORDER BY total_store_revenue DESC;