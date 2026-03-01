/*  9— Monthly Revenue Trend
Calculate total revenue per month.*/
SELECT
   coalesce(DATE_TRUNC('month', order_date)::text,'undefined') AS month,
    SUM(amount*quantity-coalesce(discount,0)) AS total_revenue
FROM orders_manual
GROUP BY month
ORDER BY month;

/*10. Monthly Average Order Value Using CTE*/
WITH monthly_avg_order AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        AVG(amount) AS avg_value
    FROM orders_manual
    GROUP BY month
    order by month
)
SELECT * FROM monthly_avg_order;


/*11. — Month-to-Month Growth Using LAG
Business Scenario
CEO asks:
Compared to last month, did we grow or decline? */
WITH monthly_revenue AS (
    SELECT  date_trunc('month', order_date) AS month, SUM(amount * quantity - COALESCE(discount,0)) AS revenue
    FROM orders_manual WHERE order_date IS NOT NULL  GROUP BY month  ORDER BY month
)
SELECT  month, revenue,LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue,revenue - LAG(revenue) OVER (ORDER BY month) AS revenue_change,
    CASE WHEN revenue - LAG(revenue) OVER (ORDER BY month) > 0 THEN 'Growth'
         WHEN revenue - LAG(revenue) OVER (ORDER BY month) < 0 THEN 'Decline' ELSE 'No Change'  END AS status FROM monthly_revenue;

