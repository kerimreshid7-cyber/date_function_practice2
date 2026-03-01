/* Challenge 1 — Orders Per Month
Business Question:
How many orders did we receive each month?*/
 select date_trunc('month',order_date) as month ,count (*) 
 from orders group by date_trunc('month',order_date) order by month; 

    /*This query helps us to show total orders per month using grouping.  
    1 date_trunc is used to cut the month to start the first date of that month for example
     if the orer date is jan 16 then it will turn to jan 1 then up to the final date registered in that month.*/


/*Challenge 2 — Monthly Revenue
Calculate: (price × quantity) - discount  then   Grouped by month.*/
select month,total_revenue from (select  date_trunc('month',order_date)as month ,
 sum(amount*quantity- coalesce(discount,0))as total_revenue from orders_manual 
 group by  date_trunc('month',order_date) order by total_revenue desc) t;
       

/* Challenge 3 — Orders Per Month  (its similar to challenge 1 but 
the differece is what if null values in order date )
Business Question:
How many orders did we receive each month?*/
select coalesce(date_trunc('month',order_date)::text,'pending')as month ,count(*)as total_order_permonth 
from orders_manual group by month order by total_order_permonth desc; 

/* the coalsce function will give another row called pending but if there is null values in order_datet t
hen while we are using count(*) the null values will be counted and display in pending  row.*/



/* Challenge 4— Management asks:
How many orders do we receive each month?
They want to understand seasonality.*/
select coalesce(date_trunc('month',order_date):: text,'pending') as month , count(*) as total_orders_per_month 
from orders_manual   group by month order by total_orders_per_month desc;

--In this query coalsce is used for if there is ordera-date null then it gives pending as month then .
--count(*) counts all null values  in the out we will show total  orders per month 



/*Challenge 5 — Monthly Revenue Trend (Trend Analysis)
Business Scenario
Finance team asks: How is revenue changing month by month? They want to see growth or decline.*/
select  date_trunc('month',order_date)as month,sum(amount*quantity -coalesce(discount,0) ) as revenue_per_month from orders_manual 
group by month order by month;



/*Challenge 6 — Delivery Time Analysis (Date Functions + Business Logic)
Business Scenario
Operations manager asks:
What is the average delivery time in days per month?
Delivery time = shipped_date − order_date*/
select date_trunc('month',order_date) as month ,avg(extract(epoch from(shipped_date-order_date))/86400)as average_delivery_time 
from orders_manual where order_date is not null and shipped_date is not null   group by month order by month;

/* here is new query function   avg(extract(epoch from(shipped_date-order_date))/86400)  
    these functions doing avg= it will calculate average value of inside value  extract will use again inside the parentesis then divide by 86400
       epoch will change the value in to seconds      shipped_date-order_date) is business logic */


/* Challenge 7 — Month-to-Month Growth Using LAG
Business Scenario
CEO asks:
Compared to last month, did we grow or decline? */
WITH monthly_revenue AS (
    SELECT  date_trunc('month', order_date) AS month, SUM(price * quantity - COALESCE(discount,0)) AS revenue
    FROM orders_manual WHERE order_date IS NOT NULL  GROUP BY month  ORDER BY month
)
SELECT  month, revenue,LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue,revenue - LAG(revenue) OVER (ORDER BY month) AS revenue_change,
    CASE WHEN revenue - LAG(revenue) OVER (ORDER BY month) > 0 THEN 'Growth'
         WHEN revenue - LAG(revenue) OVER (ORDER BY month) < 0 THEN 'Decline' ELSE 'No Change'  END AS status FROM monthly_revenue;


 /* Challenge 8 — Complex Business Challenge (Merge Everything)
Business Scenario
The company wants to identify future delivery risk
They suspect: If current orders are growing fast compared to previous month, next month shipments may be delayed.
So they want analysis combining:Time trends,Growth,Previous data and Future comparison */

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

/*The queries i have used and  the concepts i revised CTEs advanced window functions(lag and lead)
    round function (to round the result by 2) group by(to split the data by group) ,order by to sort the out put, d
    date_trunc to cut the date to the first date of that month    and case when logic with */























