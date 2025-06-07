-- RFM (Recency, Frequency, Monetary) Customer Segmentation
WITH customer_rfm AS (
    SELECT 
        c.customer_id,
        c.first_name || ' ' || c.last_name as customer_name,
        c.state,
        
        -- Recency: Days since last order
        CURRENT_DATE - MAX(CAST(o.order_date AS DATE)) as days_since_last_order,
        
        -- Frequency: Number of orders
        COUNT(DISTINCT o.order_id) as order_frequency,
        
        -- Monetary: Total amount spent
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) as total_spent,
        
        -- Additional metrics
        AVG(oi.quantity * oi.list_price * (1 - oi.discount)) as avg_order_value,
        SUM(oi.quantity) as total_items_purchased
        
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 4
    GROUP BY c.customer_id, c.first_name, c.last_name, c.state
),
rfm_scores AS (
    SELECT *,
        -- Create quintile scores (1-5, where 5 is best)
        NTILE(5) OVER (ORDER BY days_since_last_order) as recency_score,
        NTILE(5) OVER (ORDER BY order_frequency DESC) as frequency_score,
        NTILE(5) OVER (ORDER BY total_spent DESC) as monetary_score
    FROM customer_rfm
)
SELECT 
    customer_id,
    customer_name,
    state,
    days_since_last_order,
    order_frequency,
    ROUND(total_spent, 2) as total_spent,
    ROUND(avg_order_value, 2) as avg_order_value,
    
    -- RFM Scores
    recency_score,
    frequency_score,
    monetary_score,
    
    -- Combined RFM Score
    (recency_score + frequency_score + monetary_score) as combined_rfm_score,
    
    -- Customer Segmentation
    CASE 
        WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 
            THEN 'Champions'
        WHEN recency_score >= 3 AND frequency_score >= 3 AND monetary_score >= 3 
            THEN 'Loyal Customers'
        WHEN recency_score >= 3 AND frequency_score <= 2 
            THEN 'Potential Loyalists'
        WHEN recency_score <= 2 AND frequency_score >= 3 
            THEN 'At Risk'
        WHEN recency_score <= 2 AND frequency_score <= 2 AND monetary_score >= 3 
            THEN 'Cannot Lose Them'
        WHEN recency_score >= 4 AND frequency_score <= 2 
            THEN 'New Customers'
        ELSE 'Others'
    END as customer_segment

FROM rfm_scores
ORDER BY combined_rfm_score DESC, total_spent DESC;