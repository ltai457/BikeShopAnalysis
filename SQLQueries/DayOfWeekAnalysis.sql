SELECT 
    CASE EXTRACT(DOW FROM CAST(order_date AS DATE))
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END as day_of_week,
    COUNT(o.order_id) as total_orders,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) as revenue,
    AVG(oi.quantity * oi.list_price * (1 - oi.discount)) as avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 4
GROUP BY EXTRACT(DOW FROM CAST(order_date AS DATE))
ORDER BY total_orders DESC;