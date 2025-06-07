-- Monthly revenue with trend analysis using window functions
WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', CAST(o.order_date AS DATE)) as month,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) as revenue,
        COUNT(DISTINCT o.order_id) as orders
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 4
    GROUP BY DATE_TRUNC('month', CAST(o.order_date AS DATE))
)
SELECT 
    month,
    revenue,
    orders,
    -- Previous month comparison
    LAG(revenue, 1) OVER (ORDER BY month) as prev_month_revenue,
    revenue - LAG(revenue, 1) OVER (ORDER BY month) as month_over_month_change,
    
    -- Growth rate calculation
    ROUND(
        ((revenue - LAG(revenue, 1) OVER (ORDER BY month)) / 
         NULLIF(LAG(revenue, 1) OVER (ORDER BY month), 0)) * 100, 2
    ) as growth_rate_pct,
    
    -- 3-month moving average
    ROUND(
        AVG(revenue) OVER (
            ORDER BY month 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2
    ) as three_month_avg,
    
    -- Rank by revenue
    RANK() OVER (ORDER BY revenue DESC) as revenue_rank
FROM monthly_revenue
ORDER BY month;