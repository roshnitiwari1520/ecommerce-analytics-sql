use ecommerce_analytics;
# total Revenue Generated till date
 SELECT 
    SUM(quantity * price_per_unit) AS total_revenue
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Completed';

# order Status Distribution
SELECT 
    status,
    COUNT(order_id) AS total_orders,
    ROUND(COUNT(order_id) * 100.0 / SUM(COUNT(order_id)) OVER(), 2) AS percentage
FROM orders
GROUP BY status;


#Montly Revenue Growth Trend

SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
    SUM(oi.quantity * oi.price_per_unit) AS monthly_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Completed'
GROUP BY order_month
ORDER BY order_month;

# Top 3 sellling product in Each Category
WITH CategoryRevenue AS (
    SELECT 
        p.category,
        p.product_name,
        SUM(oi.quantity * oi.price_per_unit) AS total_sales,
        DENSE_RANK() OVER(PARTITION BY p.category ORDER BY SUM(oi.quantity * oi.price_per_unit) DESC) AS product_rank
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.status = 'Completed'
    GROUP BY p.category, p.product_name
)
SELECT category, product_name, total_sales, product_rank
FROM CategoryRevenue
WHERE product_rank <= 3;

# 5 high -Value customers(Whales Anaylsis)
SELECT 
    o.user_id,
    u.name,
    u.email,
    SUM(oi.quantity * oi.price_per_unit) AS total_spent,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN users u ON o.user_id = u.user_id
WHERE o.status = 'Completed'
GROUP BY o.user_id, u.name, u.email
ORDER BY total_spent DESC
LIMIT 25; 

#6 Month_on-Month(MoM)Growth percentage
WITH MonthlyRev AS (
    SELECT 
        DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
        SUM(oi.quantity * oi.price_per_unit) AS current_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Completed'
    GROUP BY order_month
)
SELECT 
    order_month,
    current_revenue,
    LAG(current_revenue) OVER (ORDER BY order_month) AS previous_month_revenue,
    ROUND(((current_revenue - LAG(current_revenue) OVER (ORDER BY order_month)) / LAG(current_revenue) OVER (ORDER BY order_month)) * 100, 2) AS mom_growth_pct
FROM MonthlyRev;

#7: Average Order Value (AOV) Trend
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    ROUND(SUM(quantity * price_per_unit) / COUNT(DISTINCT o.order_id), 2) AS average_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Completed'
GROUP BY order_month
ORDER BY order_month;

#Query 8: Cumulative (Running) Revenue Over Time

WITH DailyRevenue AS (
    SELECT 
        order_date,
        SUM(oi.quantity * oi.price_per_unit) AS daily_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Completed'
    GROUP BY order_date
)
SELECT 
    order_date,
    ROUND(daily_revenue, 2) AS daily_revenue,
    ROUND(SUM(daily_revenue) OVER (ORDER BY order_date), 2) AS cumulative_revenue
FROM DailyRevenue
ORDER BY order_date;
#8: Cumulative (Running) Revenue Over Time
WITH DailyRevenue AS (
    SELECT 
        order_date,
        SUM(oi.quantity * oi.price_per_unit) AS daily_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Completed'
    GROUP BY order_date
)
SELECT 
    order_date,
    ROUND(daily_revenue, 2) AS daily_revenue,
    ROUND(SUM(daily_revenue) OVER (ORDER BY order_date), 2) AS cumulative_revenue
FROM DailyRevenue
ORDER BY order_date;
# 9: Repeat Purchase Rate (RPR)
WITH CustomerOrderCounts AS (
    SELECT 
        user_id,
        COUNT(order_id) AS total_orders
    FROM orders
    WHERE status = 'Completed'
    GROUP BY user_id
)
SELECT 
    COUNT(CASE WHEN total_orders > 1 THEN 1 END) AS repeat_customers,
    COUNT(user_id) AS total_customers,
    ROUND(COUNT(CASE WHEN total_orders > 1 THEN 1 END) * 100.0 / COUNT(user_id), 2) AS repeat_purchase_rate_pct
FROM CustomerOrderCounts;
# 11: Most Returned Product Categories
SELECT 
    p.category,
    COUNT(CASE WHEN o.status = 'Returned' THEN 1 END) AS returned_items_count,
    COUNT(oi.order_item_id) AS total_items_sold,
    ROUND(COUNT(CASE WHEN o.status = 'Returned' THEN 1 END) * 100.0 / COUNT(oi.order_item_id), 2) AS return_rate_pct
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
GROUP BY p.category
ORDER BY return_rate_pct DESC;
# 12: Peak Order Hours & Days (Time-Series Analysis)
SELECT 
    DAYNAME(order_date) AS day_of_week,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY day_of_week
ORDER BY FIELD(day_of_week, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');
#13 : Customer Lifetime Value (CLV) by Country
SELECT 
    u.country,
    COUNT(DISTINCT u.user_id) AS total_customers,
    ROUND(SUM(oi.quantity * oi.price_per_unit), 2) AS total_revenue,
    ROUND(SUM(oi.quantity * oi.price_per_unit) / COUNT(DISTINCT u.user_id), 2) AS customer_lifetime_value
FROM users u
JOIN orders o ON u.user_id = o.user_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Completed'
GROUP BY u.country
ORDER BY customer_lifetime_value DESC;

# 14: Pareto 80/20 Rule Verification
WITH ProductRevenue AS (
    SELECT 
        product_id,
        SUM(quantity * price_per_unit) AS revenue,
        SUM(SUM(quantity * price_per_unit)) OVER() AS total_revenue
    FROM order_items
    GROUP BY product_id
),
RunningRevenue AS (
    SELECT 
        product_id,
        revenue,
        SUM(revenue) OVER(ORDER BY revenue DESC) AS cumulative_revenue,
        total_revenue
    FROM ProductRevenue
)
SELECT 
    product_id,
    revenue,
    ROUND((cumulative_revenue / total_revenue) * 100, 2) AS running_revenue_pct
FROM RunningRevenue;
#Query 15: Checkout Funnel Drop-off Simulation
SELECT 
    (SELECT COUNT(*) FROM users) AS stage_1_all_registered_users,
    COUNT(DISTINCT user_id) AS stage_2_placed_any_order,
    COUNT(DISTINCT CASE WHEN status = 'Completed' THEN user_id END) AS stage_3_successful_buyers,
    ROUND(COUNT(DISTINCT user_id) * 100.0 / (SELECT COUNT(*) FROM users), 2) AS registration_to_order_pct,
    ROUND(COUNT(DISTINCT CASE WHEN status = 'Completed' THEN user_id END) * 100.0 / COUNT(DISTINCT user_id), 2) AS conversion_rate_pct
FROM orders;
#Query 16 & 17: RFM Segmentation 
-- Query 16: Calculating Raw RFM Values
CREATE OR REPLACE VIEW rfm_raw AS
SELECT 
    user_id,
    DATEDIFF('2026-06-15', MAX(order_date)) AS recency,
    COUNT(DISTINCT order_id) AS frequency,
    SUM(quantity * price_per_unit) AS monetary
FROM orders
JOIN order_items USING (order_id)
WHERE status = 'Completed'
GROUP BY user_id;

-- Query 17: Generating RFM Scores & Segments
WITH RFM_Scores AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency DESC) AS r_score, -- Churn risk high = low score
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM rfm_raw
)
SELECT 
    user_id, recency, frequency, monetary,
    CONCAT(r_score, f_score, m_score) AS rfm_cell,
    CASE 
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions / Loyal'
        WHEN r_score >= 3 AND f_score <= 2 THEN 'New / Promising'
        WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk / Can Cannot Lose'
        WHEN r_score <= 1 THEN 'Lost / Dormant'
        ELSE 'Regular Customer'
    END AS customer_segment
FROM RFM_Scores;

#: Cohort Retention Analysis 
-- Query 18: Cohort Base (User registration month and activity months)
WITH UserCohorts AS (
    SELECT 
        user_id,
        DATE_FORMAT(created_at, '%Y-%m') AS cohort_month
    FROM users
),
UserActivity AS (
    SELECT 
        o.user_id,
        DATE_FORMAT(o.order_date, '%Y-%m') AS activity_month,
        PERIOD_DIFF(DATE_FORMAT(o.order_date, '%Y%m'), DATE_FORMAT(u.created_at, '%Y%m')) AS month_number
    FROM orders o
    JOIN users u ON o.user_id = u.user_id
    WHERE o.status = 'Completed'
),
CohortSizes AS (
    SELECT cohort_month, COUNT(distinct user_id) AS total_users
    FROM UserCohorts
    GROUP BY cohort_month
),
-- Query 19: Retained Users Per Cohort Month
RetentionData AS (
    SELECT 
        uc.cohort_month,
        ua.month_number,
        COUNT(DISTINCT ua.user_id) AS retained_users
    FROM UserCohorts uc
    JOIN UserActivity ua ON uc.user_id = ua.user_id
    WHERE ua.month_number >= 0
    GROUP BY uc.cohort_month, ua.month_number
)
-- Query 20: Final Cohort Matrix Representation
SELECT 
    r.cohort_month,
    s.total_users AS cohort_size,
    MAX(CASE WHEN r.month_number = 0 THEN ROUND(r.retained_users * 100.0 / s.total_users, 1) END) AS month_0,
    MAX(CASE WHEN r.month_number = 1 THEN ROUND(r.retained_users * 100.0 / s.total_users, 1) END) AS month_1,
    MAX(CASE WHEN r.month_number = 2 THEN ROUND(r.retained_users * 100.0 / s.total_users, 1) END) AS month_2,
    MAX(CASE WHEN r.month_number = 3 THEN ROUND(r.retained_users * 100.0 / s.total_users, 1) END) AS month_3,
    MAX(CASE WHEN r.month_number = 4 THEN ROUND(r.retained_users * 100.0 / s.total_users, 1) END) AS month_4
FROM RetentionData r
JOIN CohortSizes s ON r.cohort_month = s.cohort_month
GROUP BY r.cohort_month, s.total_users
ORDER BY r.cohort_month;