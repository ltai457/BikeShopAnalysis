-- Evaluate staff performance
SELECT 
    st.first_name,
    st.last_name,
    s.store_name,
    COUNT(DISTINCT o.order_id) as orders_processed,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) as total_sales,
    AVG(oi.quantity * oi.list_price * (1 - oi.discount)) as avg_order_value,
    COUNT(DISTINCT o.customer_id) as unique_customers_served
FROM staffs st
JOIN stores s ON st.store_id = s.store_id
JOIN orders o ON st.staff_id = o.staff_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 4 AND st.active = 1
GROUP BY st.staff_id, st.first_name, st.last_name, s.store_name
ORDER BY total_sales DESC;