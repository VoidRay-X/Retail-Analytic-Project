------ Bussiness problems


--------X------------------------X---------------------------X-----------------------------X-----------------------X-------------------
-- kinda high level metric 
--------X------------------------X---------------------------X-----------------------------X-----------------------X-------------------

-- 1. Total number of orders
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM orders_360
--  Insight: Indicates total business volume handled.

-- 2. Number of Customers
select count(distinct customer_id) from customer_360
--Insight: Core to understanding market reach

-- 3. Total Revenue, Profit, and Cost
SELECT 
    SUM(total_amount) AS total_revenue,
    SUM(profit) AS total_profit,
    SUM(total_amount - profit) AS total_cost
FROM orders_360;
--  Insight: Core financial performance — cost structure vs earnings.

-- 4. Total quantity of products sold
SELECT SUM(quantity) AS total_quantity_sold
FROM orders_360;
--  Insight: Understand product movement & inventory planning.

-- 5. Total distinct products, categories, stores
SELECT 
    COUNT(DISTINCT product_id) AS total_products,
    COUNT(DISTINCT category) AS total_categories,
    COUNT(DISTINCT store_id) AS total_stores
FROM orders_360;
--  Insight: Variety of offerings & store coverage.

-- 6. Total locations (states), Region
SELECT COUNT(DISTINCT seller_state) AS total_locations,
	COUNT(DISTINCT Region) AS Total_Regions
FROM store_360
--  Insight: Business geographical footprint.

-- 7. Total payment methods used
SELECT 
    COUNT(CASE WHEN credit_card_paid > 0 THEN 1 END) as credit,
    COUNT(CASE WHEN debit_card_paid > 0 THEN 1 END) as debit,
    COUNT(CASE WHEN upi_cash_paid > 0 THEN 1 END) as upi,
    COUNT(CASE WHEN voucher_paid > 0 THEN 1 END) AS voucher
FROM customer_360;
--  Insight: Customer payment preferences.

-- 8.Total Channels
SELECT 
  COUNT(DISTINCT Channel) AS Total_Channels
  FROM orders_360
--Insight: Tracks operational channels

-- 9. Average order value (AOV)
select round(sum(paid_amount)/count(distinct order_id),2) from orders_360

--  Insight: Measure spending per order for pricing/marketing.

-- 10. Avg Categories per Order

SELECT AVG(avgCount) AS Avg_Categories_per_Order
FROM (
  SELECT order_id, COUNT(DISTINCT Category) AS avgCount
  FROM Orders_360
  GROUP BY order_id
) AS T
-- Insight: Indicates product diversity in orders.

-- 11. Average profit per customer
SELECT ROUND(AVG(total_profit), 2) AS avg_profit_per_customer
FROM customer_360;
--  Insight: Profitability per customer to target high-value ones.

-- 12. Average sales per customer
SELECT ROUND(AVG(total_revenue), 2) AS avg_sales_per_customer
FROM customer_360;
--  Insight: Identify customer lifetime value.

-- 13. Average number of items per order
SELECT ROUND(AVG(quantity), 2) AS avg_items_per_order
FROM orders_360;
--  Insight: Upselling potential per order.

-- 14. Average number of days between transactions

with diff as (
	select customer_id, abs(DATEDIFF(DAY,LAG(bill_date_timestamp) over (partition by customer_id order by bill_date_timestamp),
	bill_date_timestamp	)) as days_avg 
	from orders_360)
select avg(days_avg) from diff
where days_avg >0

--  Insight: Helps define re-engagement strategies for returning customers.

-- 15. Profit and Discount percentage
SELECT 
    ROUND(SUM(profit)*100.0 / NULLIF(SUM(total_amount),0), 2) AS profit_percentage,
	Round(SUM(Discount) * 100.0 / SUM(Paid_amount),2) AS Discount_Percentage
FROM orders_360;
--  Insight: Margin analysis for profitability.

-- 16. Average discount per order
SELECT 
    ROUND(AVG(mrp - paid_amount), 2) AS avg_discount_per_order
FROM orders_360;
--Insight: Helps evaluate promo campaign effectiveness.

-- 17. Total Discount
SELECT SUM(discount) AS Total_Discount FROM Orders_360
-- Insight: Helps to understand the total discount given so to know promo campaign effectiveness

-- 18. Average Discount per Customer

select sum(discount)/count(distinct customer_id) from orders_360
-- Insight: Indicates promotional spend effectiveness on a per-customer level

-- 19. Transactions per Customer
select avg(total_orders) from customer_360
--Insight: Indicates engagement and frequency.

-- 20. One-time buyer percentage
SELECT 
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customer_360) AS one_time_buyer_percentage
FROM customer_360
WHERE total_orders = 1;
--  Insight: Retention problem if high % of customers order only once.

-- 21. Repeat customer percentage
SELECT 
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customer_360) AS repeat_customer_percentage
FROM customer_360
WHERE total_orders > 1;
--  Insight: High repeat % indicates brand loyalty.

-- 22. Monthly New Customer Acquisition
SELECT 
    FORMAT(MIN(first_order_date), 'yyyy-MM') AS month_joined,
    COUNT(distinct customer_id) AS new_customers
FROM customer_360
GROUP BY FORMAT(first_order_date, 'yyyy-MM')
ORDER BY month_joined;
--  Insight: Understand customer acquisition trends over time.

-- 23. Monthly Retention Trend

WITH first_purchase AS (
    SELECT 
        customer_id,
        FORMAT(CAST(MIN(bill_date_timestamp) AS DATE), 'yyyy-MM') AS first_buy_month
    FROM orders_360
    GROUP BY customer_id
),

-- Count new customers by month
cohort_monthly AS (
    SELECT 
        first_buy_month,
        COUNT(DISTINCT customer_id) AS new_customers
    FROM first_purchase
    GROUP BY first_buy_month
),

-- Total new customers across all months
final_customers_cte AS (
    SELECT SUM(new_customers) AS total_customers
    FROM cohort_monthly
),

-- Customers retained next month
retained_customers AS (
    SELECT 
        cfp.customer_id,
        cfp.first_buy_month
    FROM first_purchase cfp
    JOIN orders_360 o
        ON cfp.customer_id = o.customer_id
        AND CAST(FORMAT(CAST(o.bill_date_timestamp AS DATE), 'yyyy-MM') + '-01' AS DATE) = 
            DATEADD(MONTH, 1, CAST(cfp.first_buy_month + '-01' AS DATE))
)

-- Final result
SELECT 
    cm.first_buy_month,
    cm.new_customers,
    COUNT(DISTINCT rc.customer_id) AS retained_customers
FROM cohort_monthly cm
JOIN final_customers_cte tnc ON 1=1
LEFT JOIN retained_customers rc 
    ON cm.first_buy_month = rc.first_buy_month
GROUP BY cm.first_buy_month, cm.new_customers, tnc.total_customers
ORDER BY cm.first_buy_month;


--  Insight: Identifies drop-off periods post-acquisition.

-- 24. Revenue by New vs Existing Customers (monthly)

WITH First_Purchase AS (
  SELECT 
    customer_id,
    MIN(month(bill_date_timestamp)) AS first_purchase_month
  FROM orders_360
  GROUP BY customer_id
),
Orders_With_Type AS (
  SELECT 
    o.customer_id,
    month(o.bill_date_timestamp) AS order_month,
    o.paid_amount,
    CASE 
      WHEN month(o.bill_date_timestamp) = fp.first_purchase_month THEN 'New'
      ELSE 'Existing'
    END AS customer_type
  FROM orders_360 o
  JOIN First_Purchase fp ON o.customer_id = fp.customer_id
)
SELECT 
  order_month,
  customer_type,
    SUM(paid_amount) AS total_revenue
FROM Orders_With_Type
GROUP BY order_month, customer_type
ORDER BY order_month, customer_type;

-- Insight: Track how new and old customers contribute to monthly growth.

-- 25. Seasonality: Sales Trends by Category & Month
SELECT 
    FORMAT(cast(bill_date_timestamp as datetime), 'yyyy MMMM') AS month_year,
	category,
    SUM(quantity) AS total_qty,
    SUM(total_amount) AS total_sales
FROM orders_360
GROUP BY category, FORMAT(cast(bill_date_timestamp as datetime), 'yyyy MMMM')
ORDER BY month_year, category;
-- Insight: Reveal seasonal preferences per product category.

-- 26. Region-wise Contribution
SELECT 
    region,
    SUM(total_revenue) AS region_revenue,
    ROUND(SUM(total_revenue) * 100.0 / (SELECT SUM(total_revenue) FROM store_360), 2) AS revenue_pct
FROM store_360
GROUP BY region;
--  Insight: Identify underperforming or high-value regions.

-- 27. Top 10 Popular Categories by Quantity
SELECT TOP 10 category, SUM(quantity) AS qty_sold
FROM orders_360
GROUP BY category
ORDER BY qty_sold DESC;
--  Insight: Helps optimize stock and promotions on high-demand items.

-- 28. Top 10 Most Expensive Products (by MRP) and Their Sales
SELECT TOP 10 product_id, MAX(mrp) AS max_price, SUM(total_amount) AS sales_contribution
FROM orders_360
GROUP BY product_id
ORDER BY max_price DESC;
--  Insight: Target premium product positioning and profitability.

-- 29. All Products Appeared in Transactions
SELECT DISTINCT product_id
FROM orders_360;
-- Insight: Total variety of SKUs that drive transactions.

-- 30. Top 10 Performing Stores by Revenue
SELECT TOP 10 store_id, SUM(total_revenue) AS revenue
FROM store_360
GROUP BY store_id
ORDER BY revenue DESC;
-- Insight: Learn from top stores and replicate strategies.

-- 31. Bottom 10 Performing Stores by Revenue
SELECT TOP 10 store_id, SUM(total_revenue) AS revenue
FROM store_360
GROUP BY store_id
ORDER BY revenue ASC;
-- Insight: Investigate poor-performing stores for corrective action.


-- 32. Popular Categories / Products by Store, State, Region
select category, sum(quantity) total_quantity from orders_360
group by category
order by total_quantity desc

select store_id, sum(quantity) total_quantity from orders_360
group by store_id
order by total_quantity desc


select seller_state, sum(quantity) total_quantity from orders_360 o join store_360 s
on o.store_id=s.store_id
group by seller_state
order by total_quantity desc

select region, sum(quantity) total_quantity from orders_360 o join store_360 s
on o.store_id=s.store_id
group by region
order by total_quantity desc
-- Insight: Helps optimize inventory by geography.

-- 33. Trends: Monthly Sales by Category, Region, Store, Channel

select  YEAR(CAST(bill_date_timestamp AS datetime)) AS order_year,
    DATENAME(MONTH, CAST(bill_date_timestamp AS datetime)) AS order_month_name,category ,count(distinct order_id) sales from orders_360
group by YEAR(CAST(bill_date_timestamp AS datetime)),DATENAME(MONTH, CAST(bill_date_timestamp AS datetime)),month(bill_date_timestamp), category
order by order_year ,month(bill_date_timestamp), sales
 
select  YEAR(CAST(bill_date_timestamp AS datetime)) AS order_year,
    DATENAME(MONTH, CAST(bill_date_timestamp AS datetime)) AS order_month_name, region ,count(distinct order_id) sales from orders_360 o
	join store_360 s
	on o.store_id=s.store_id
group by YEAR(CAST(bill_date_timestamp AS datetime)),DATENAME(MONTH, CAST(bill_date_timestamp AS datetime)),month(bill_date_timestamp), region
order by order_year ,month(bill_date_timestamp), sales

select  YEAR(CAST(bill_date_timestamp AS datetime)) AS order_year,
    DATENAME(MONTH, CAST(bill_date_timestamp AS datetime)) AS order_month_name, store_id ,count(distinct order_id) sales from orders_360
group by YEAR(CAST(bill_date_timestamp AS datetime)),DATENAME(MONTH, CAST(bill_date_timestamp AS datetime)),month(bill_date_timestamp), store_id
order by order_year ,month(bill_date_timestamp), sales

select  YEAR(CAST(bill_date_timestamp AS datetime)) AS order_year,
    DATENAME(MONTH, CAST(bill_date_timestamp AS datetime)) AS order_month_name, channel ,count(distinct order_id) sales from orders_360
group by YEAR(CAST(bill_date_timestamp AS datetime)),DATENAME(MONTH, CAST(bill_date_timestamp AS datetime)),month(bill_date_timestamp), channel
order by order_year ,month(bill_date_timestamp), sales

-- Business Relevance: Seasonality and performance across dimensions.



--------X------------------------X---------------------------X-----------------------------X-----------------------X-------------------
--  CUSTOMER BEHAVIOUR ANALYSIS
--------X------------------------X---------------------------X-----------------------------X-----------------------X-------------------

--  1. Segment Customers by Revenue
select revenue_segment, count(customer_id) customer_count from (SELECT 
    customer_id,
    total_revenue,
    CASE 
        WHEN total_revenue >= 1000 THEN 'High'
        WHEN total_revenue >= 500 THEN 'Medium'
        ELSE 'Low'
    END AS revenue_segment
FROM customer_360) as t
group by revenue_segment

--  Insight: Enables targeted campaigns—'High' for loyalty rewards, 'Low' for reactivation offers.

--  2. RFM Segmentation (Recency, Frequency, Monetary)
 ;WITH rfm_base AS (
    SELECT 
        customer_id,
        DATEDIFF(DAY, last_order_date, GETDATE()) AS recency,
        total_orders AS frequency,
        total_revenue AS monetary
    FROM customer_360
),

recency_ranked AS (
    SELECT *,
        NTILE(4) OVER (ORDER BY recency ASC) AS r_score
    FROM rfm_base
),

frequency_ranked AS (
    SELECT *,
        NTILE(4) OVER (ORDER BY frequency DESC) AS f_score
    FROM recency_ranked
),

monetary_ranked AS (
    SELECT *,
        NTILE(4) OVER (ORDER BY monetary DESC) AS m_score
    FROM frequency_ranked
)

SELECT 
    rfm_segment, 
    COUNT(customer_id) AS custcount
FROM (
    SELECT
        customer_id,
        recency,
        frequency,
        monetary,
        r_score,
        f_score,
        m_score,
        CAST(r_score AS VARCHAR) + CAST(f_score AS VARCHAR) + CAST(m_score AS VARCHAR) AS rfm_score,
        CASE
            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Premium'
            WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Gold'
            WHEN r_score <= 2 AND f_score >= 2 AND m_score >= 2 THEN 'Silver'
            ELSE 'Standard'
        END AS rfm_segment
    FROM monetary_ranked
) AS A
GROUP BY rfm_segment;



-- Insight: Helps classify customers based on loyalty and recent activity for retention strategies.

--  3. Customers Active in All Channels
SELECT customer_id
FROM orders_360
GROUP BY customer_id
HAVING COUNT(DISTINCT channel) = (SELECT COUNT(DISTINCT channel) FROM orders_360);
--  Insight: Multi-channel customers show high engagement; potential brand advocates.

--  4. One-Time vs Repeat Buyers
select buyer_type, count(customer_id) customer from (
SELECT 
    customer_id,
    total_orders,
    CASE 
        WHEN total_orders = 1 THEN 'One-time Buyer'
        ELSE 'Repeat Buyer'
    END AS buyer_type
FROM customer_360) as A
group by buyer_type

-- Insight: One-time buyers are churn risks; repeat buyers are good candidates for loyalty programs.

-- 5. Discount Seekers vs Non-discount Seekers
select discount_type, count(customer_id) as customer from
(SELECT 
    customer_id,
    SUM(discount) AS total_discount,
    COUNT(order_id) AS total_orders,
    CASE 
        WHEN SUM(discount) > 25 THEN 'Discount Seeker'
        ELSE 'Non Discount Seeker'
    END AS discount_type
FROM orders_360
GROUP BY customer_id) as A
group by discount_type

--  Insight: Useful for promoting seasonal sales or full-price premium bundles.

--  6. Customer Preferences (Channel, Payment, Store, Category)

-- Step 1: Preferred Channel
WITH Preferred_Channel AS (
    SELECT customer_id, channel,
           COUNT(*) AS freq,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY COUNT(*) DESC) AS rn
    FROM orders_360
    GROUP BY customer_id, channel
),

-- Step 2: Unpivot payment columns to get one row per payment method usage
Unpivoted_Payments AS (
    SELECT customer_id, payment_method, payment_value
    FROM (
        SELECT customer_id, credit_card, upi_cash, debit_card, voucher
        FROM orders_360
    ) p
    UNPIVOT (
        payment_value FOR payment_method IN (credit_card, upi_cash, debit_card, voucher)
    ) AS up
),

-- Step 3: Preferred Payment Method
Preferred_Payment AS (
    SELECT customer_id, payment_method,
           SUM(payment_value) AS total_paid,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY SUM(payment_value) DESC) AS rn
    FROM Unpivoted_Payments
    GROUP BY customer_id, payment_method
),

-- Step 4: Preferred Store
Preferred_Store AS (
    SELECT customer_id, store_id,
           COUNT(*) AS freq,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY COUNT(*) DESC) AS rn
    FROM orders_360
    GROUP BY customer_id, store_id
),

-- Step 5: Preferred Category
Preferred_Category AS (
    SELECT customer_id, category,
           COUNT(*) AS freq,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY COUNT(*) DESC) AS rn
    FROM orders_360
    GROUP BY customer_id, category
)

-- Final Output: Merge all preferred attributes per customer
SELECT 
    c.customer_id,
    pc.channel AS preferred_channel,
    pp.payment_method AS preferred_payment,
    ps.store_id AS preferred_store,
    cat.category AS preferred_category
FROM customer_360 c
LEFT JOIN Preferred_Channel pc ON c.customer_id = pc.customer_id AND pc.rn = 1
LEFT JOIN Preferred_Payment pp ON c.customer_id = pp.customer_id AND pp.rn = 1
LEFT JOIN Preferred_Store ps ON c.customer_id = ps.customer_id AND ps.rn = 1
LEFT JOIN Preferred_Category cat ON c.customer_id = cat.customer_id AND cat.rn = 1;

--  Insight: Personalization—target users on their preferred platforms with preferred offers.

-- 7. Single vs Multi-category Buyers
select category_type, count(customer_id) as customer from
(SELECT 
    customer_id,
    COUNT(DISTINCT category) AS unique_categories,
    CASE 
        WHEN COUNT(DISTINCT category) = 1 THEN 'Single Category Buyer'
        ELSE 'Multi-Category Buyer'
    END AS category_type
FROM orders_360
GROUP BY customer_id) as A
group by category_type

-- Insight: Cross-sell opportunity for single-category buyers; loyalty schemes for multi-category.


--------X------------------------X---------------------------X-----------------------------X-----------------------X-------------------
--  Cross-Selling: Top 10 category combinations bought together (Pairs)
--------X------------------------X---------------------------X-----------------------------X-----------------------X-------------------
SELECT 
    o1.category AS category_1,
    o2.category AS category_2,
    COUNT(*) AS times_bought_together
FROM orders_360 o1
JOIN orders_360 o2 
    ON o1.order_id = o2.order_id
    AND o1.category < o2.category  -- Avoid duplicates like (A-B) and (B-A)
    AND o1.category IS NOT NULL AND o2.category IS NOT NULL
GROUP BY o1.category, o2.category
ORDER BY times_bought_together DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

-- Insights: These category combinations reveal natural bundling opportunities for 
--marketing or UI improvements ("Frequently Bought Together" sections)




--------X------------------------X---------------------------X-----------------------------X-----------------------X-------------------
-- Understand the Category Behavior
--------X------------------------X---------------------------X-----------------------------X-----------------------X-------------------

--  1. Total Sales & % Sales by Category (Pareto Analysis)

SELECT 
    category,
    SUM(total_amount) AS total_sales,
    ROUND(100.0 * SUM(total_amount) / SUM(SUM(total_amount)) OVER (), 2) AS percent_of_total_sales
FROM orders_360
WHERE category IS NOT NULL
GROUP BY category
ORDER BY total_sales DESC;

-- Insight: Helps identify top contributing categories — essential for inventory & marketing focus.
-------------------------------------------------------------

-- 2. Most Profitable Category and Its Contribution

SELECT 
    category,
    SUM(profit) AS total_profit,
    ROUND(100.0 * SUM(profit) / SUM(SUM(profit)) OVER (), 2) AS percent_of_total_profit
FROM orders_360
WHERE category IS NOT NULL
GROUP BY category
ORDER BY total_profit DESC;
-- Insight: High profit margin categories can be pushed in promotions to maximize profit.

-------------------------------------------------------------

-- 3. Category Penetration Month-on-Month
-- Category Penetration = Orders with this category / All Orders that month


WITH Orders_Category AS (
    SELECT DISTINCT Order_id, Order_month, Category
    FROM orders_360
),
Orders_Per_Category AS (
    SELECT 
        Order_month,
        Category,
        COUNT(DISTINCT Order_id) AS Orders_with_Category
    FROM Orders_Category
    GROUP BY Order_month, Category
),
Total_Orders_Per_Month AS (
    SELECT 
        Order_month,
        COUNT(DISTINCT order_id) AS Total_Orders
    FROM orders_360
    GROUP BY Order_month
)

SELECT 
    c.Order_month,
    c.Category,
    c.Orders_with_Category,
    t.Total_Orders,
    ROUND((c.Orders_with_Category * 1.0 / t.Total_Orders) * 100, 2) AS Category_Penetration_Percentage
FROM Orders_Per_Category c
JOIN Total_Orders_Per_Month t ON c.Order_month = t.Order_month
ORDER BY c.Order_month, Category;


-- Insight: Track rising/falling interest in specific categories
-------------------------------------------------------------

--  4. Cross-Category Analysis per Bill (Average number of categories shopped)

SELECT 
    FORMAT(CAST(bill_date_timestamp AS DATETIME), 'yyyy MMMM') AS order_month,
    s.region,
    s.seller_state,
    AVG(category_count) AS avg_categories_per_bill
FROM (
    SELECT order_id, COUNT(DISTINCT category) AS category_count
    FROM orders_360
    WHERE category IS NOT NULL
    GROUP BY order_id
) AS bill_data
JOIN orders_360 o ON o.order_id = bill_data.order_id
JOIN store_360 s ON s.store_id = o.store_id
GROUP BY FORMAT(CAST(bill_date_timestamp AS DATETIME), 'yyyy MMMM'), s.region, s.seller_state
ORDER BY order_month, s.region;


-- Insight: Helps in basket analysis and upselling.
-------------------------------------------------------------

-- 5. Most Popular Category in First Purchase of Each Customer


WITH first_orders AS (
    SELECT 
        customer_id,
        MIN(bill_date_timestamp) AS first_purchase_date
    FROM orders_360
    GROUP BY customer_id
),
first_order_categories AS (
    SELECT o.customer_id, o.category
    FROM orders_360 o
    JOIN first_orders f
        ON o.customer_id = f.customer_id AND o.bill_date_timestamp = f.first_purchase_date
    WHERE o.category IS NOT NULL
)
SELECT 
    category,
    COUNT(*) AS customer_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percent_of_first_time_buyers
FROM first_order_categories
GROUP BY category
ORDER BY customer_count DESC;

-- Insight: Shows entry-level categories attracting new users, great for onboarding & ads.



-------X-------------------X--------------------------X---------------------X----------------------X-----------------


---------X-----------------X------------------X------------------X---------------------X------------------------------
 -- 5. Customer Satisfaction Towards Category & Product
 ---------X-----------------X------------------X------------------X---------------------X------------------------------
-- Which categories (top 10) are maximum rated & minimum rated and average rating score? 
-- Average rating by location, store, product, category, month, etc.

-- TOP RATED CATEGORIES

SELECT TOP 10 
    category,
    ROUND(AVG(c.avg_rating), 2) AS avg_rating,
    COUNT(c.customer_id) AS rating_count
FROM customer_360 c
JOIN orders_360 o ON c.customer_id = o.customer_id
WHERE c.avg_rating IS NOT NULL AND category IS NOT NULL
GROUP BY category
ORDER BY avg_rating DESC;

-- Insight: Find top 10 highest-rated categories based on average review scores.

-- BOTTOM RATED CATEGORIES

SELECT TOP 10 
    category,
    ROUND(AVG(c.avg_rating), 2) AS avg_rating,
    COUNT(c.customer_id) AS rating_count
FROM customer_360 c
JOIN orders_360 o ON c.customer_id = o.customer_id
WHERE c.avg_rating IS NOT NULL AND category IS NOT NULL
GROUP BY category
ORDER BY avg_rating ASC;
-- Insight: Find bottom 10 lowest-rated categories based on average review scores

-- AVERAGE RATINGS BY STORES

SELECT 
    o.store_id,
    ROUND(AVG(c.avg_rating), 2) AS avg_store_rating,
    COUNT(DISTINCT c.customer_id) AS total_customers
FROM customer_360 c
JOIN orders_360 o ON c.customer_id = o.customer_id
WHERE c.avg_rating IS NOT NULL
GROUP BY o.store_id
ORDER BY avg_store_rating DESC;

-- Insight: Average rating by store (identify which stores have the happiest customers)

-- AVERAGE RATING BY PRODUCT

SELECT 
    o.product_id,
    ROUND(AVG(c.avg_rating), 2) AS avg_product_rating,
    COUNT(DISTINCT c.customer_id) AS total_customers
FROM customer_360 c
JOIN orders_360 o ON c.customer_id = o.customer_id
WHERE c.avg_rating IS NOT NULL AND o.product_id IS NOT NULL
GROUP BY o.product_id
ORDER BY avg_product_rating DESC;
-- Insight: Average rating by product (useful if product_id exists in order_360 table)

-- AVERAGE RATING BY CATEGORY

SELECT 
    category,
    ROUND(AVG(c.avg_rating), 2) AS avg_category_rating,
    COUNT(DISTINCT c.customer_id) AS total_customers
FROM customer_360 c
JOIN orders_360 o ON c.customer_id = o.customer_id
WHERE c.avg_rating IS NOT NULL AND category IS NOT NULL
GROUP BY category
ORDER BY avg_category_rating DESC;
-- Insight: Average rating by category

-- AVERAGE RATING BY MONTHS

SELECT 
    FORMAT(cast(o.bill_date_timestamp as datetime), 'yyyy MMMM') AS rating_month,
    ROUND(AVG(c.avg_rating), 2) AS avg_rating_month,
    COUNT(DISTINCT c.customer_id) AS total_customers
FROM customer_360 c
JOIN orders_360 o ON c.customer_id = o.customer_id
WHERE c.avg_rating IS NOT NULL AND o.bill_date_timestamp IS NOT NULL
GROUP BY FORMAT(cast(o.bill_date_timestamp as datetime), 'yyyy MMMM')
ORDER BY rating_month;
-- Insight: Average rating by month (customer satisfaction trend over time)


-----X--------------X--------------------X-------------------X------------------X-----------------------X--------
-- Sales Trends, Seasonality, and Pattern Analysis
-----------X------------X-----------------------X---------------------X------------------X-----------------------
----------------

--  Insight:
-- Understand how your sales fluctuate by time, identify peak/low months, optimize marketing by weekday/weekend patterns, and track seasonal behaviors for targeted campaigns.

-- ================================
-- 1. Sales Trend by Month with % Contribution
-- ================================
with monthly_sales AS (
    SELECT 
        DATENAME(MONTH, bill_date_timestamp) AS month_name,
        MONTH(bill_date_timestamp) AS month_num,
        SUM(total_amount) AS total_sales
    FROM orders_360
    GROUP BY DATENAME(MONTH, bill_date_timestamp),  MONTH(bill_date_timestamp)
)
SELECT 
    month_name,
    total_sales,
    ROUND(100.0 * total_sales / SUM(total_sales) OVER (), 2) AS contribution_percent
FROM monthly_sales
ORDER BY month_num;

-- Insight:
--  Shows which months had highest/lowest sales and their contribution to annual revenue.

-- ================================
-- 2. Sales Trend by Weekday vs Weekend
-- ================================
SELECT 
     IIF(DATENAME(WEEKDAY, bill_date_timestamp) IN ('Saturday', 'Sunday'), 'Weekend', 'Weekday') AS day_type,
    SUM(total_amount) AS total_sales,
	count(distinct order_id) ordercount,
    ROUND(100.0 * SUM(total_amount) / (SELECT SUM(total_amount) FROM orders_360), 2) AS contribution_percent
FROM orders_360
GROUP BY  IIF(DATENAME(WEEKDAY, bill_date_timestamp) IN ('Saturday', 'Sunday'), 'Weekend', 'Weekday');

-- Insight:
--  Compare sales on weekends vs. weekdays to align campaign/discount strategy.

-- ================================
-- 3. Sales by Day of Week
-- ================================
SELECT 
    DATENAME(WEEKDAY, bill_date_timestamp) AS day_name,
    SUM(total_amount) AS total_sales,
	count(distinct order_id) total_orders
FROM orders_360
GROUP BY DATENAME(WEEKDAY, bill_date_timestamp)
ORDER BY 
    CASE DATENAME(WEEKDAY, bill_date_timestamp)
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END;

-- Insight:
--  Identify best-performing weekdays; plan offers or operations accordingly.

-- ================================
--  4. Sales by Week Number (Week of the Year)
-- ================================
SELECT 
    DATEPART(WEEK, bill_date_timestamp) AS week_num,
    SUM(total_amount) AS total_sales,
	count(distinct order_id) 
FROM orders_360
GROUP BY DATEPART(WEEK, bill_date_timestamp)
ORDER BY week_num;

-- Insight:
--  Detect weekly spikes or dips in sales, useful for event or campaign timing.

-- ================================
--  5. Sales by Quarter
-- ================================
SELECT 
    DATEPART(QUARTER, bill_date_timestamp) quarter_num,
    SUM(total_amount) AS total_sales,
    ROUND(100.0 * SUM(total_amount) / (SELECT SUM(total_amount) FROM orders_360), 2) AS contribution_percent,
	count(distinct order_id) as orders
FROM orders_360
GROUP BY DATEPART(QUARTER, bill_date_timestamp)
ORDER BY quarter_num;

-- Insight:
--  Recognize quarterly trends — e.g. Q4 boost due to holidays or Q1 dip.

-- ====================
-- 6. Month wise sales
-- ====================

with monthly_sales AS (
    SELECT 
        DATENAME(MONTH, bill_date_timestamp) AS month_name,
        MONTH(bill_date_timestamp) AS month_num,
        SUM(total_amount) AS total_sales
    FROM orders_360
    GROUP BY DATENAME(MONTH, bill_date_timestamp),  MONTH(bill_date_timestamp)
)
SELECT 
    month_name,
    total_sales
FROM monthly_sales
ORDER BY month_num;

-- Insights : To see the monthly trends




--------X------------------X-------------------------------X----------------------X-------------------------------X--------------
--Acquistion Cohort Analysis(Retension Rate)
--------X------------------X-------------------------------X----------------------X-------------------------------X--------------


WITH First_Transaction AS (
    SELECT 
        customer_id,
        DATEFROMPARTS(YEAR(MIN(bill_date_timestamp)), MONTH(MIN(bill_date_timestamp)),1) AS cohort_month
    FROM orders_360
    GROUP BY customer_id
),
Customer_Activity AS (
    SELECT 
        o.customer_id,
        DATEFROMPARTS(YEAR(o.bill_date_timestamp), MONTH(o.bill_date_timestamp),1) AS activity_month,
        f.cohort_month
    FROM orders_360 o
    JOIN First_Transaction f
        ON o.customer_id = f.customer_id
),
Cohort_Indexed AS (
    SELECT 
        cohort_month,
        DATEDIFF(MONTH, cohort_month, activity_month) AS cohort_index,
        customer_id
    FROM Customer_Activity
),
CustomerCounts AS (
    SELECT
        cohort_month,
        cohort_index,
        COUNT(DISTINCT customer_id) AS customer_count
    FROM Cohort_Indexed
    GROUP BY cohort_month, cohort_index
),
CohortSize AS (
    SELECT
        cohort_month,
        MAX(CASE WHEN cohort_index = 0 THEN customer_count ELSE 0 END) AS cohort_size
    FROM CustomerCounts
    GROUP BY cohort_month
),
RetentionRate AS (
    SELECT
        c.cohort_month,
        c.cohort_index,
        c.customer_count,
        cs.cohort_size,
        ROUND(1.0 * c.customer_count * 100 / cs.cohort_size, 2) AS retention_percent
    FROM CustomerCounts c
    JOIN CohortSize cs
        ON c.cohort_month = cs.cohort_month
)
SELECT 
    FORMAT(cohort_month, 'MMM-yyyy') AS Cohort_Month,
    MAX(CASE WHEN cohort_index = 0 THEN CAST(customer_count AS VARCHAR) + ' (' + CAST(retention_percent AS VARCHAR) + '%)' END) AS Period_0,
    MAX(CASE WHEN cohort_index = 1 THEN CAST(customer_count AS VARCHAR) + ' (' + CAST(retention_percent AS VARCHAR) + '%)' END) AS Period_1,
    MAX(CASE WHEN cohort_index = 2 THEN CAST(customer_count AS VARCHAR) + ' (' + CAST(retention_percent AS VARCHAR) + '%)' END) AS Period_2,
    MAX(CASE WHEN cohort_index = 3 THEN CAST(customer_count AS VARCHAR) + ' (' + CAST(retention_percent AS VARCHAR) + '%)' END) AS Period_3,
    MAX(CASE WHEN cohort_index = 4 THEN CAST(customer_count AS VARCHAR) + ' (' + CAST(retention_percent AS VARCHAR) + '%)' END) AS Period_4,
    MAX(CASE WHEN cohort_index = 5 THEN CAST(customer_count AS VARCHAR) + ' (' + CAST(retention_percent AS VARCHAR) + '%)' END) AS Period_5
FROM RetentionRate
GROUP BY cohort_month, FORMAT(cohort_month, 'yyyy-MM')
ORDER BY  FORMAT(cohort_month, 'yyyy-MM');



---------X--------------X------------------------X-----------------------------X--------------------------X-------------------------
-- Behavour Based Cohort
----------X---------------------------X------------------------------X-------------------------------------------------------X-------


--1) Discount Seekers
WITH Customer_Type AS (
    SELECT 
        customer_id,
        CASE 
            WHEN SUM(discount) > 15 THEN 'Discount Seeker'
            ELSE 'Non Discount Seeker'
        END AS customer_type
    FROM orders_360
    GROUP BY customer_id
),
First_Transaction AS (
    SELECT 
        o.customer_id,
        DATEFROMPARTS(YEAR(MIN(o.bill_date_timestamp)), MONTH(MIN(o.bill_date_timestamp)), 1) AS cohort_month,
        ct.customer_type
    FROM orders_360 o
    JOIN Customer_Type ct ON o.customer_id = ct.customer_id
    GROUP BY o.customer_id, ct.customer_type
),
Customer_Month_Activity AS (
    SELECT 
        o.customer_id,
        DATEFROMPARTS(YEAR(o.bill_date_timestamp), MONTH(o.bill_date_timestamp), 1) AS activity_month,
        f.cohort_month,
        f.customer_type
    FROM orders_360 o
    JOIN First_Transaction f ON o.customer_id = f.customer_id
),
Cohort_Indexed AS (
    SELECT 
        cohort_month,
        customer_type,
        DATEDIFF(MONTH, cohort_month, activity_month) AS cohort_index,
        customer_id
    FROM Customer_Month_Activity
),
CustomerCounts AS (
    SELECT
        cohort_month,
        customer_type,
        cohort_index,
        COUNT(DISTINCT customer_id) AS customer_count
    FROM Cohort_Indexed
    GROUP BY cohort_month, customer_type, cohort_index
),
CohortSize AS (
    SELECT
        cohort_month,
        customer_type,
        MAX(CASE WHEN cohort_index = 0 THEN customer_count ELSE 0 END) AS cohort_size
    FROM CustomerCounts
    GROUP BY cohort_month, customer_type
),
RetentionRate AS (
    SELECT
        c.cohort_month,
        c.customer_type,
        c.cohort_index,
        c.customer_count,
        cs.cohort_size,
        ROUND(1.0 * c.customer_count * 100 / NULLIF(cs.cohort_size, 0), 2) AS retention_percent
    FROM CustomerCounts c
    JOIN CohortSize cs 
        ON c.cohort_month = cs.cohort_month AND c.customer_type = cs.customer_type
)
SELECT 
    FORMAT(cohort_month, 'MMM-yyyy') AS Cohort_Month,
    customer_type,
    MAX(CASE WHEN cohort_index = 0 THEN CAST(customer_count AS VARCHAR) + ' (' + CAST(retention_percent AS VARCHAR) + '%)' END) AS Period_0,
    MAX(CASE WHEN cohort_index = 1 THEN CAST(customer_count AS VARCHAR) + ' (' + CAST(retention_percent AS VARCHAR) + '%)' END) AS Period_1,
    MAX(CASE WHEN cohort_index = 2 THEN CAST(customer_count AS VARCHAR) + ' (' + CAST(retention_percent AS VARCHAR) + '%)' END) AS Period_2,
    MAX(CASE WHEN cohort_index = 3 THEN CAST(customer_count AS VARCHAR) + ' (' + CAST(retention_percent AS VARCHAR) + '%)' END) AS Period_3,
    MAX(CASE WHEN cohort_index = 4 THEN CAST(customer_count AS VARCHAR) + ' (' + CAST(retention_percent AS VARCHAR) + '%)' END) AS Period_4,
    MAX(CASE WHEN cohort_index = 5 THEN CAST(customer_count AS VARCHAR) + ' (' + CAST(retention_percent AS VARCHAR) + '%)' END) AS Period_5
FROM RetentionRate
where customer_type='Discount Seeker'
GROUP BY cohort_month, customer_type, FORMAT(cohort_month, 'yyyy-MM')
ORDER BY 
    CASE customer_type 
        WHEN 'Discount Seeker' THEN 1 
        WHEN 'Non Discount Seeker' THEN 2 
        ELSE 3 
    END,
    FORMAT(cohort_month, 'yyyy-MM');



-- 2)  Non Dsicount Seekers

WITH Customer_Type AS (
    SELECT 
        customer_id,
        CASE 
            WHEN SUM(discount) > 15 THEN 'Discount Seeker'
            ELSE 'Non Discount Seeker'
        END AS customer_type
    FROM orders_360
    GROUP BY customer_id
),
First_Transaction AS (
    SELECT 
        o.customer_id,
        DATEFROMPARTS(YEAR(MIN(o.bill_date_timestamp)), MONTH(MIN(o.bill_date_timestamp)), 1) AS cohort_month,
        ct.customer_type
    FROM orders_360 o
    JOIN Customer_Type ct ON o.customer_id = ct.customer_id
    GROUP BY o.customer_id, ct.customer_type
),
Customer_Month_Activity AS (
    SELECT 
        o.customer_id,
        DATEFROMPARTS(YEAR(o.bill_date_timestamp), MONTH(o.bill_date_timestamp), 1) AS activity_month,
        f.cohort_month,
        f.customer_type
    FROM orders_360 o
    JOIN First_Transaction f ON o.customer_id = f.customer_id
),
Cohort_Indexed AS (
    SELECT 
        cohort_month,
        customer_type,
        DATEDIFF(MONTH, cohort_month, activity_month) AS cohort_index,
        customer_id
    FROM Customer_Month_Activity
),
CustomerCounts AS (
    SELECT
        cohort_month,
        customer_type,
        cohort_index,
        COUNT(DISTINCT customer_id) AS customer_count
    FROM Cohort_Indexed
    GROUP BY cohort_month, customer_type, cohort_index
),
CohortSize AS (
    SELECT
        cohort_month,
        customer_type,
        MAX(CASE WHEN cohort_index = 0 THEN customer_count ELSE 0 END) AS cohort_size
    FROM CustomerCounts
    GROUP BY cohort_month, customer_type
),
RetentionRate AS (
    SELECT
        c.cohort_month,
        c.customer_type,
        c.cohort_index,
        c.customer_count,
        cs.cohort_size,
        ROUND(1.0 * c.customer_count * 100 / NULLIF(cs.cohort_size, 0), 2) AS retention_percent
    FROM CustomerCounts c
    JOIN CohortSize cs 
        ON c.cohort_month = cs.cohort_month AND c.customer_type = cs.customer_type
)
SELECT 
    FORMAT(cohort_month, 'MMM-yyyy') AS Cohort_Month,
    customer_type,
    MAX(CASE WHEN cohort_index = 0 THEN CAST(customer_count AS VARCHAR) + ' (' + CAST(retention_percent AS VARCHAR) + '%)' END) AS Period_0,
    MAX(CASE WHEN cohort_index = 1 THEN CAST(customer_count AS VARCHAR) + ' (' + CAST(retention_percent AS VARCHAR) + '%)' END) AS Period_1,
    MAX(CASE WHEN cohort_index = 2 THEN CAST(customer_count AS VARCHAR) + ' (' + CAST(retention_percent AS VARCHAR) + '%)' END) AS Period_2,
    MAX(CASE WHEN cohort_index = 3 THEN CAST(customer_count AS VARCHAR) + ' (' + CAST(retention_percent AS VARCHAR) + '%)' END) AS Period_3,
    MAX(CASE WHEN cohort_index = 4 THEN CAST(customer_count AS VARCHAR) + ' (' + CAST(retention_percent AS VARCHAR) + '%)' END) AS Period_4,
    MAX(CASE WHEN cohort_index = 5 THEN CAST(customer_count AS VARCHAR) + ' (' + CAST(retention_percent AS VARCHAR) + '%)' END) AS Period_5
FROM RetentionRate
where customer_type='Non Discount Seeker'
GROUP BY cohort_month, customer_type, FORMAT(cohort_month, 'yyyy-MM')
ORDER BY 
    CASE customer_type 
        WHEN 'Discount Seeker' THEN 1 
        WHEN 'Non Discount Seeker' THEN 2 
        ELSE 3 
    END,
    FORMAT(cohort_month, 'yyyy-MM');


---------X--------------X------------------------X-----------------------------X--------------------------X-------------------------
-- Segment Based Cohort
----------X---------------------------X------------------------------X-------------------------------------------------------X-------

--1) State Wise Repeat Purchse Behaviour

WITH First_Transaction AS (
    SELECT 
        o.customer_id,
        c.customer_state,
        DATEFROMPARTS(YEAR(MIN(o.bill_date_timestamp)), MONTH(MIN(o.bill_date_timestamp)), 1) AS cohort_month
    FROM orders_360 o
	join customer_360 c 
	on c.customer_id=o.customer_id
    GROUP BY o.customer_id, c.customer_state
),
Customer_Month_Activity AS (
    SELECT 
        o.customer_id,
        f.customer_state,
        DATEFROMPARTS(YEAR(o.bill_date_timestamp), MONTH(o.bill_date_timestamp), 1) AS activity_month,
        f.cohort_month
    FROM orders_360 o
    JOIN First_Transaction f
        ON o.customer_id = f.customer_id
),
Cohort_Indexed AS (
    SELECT 
        customer_state,
        cohort_month,
        DATEDIFF(MONTH, cohort_month, activity_month) AS cohort_index,
        customer_id
    FROM Customer_Month_Activity
),
CustomerCounts AS (
    SELECT
        customer_state,
        cohort_month,
        cohort_index,
        COUNT(DISTINCT customer_id) AS customer_count
    FROM Cohort_Indexed
    GROUP BY customer_state, cohort_month, cohort_index
),
CohortSize AS (
    SELECT
        customer_state,
        cohort_month,
        MAX(CASE WHEN cohort_index = 0 THEN customer_count ELSE 0 END) AS cohort_size
    FROM CustomerCounts
    GROUP BY customer_state, cohort_month
),
RetentionRate AS (
    SELECT
        c.customer_state,
        c.cohort_month,
        c.cohort_index,
        c.customer_count,
        cs.cohort_size,
        ROUND(1.0 * c.customer_count * 100 / NULLIF(cs.cohort_size, 0), 2) AS retention_percent
    FROM CustomerCounts c
    JOIN CohortSize cs
        ON c.customer_state = cs.customer_state AND c.cohort_month = cs.cohort_month
)
SELECT 
    customer_state AS [State],
    FORMAT(cohort_month, 'MMM-yyyy') AS [Cohort_Month],
    MAX(CASE WHEN cohort_index = 0 THEN CAST(customer_count AS VARCHAR) + ' (' + CAST(retention_percent AS VARCHAR) + '%)' END) AS Period_0,
    MAX(CASE WHEN cohort_index = 1 THEN CAST(customer_count AS VARCHAR) + ' (' + CAST(retention_percent AS VARCHAR) + '%)' END) AS Period_1,
    MAX(CASE WHEN cohort_index = 2 THEN CAST(customer_count AS VARCHAR) + ' (' + CAST(retention_percent AS VARCHAR) + '%)' END) AS Period_2,
    MAX(CASE WHEN cohort_index = 3 THEN CAST(customer_count AS VARCHAR) + ' (' + CAST(retention_percent AS VARCHAR) + '%)' END) AS Period_3,
    MAX(CASE WHEN cohort_index = 4 THEN CAST(customer_count AS VARCHAR) + ' (' + CAST(retention_percent AS VARCHAR) + '%)' END) AS Period_4,
    MAX(CASE WHEN cohort_index = 5 THEN CAST(customer_count AS VARCHAR) + ' (' + CAST(retention_percent AS VARCHAR) + '%)' END) AS Period_5
FROM RetentionRate
GROUP BY customer_state, cohort_month, FORMAT(cohort_month, 'yyyy-MM')
ORDER BY customer_state, FORMAT(cohort_month, 'yyyy-MM');


-- 2) REGION WISE REPEAT SELLEING BEHAVIOUR

WITH First_Transaction AS (
    SELECT 
        o.customer_id,
        S.region,
        DATEFROMPARTS(YEAR(MIN(o.bill_date_timestamp)), MONTH(MIN(o.bill_date_timestamp)), 1) AS cohort_month
    FROM orders_360 o
	join customer_360 c 
	on c.customer_id=o.customer_id
	JOIN store_360 S
	ON S.store_id=O.store_id
    GROUP BY o.customer_id, S.region
),
Customer_Month_Activity AS (
    SELECT 
        o.customer_id,
        f.region,
        DATEFROMPARTS(YEAR(o.bill_date_timestamp), MONTH(o.bill_date_timestamp), 1) AS activity_month,
        f.cohort_month
    FROM orders_360 o
    JOIN First_Transaction f
        ON o.customer_id = f.customer_id
),
Cohort_Indexed AS (
    SELECT 
        region,
        cohort_month,
        DATEDIFF(MONTH, cohort_month, activity_month) AS cohort_index,
        customer_id
    FROM Customer_Month_Activity
),
CustomerCounts AS (
    SELECT
        region,
        cohort_month,
        cohort_index,
        COUNT(DISTINCT customer_id) AS customer_count
    FROM Cohort_Indexed
    GROUP BY region, cohort_month, cohort_index
),
CohortSize AS (
    SELECT
        region,
        cohort_month,
        MAX(CASE WHEN cohort_index = 0 THEN customer_count ELSE 0 END) AS cohort_size
    FROM CustomerCounts
    GROUP BY region, cohort_month
),
RetentionRate AS (
    SELECT
        c.region,
        c.cohort_month,
        c.cohort_index,
        c.customer_count,
        cs.cohort_size,
        ROUND(1.0 * c.customer_count * 100 / NULLIF(cs.cohort_size, 0), 2) AS retention_percent
    FROM CustomerCounts c
    JOIN CohortSize cs
        ON c.region = cs.region AND c.cohort_month = cs.cohort_month
)
SELECT 
    region AS [Region],
    FORMAT(cohort_month, 'MMM-yyyy') AS [Cohort_Month],
    MAX(CASE WHEN cohort_index = 0 THEN CAST(customer_count AS VARCHAR) + ' (' + CAST(retention_percent AS VARCHAR) + '%)' END) AS Period_0,
    MAX(CASE WHEN cohort_index = 1 THEN CAST(customer_count AS VARCHAR) + ' (' + CAST(retention_percent AS VARCHAR) + '%)' END) AS Period_1,
    MAX(CASE WHEN cohort_index = 2 THEN CAST(customer_count AS VARCHAR) + ' (' + CAST(retention_percent AS VARCHAR) + '%)' END) AS Period_2,
    MAX(CASE WHEN cohort_index = 3 THEN CAST(customer_count AS VARCHAR) + ' (' + CAST(retention_percent AS VARCHAR) + '%)' END) AS Period_3,
    MAX(CASE WHEN cohort_index = 4 THEN CAST(customer_count AS VARCHAR) + ' (' + CAST(retention_percent AS VARCHAR) + '%)' END) AS Period_4,
    MAX(CASE WHEN cohort_index = 5 THEN CAST(customer_count AS VARCHAR) + ' (' + CAST(retention_percent AS VARCHAR) + '%)' END) AS Period_5
FROM RetentionRate
GROUP BY region, cohort_month, FORMAT(cohort_month, 'yyyy-MM')
ORDER BY region, FORMAT(cohort_month, 'yyyy-MM');





------X----------X---------------X-------------------X-------------------X---------------------------------X---------
-- Monetory Based Cohort 
------X----------X---------------X-------------------X-------------------X---------------------------------X---------

-- Step 1: Create cohort month calendar from Sep 2021 to Oct 2023
WITH Month_Calendar AS (
    SELECT DATEFROMPARTS(2021, 9, 1) AS cohort_month
    UNION ALL
    SELECT DATEADD(MONTH, 1, cohort_month)
    FROM Month_Calendar
    WHERE cohort_month < '2023-10-01'
),

-- Step 2: Define spend groups
Spend_Groups AS (
    SELECT '0-999' AS spend_group
    UNION ALL SELECT '1000-4999'
    UNION ALL SELECT '5000+'
),

-- Step 3: All possible combinations of spend group and cohort month
Group_Month_Base AS (
    SELECT sg.spend_group, mc.cohort_month
    FROM Spend_Groups sg
    CROSS JOIN Month_Calendar mc
),

-- Step 4: Get each customer's initial spend and cohort month
First_Transaction AS (
    SELECT 
        customer_id,
        SUM(paid_amount) AS initial_spend,
        DATEFROMPARTS(YEAR(MIN(bill_date_timestamp)), MONTH(MIN(bill_date_timestamp)), 1) AS cohort_month
    FROM orders_360
    GROUP BY customer_id
),

Spend_Grouped_Customers AS (
    SELECT 
        customer_id,
        cohort_month,
        CASE 
            WHEN initial_spend < 1000 THEN '0-999'
            WHEN initial_spend BETWEEN 1000 AND 4999 THEN '1000-4999'
            ELSE '5000+'
        END AS spend_group
    FROM First_Transaction
),

-- Step 5: Map each customer to all months they were active
Customer_Month_Activity AS (
    SELECT 
        o.customer_id,
        sgc.spend_group,
        DATEFROMPARTS(YEAR(o.bill_date_timestamp), MONTH(o.bill_date_timestamp), 1) AS activity_month,
        sgc.cohort_month
    FROM orders_360 o
    JOIN Spend_Grouped_Customers sgc ON o.customer_id = sgc.customer_id
),

-- Step 6: Compute month offset for each customer
Cohort_Indexed AS (
    SELECT 
        spend_group,
        cohort_month,
        DATEDIFF(MONTH, cohort_month, activity_month) AS cohort_index,
        customer_id
    FROM Customer_Month_Activity
    WHERE DATEDIFF(MONTH, cohort_month, activity_month) BETWEEN 0 AND 5
),

-- Step 7a: Count customers in each group + month + index
Customer_Counts AS (
    SELECT 
        spend_group,
        cohort_month,
        cohort_index,
        COUNT(DISTINCT customer_id) AS customer_count
    FROM Cohort_Indexed
    GROUP BY spend_group, cohort_month, cohort_index
),

-- Step 7b: Get cohort sizes (P0 count)
Cohort_Sizes AS (
    SELECT 
        spend_group,
        cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_size
    FROM Cohort_Indexed
    WHERE cohort_index = 0
    GROUP BY spend_group, cohort_month
),

-- Step 7c: Join counts to sizes to compute %s
Customer_Percentages AS (
    SELECT 
        cc.spend_group,
        cc.cohort_month,
        cc.cohort_index,
        NULLIF(ROUND(1.0 * cc.customer_count * 100.0 / NULLIF(cs.cohort_size, 0), 2), 0.00) AS retention_percent
    FROM Customer_Counts cc
    JOIN Cohort_Sizes cs 
        ON cc.spend_group = cs.spend_group AND cc.cohort_month = cs.cohort_month
),

-- Step 8: Final pivot output with NULLs for 0%
Final_Output AS (
    SELECT 
        gm.spend_group,
        FORMAT(gm.cohort_month, 'MMM-yyyy') AS Cohort_Month,
        MAX(CASE WHEN cp.cohort_index = 0 THEN cast(cp.retention_percent as varchar) + '%' END) AS P0,
        MAX(CASE WHEN cp.cohort_index = 1 THEN cast(cp.retention_percent as varchar) + '%' END) AS P1,
        MAX(CASE WHEN cp.cohort_index = 2 THEN cast(cp.retention_percent as varchar)+ '%' END) AS P2,
        MAX(CASE WHEN cp.cohort_index = 3 THEN cast(cp.retention_percent as varchar) + '%' END) AS P3,
        MAX(CASE WHEN cp.cohort_index = 4 THEN cast(cp.retention_percent as varchar) + '%' END) AS P4,
        MAX(CASE WHEN cp.cohort_index = 5 THEN cast(cp.retention_percent as varchar) + '%' END) AS P5
    FROM Group_Month_Base gm
    LEFT JOIN Customer_Percentages cp 
        ON gm.spend_group = cp.spend_group AND gm.cohort_month = cp.cohort_month
    GROUP BY gm.spend_group, gm.cohort_month
)

-- Step 9: Order by spend group then cohort month
SELECT *
FROM Final_Output
ORDER BY 
    CASE spend_group 
        WHEN '0-999' THEN 1
        WHEN '1000-4999' THEN 2
        WHEN '5000+' THEN 3
    END,
    TRY_CAST('01-' + Cohort_Month AS DATE)
OPTION (MAXRECURSION 1000);

