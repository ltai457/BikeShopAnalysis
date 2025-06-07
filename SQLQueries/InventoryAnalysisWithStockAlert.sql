-- Advanced inventory management with sales velocity
SELECT 
    p.product_id,
    p.product_name,
    b.brand_name,
    c.category_name,
    p.list_price,
    
    -- Current stock levels
    COALESCE(current_stock.total_stock, 0) as current_stock,
    
    -- Sales in last 30 days
    COALESCE(recent_sales.units_sold_30d, 0) as units_sold_last_30_days,
    COALESCE(recent_sales.revenue_30d, 0) as revenue_last_30_days,
    
    -- Sales in last 90 days  
    COALESCE(quarterly_sales.units_sold_90d, 0) as units_sold_last_90_days,
    
    -- Calculate daily sales velocity
    CASE 
        WHEN recent_sales.units_sold_30d > 0 
        THEN ROUND(recent_sales.units_sold_30d / 30.0, 2)
        ELSE 0
    END as daily_sales_velocity,
    
    -- Days of inventory remaining
    CASE 
        WHEN recent_sales.units_sold_30d > 0 
        THEN ROUND(COALESCE(current_stock.total_stock, 0) / (recent_sales.units_sold_30d / 30.0), 1)
        ELSE NULL
    END as days_of_inventory,
    
    -- Stock status alert
    CASE 
        WHEN COALESCE(current_stock.total_stock, 0) = 0 
            THEN 'OUT_OF_STOCK'
        WHEN recent_sales.units_sold_30d > 0 AND 
             COALESCE(current_stock.total_stock, 0) / (recent_sales.units_sold_30d / 30.0) < 7 
            THEN 'CRITICAL_LOW'
        WHEN recent_sales.units_sold_30d > 0 AND 
             COALESCE(current_stock.total_stock, 0) / (recent_sales.units_sold_30d / 30.0) < 14 
            THEN 'LOW_STOCK'
        WHEN recent_sales.units_sold_30d > 0 AND 
             COALESCE(current_stock.total_stock, 0) / (recent_sales.units_sold_30d / 30.0) > 90 
            THEN 'OVERSTOCK'
        WHEN recent_sales.units_sold_30d = 0 AND COALESCE(current_stock.total_stock, 0) > 0 
            THEN 'NO_RECENT_SALES'
        ELSE 'NORMAL'
    END as stock_alert

FROM products p
JOIN brands b ON p.brand_id = b.brand_id
JOIN categories c ON p.category_id = c.category_id

-- Current stock subquery
LEFT JOIN (
    SELECT 
        product_id,
        SUM(quantity) as total_stock
    FROM stocks
    GROUP BY product_id
) current_stock ON p.product_id = current_stock.product_id

-- Recent sales (30 days) subquery
LEFT JOIN (
    SELECT 
        oi.product_id,
        SUM(oi.quantity) as units_sold_30d,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) as revenue_30d
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status = 4 
    AND CAST(o.order_date AS DATE) >= CURRENT_DATE - INTERVAL '30 days'
    GROUP BY oi.product_id
) recent_sales ON p.product_id = recent_sales.product_id

-- Quarterly sales (90 days) subquery
LEFT JOIN (
    SELECT 
        oi.product_id,
        SUM(oi.quantity) as units_sold_90d
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status = 4 
    AND CAST(o.order_date AS DATE) >= CURRENT_DATE - INTERVAL '90 days'
    GROUP BY oi.product_id
) quarterly_sales ON p.product_id = quarterly_sales.product_id

ORDER BY 
    CASE 
        WHEN recent_sales.units_sold_30d > 0 
        THEN COALESCE(current_stock.total_stock, 0) / (recent_sales.units_sold_30d / 30.0)
        ELSE 999
    END ASC;