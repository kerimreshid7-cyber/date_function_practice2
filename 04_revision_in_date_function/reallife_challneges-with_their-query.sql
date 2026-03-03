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


-- Lets do it step by step first   
SELECT
    date_trunc('month', order_date) AS month,
    COUNT(order_id) AS total_orders
FROM orders_manual
WHERE order_date IS NOT NULL
GROUP BY month
ORDER BY month;
/* Here first i wrote to query to show total orders per month    
then i will use it in the finall query in side with out order by bc we use it in aggregation functions'with' */



 /* Challenge 12 — Complex Business Challenge (Merge Everything)
Business Scenario
The company wants to identify future delivery risk
They suspect: If current orders are growing fast compared to previous month, next month shipments may be delayed.
So they want analysis combining:Time trends,Growth,Previous data and Future comparison */

--Here is the finall query and I will paste the above query in side CTEs(with)
WITH monthly_orders AS (
    SELECT date_trunc('month', order_date) AS month,
        COUNT(order_id) AS total_orders FROM orders_manual WHERE order_date IS NOT NULL GROUP BY month )
SELECT   month,total_orders,
    LAG(total_orders) OVER (ORDER BY month) AS previous_month_orders,
    LEAD(total_orders) OVER (ORDER BY month) AS next_month_orders,

    ROUND(
        (total_orders - LAG(total_orders) OVER (ORDER BY month))
        * 100.0  / LAG(total_orders) OVER (ORDER BY month), 2) AS growth_percent,
    CASE
        WHEN (total_orders - LAG(total_orders) OVER (ORDER BY month))
            * 100.0  / LAG(total_orders) OVER (ORDER BY month) > 20 THEN 'High Risk' ELSE 'Normal'
    END AS risk_flag FROM monthly_orders ORDER BY month;