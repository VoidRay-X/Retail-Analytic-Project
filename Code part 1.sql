use Intership

select top 2 *from Customers$

select top 2 * from OrderPayments$

select top 2 *  from OrderReview_Ratings$

select top 2 * from Orders$

select top 2 * from ProductsInfo$

select top 2 * from StoresInfo$


-------------------------------- Check data types--------------------------------------
-----Customers
select column_name, DATA_type from  INFORMATION_SCHEMA.COLUMNS
where table_name = 'Customers$'

---orderpayments
select column_name, Data_type from INFORMATION_SCHEMA.COLUMNS
where table_name='OrderPayments$'

-----OrderReview_Ratings$
select column_name, Data_type from INFORMATION_SCHEMA.COLUMNS
where table_name='OrderReview_Ratings$'

 -----Orders$
select column_name, Data_type from INFORMATION_SCHEMA.COLUMNS
where table_name='Orders$'

 ----ProductsInfo$
select column_name, Data_type from INFORMATION_SCHEMA.COLUMNS
where table_name='ProductsInfo$'

 -----['Stores Info$']
select column_name, Data_type from INFORMATION_SCHEMA.COLUMNS
where table_name='StoresInfo$'

------------------------------------------------------------------------------------------------------------




/* To find if a single order id have multiple payment type*/

select order_id, count(payment_type) as pay_type_no from OrderPayments$
group by order_id
order by pay_type_no desc

/* to find if a single customer have multiple order id */

select Customer_id, count(order_id) as orderid_count from Orders$
group by Customer_id
order by orderid_count desc

/* to find if a single order id have multiple product id */

select order_id, count(product_id) as pro_count from Orders$
group by order_id
order by pro_count desc

---checking if a single order id is used for mutiple customers

SELECT order_id, count(DISTINCT Customer_id) as [different customers]
FROM Orders$
GROUP BY order_id
HAVING COUNT(DISTINCT Customer_id) > 1;



-------------------------Rough----------

select Gender, count(distinct Custid) from Customers$
group by Gender

select  * from Orders$

select distinct Custid from Customers$

select distinct product_id  from ProductsInfo$

select StoreID from StoresInfo$
group by StoreID
having count(StoreID)>1

select  count(order_id)-count(distinct order_id) as difference from OrderPayments$

select distinct * from OrderReview_Ratings$

select * from Orders$

SELECT order_id, product_id, COUNT(DISTINCT Quantity) AS different_quantity_count
FROM Orders$
GROUP BY order_id, product_id
HAVING COUNT(DISTINCT Quantity) > 1
order by different_quantity_count desc

SELECT * from Orders$
where order_id='4d2c3fb1909604d5f9474e4675971ef2'


SELECT order_id, 
       COUNT(DISTINCT Delivered_StoreID) AS store_count
FROM Orders$
GROUP BY order_id
HAVING COUNT(DISTINCT Delivered_StoreID) > 1
order by store_count desc


select order_id, count(distinct Delivered_StoreID) as store_count from Orders$
group by order_id
having count(distinct Delivered_StoreID)>1

select * from Orders$
where order_id='002f98c0f7efd42638ed6100ca699b42'


SELECT order_id, Bill_date_timestamp
FROM Orders$
WHERE TRY_CAST(Bill_date_timestamp AS DATETIME) IS NULL;

SELECT order_id, CONVERT(DATETIME, Bill_date_timestamp, 101) AS CleanDateTime
FROM Orders$

select order_id, count(distinct convert(datetime2, Bill_date_timestamp, 101)) as Date_No from Orders$
group by order_id
having count(distinct convert(datetime2, Bill_date_timestamp, 101))>1


select * from Orders$
where order_id='02e405aa2667a116637cdb4affaf93c0'

select order_id, count(order_id) from Orders$
where [Cost Per Unit]=MRP
group by order_id

select * from Orders$
where order_id='00404fa7a687c8c44ca69d42695aae73'

select order_id, count(order_id) from Orders$
where ([Cost Per Unit]* Quantity) - Discount> [Total Amount]
group by order_id

select product_id, count(distinct MRP) from Orders$
group by product_id
having count(distinct MRP)>1

select * from Orders$
where product_id='00126f27c813603687e6ce486d909d01'

-- Orders in Orders$ but not in OrderPayment$
SELECT order_id FROM Orders$
EXCEPT
SELECT order_id FROM OrderPayments$;

-- Orders in OrderPayment$ but not in Orders$
SELECT order_id FROM OrderPayments$
EXCEPT
SELECT order_id FROM Orders$;

-- Orders in Order review rating that are not in orders

select distinct order_id from OrderReview_Ratings$
EXCEPT
select distinct order_id from Orders$

-- Step 1: Sum Total_Amount from Orders$ grouped by order_id
-- Step 2: Sum Payment_Amount from OrderPayment$ grouped by order_id
-- Step 3: Join and compare both
SELECT 
    o.order_id,
    o.total_order_amount,
    p.total_payment_amount,
    ROUND(o.total_order_amount - p.total_payment_amount, 2) AS difference
FROM (
    SELECT order_id, SUM([Total Amount]) AS total_order_amount
    FROM Orders$
    GROUP BY order_id
) o
LEFT JOIN (
    SELECT order_id, SUM(payment_value) AS total_payment_amount
    FROM OrderPayments$
    GROUP BY order_id
) p ON o.order_id = p.order_id
WHERE ABS(o.total_order_amount - p.total_payment_amount) > 0.01

select * from Orders$
where order_id='00143d0f86d6fbd9f9b38ab440ac16f5'

select * from OrderPayments$
where order_id='00143d0f86d6fbd9f9b38ab440ac16f5'



select distinct customer_state from Customers$
Except
select distinct seller_state from StoresInfo$


select order_id, count(order_id) from OrderPayments$
group by order_id
having count(order_id)>1
order by count(order_id) desc

select * from OrderPayments$
where order_id='0016dfedd97fc2950e388d2971d718c7'

SELECT *
FROM ProductsInfo$
WHERE Category ='#N/A' 

select order_id, count(distinct Customer_Satisfaction_Score) as sat_count from OrderReview_Ratings$
group by order_id
having count(distinct Customer_Satisfaction_Score)>1
order by sat_count desc

select distinct * from OrderReview_Ratings$
where  order_id='013056cfe49763c6f66bda03396c5ee3'

select distinct Category from ProductsInfo$
group by Category

SELECT * FROM ProductsInfo$
WHERE Category ='#N/A'


-- Show total sum of Total Amount and Net Amount
SELECT 
    SUM([Total Amount]) AS Total_order_amount,
    SUM((MRP - Discount) * Quantity) AS Total_net_amount
FROM Orders$
WHERE order_id = '00143d0f86d6fbd9f9b38ab440ac16f5';

-- Show Payment value for that order
SELECT 
    order_id,
    payment_type,
    payment_value
FROM OrderPayments$
WHERE order_id = '00143d0f86d6fbd9f9b38ab440ac16f5';

SELECT * FROM Orders$
WHERE order_id = '4677e6e3e54b79b7ae98dede52d8f2b0';

select * from OrderPayments$
where order_id='4677e6e3e54b79b7ae98dede52d8f2b0'

-------- for different product id

SELECT *, MRP-Discount as [Net Amount] FROM Orders$
WHERE order_id = '00bcee890eba57a9767c7b5ca12d3a1b';

select * from OrderPayments$
where order_id='00bcee890eba57a9767c7b5ca12d3a1b'

select distinct * from OrderReview_Ratings$



select max(Quantity), min(Quantity), max(Discount), min(Discount) from Orders$

select distinct * from OrderPayments$
where order_id='4b09fc170c84e10e4caeff4d880db358'

select distinct * from Orders$
where order_id='4b09fc170c84e10e4caeff4d880db358'

select distinct * from OrderPayments$
order by payment_value 



select distinct Customer_id, order_id from Orders$
group by order_id, Customer_id
having count(order_id) >1


SELECT order_id, count(DISTINCT Customer_id) as [different customers]
FROM Orders$
GROUP BY order_id
HAVING COUNT(DISTINCT Customer_id) > 1;


select * from Orders$
where order_id='001d8f0e34a38c37f7dba2a37d4eba8b'

select * from OrderPayments$
where order_id='001d8f0e34a38c37f7dba2a37d4eba8b'




-------analysis part 

-----------------------naming correct--------------------------


select 
	Custid as customer_id, customer_city, customer_state, Gender as gender
	into customers_clean
from Customers$

select StoreID as store_id, seller_city, seller_state, Region as region
	into stores_info_clean
from StoresInfo$

select product_id, Category as category, product_name_lenght, product_description_lenght,product_photos_qty, product_weight_g,
	product_length_cm, product_height_cm, product_width_cm 
into products_info_clean
from ProductsInfo$

select * into order_payments_clean from OrderPayments$

select order_id, Customer_Satisfaction_Score as customer_satisfaction_score
into order_review_ratings_clean
from OrderReview_Ratings$

select Customer_id as customer_id, order_id, product_id, Channel as channel, Delivered_StoreID as store_id, 
Bill_date_timestamp as bill_date_timestamp, Quantity as quantity, [Cost Per Unit] as cost_per_unit, MRP as mrp, Discount as discount,
[Total Amount] as total_amount
into orders_clean
from Orders$

-----------checking

select * from products_info_clean

select * from orders_clean

select * from order_review_ratings_clean





----------------- cleaning of duplicate


------ store
---- duplicate

WITH duplicate AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY store_id, seller_city, seller_state, region
			   order by store_id
           ) AS rn
    FROM stores_info_clean
)
DELETE FROM duplicate
WHERE rn > 1;

select * from stores_info_clean

--------------orders payment 
---payment value =0

delete from order_payments_clean
where payment_value is null or payment_value =0

select * from order_payments_clean

--- duplicated rows delete

WITH dup AS( 
	select *,
		ROW_NUMBER() over (
					PARTITION BY order_id, payment_type, payment_value
						order by order_id) as rn
from order_payments_clean)
DELETE from dup
where rn>1

select * from order_payments_clean




------order review ratings 
----removig duplicated rows

WITH dupp AS(
select  *, ROW_NUMBER() OVER(
			PARTITION BY order_id, customer_satisfaction_score
				order by order_id) as rn
from order_review_ratings_clean) 
DELETE from dupp
where rn>1

select * from order_review_ratings_clean

---- one order id 2 different rating , now mean it

-- Step 1: Create temp table and insert average ratings
SELECT 
    order_id,
    AVG(customer_satisfaction_score) AS avg_score
INTO #avg_ratings
FROM order_review_ratings_clean
GROUP BY order_id;

-- Step 2: Clear old table
DELETE FROM order_review_ratings_clean;

-- Step 3: Insert back averaged scores
INSERT INTO order_review_ratings_clean (order_id, customer_satisfaction_score)
SELECT order_id, avg_score
FROM #avg_ratings;

-- Step 4: Drop the temp table
DROP TABLE #avg_ratings;

select * from order_review_ratings_clean


--------------------- customers

-- DELETE CUSTOMERS WHO ARE IN CUSTOMERS BUT NOT IN ORDERS TABLE

DELETE FROM customers_clean
WHERE customer_id IN (
    SELECT customer_id 
    FROM customers_clean
    EXCEPT
    SELECT customer_id 
    FROM orders_clean
);

------------- PRODUCT 
---DELETEING ALL THE ROWS WHERE CATEGORY IS #N/A

SELECT category, COUNT(category) FROM products_info_clean
GROUP BY category

UPDATE products_info_clean
SET category = 'Unknown'
WHERE category = '#N/A';

SELECT * FROM products_info_clean

--------------------------------------- ORDERS

SELECT * FROM orders_clean

-- Step 1: Update the column to proper DATETIME
UPDATE orders_clean
SET bill_date_timestamp = TRY_CONVERT(DATETIME, bill_date_timestamp)
WHERE ISDATE(bill_date_timestamp) = 1;

--deleting rows which are outside of the range

DELETE FROM orders_clean
WHERE bill_date_timestamp NOT BETWEEN 
    CAST('2021-09-01' AS DATETIME) AND 
    CAST('2023-10-31' AS DATETIME);

---------checking if a order id has differnt date
--checking
SELECT order_id,
       COUNT(DISTINCT bill_date_timestamp) AS different_dates
FROM orders_clean
GROUP BY order_id
HAVING COUNT(DISTINCT bill_date_timestamp) > 1;

-- Step 1: Get latest date for each order_id
WITH latest_dates AS (
    SELECT order_id, MAX(bill_date_timestamp) AS latest_date
    FROM orders_clean
    GROUP BY order_id
)

-- Step 2: Update all rows to the latest date per order_id
UPDATE o
SET o.bill_date_timestamp = l.latest_date
FROM orders_clean o
JOIN latest_dates l ON o.order_id = l.order_id;



-------------------------- deleting the rows , same order id for mutliple customers id
--checking the order id for multiple customers

SELECT order_id
FROM orders_clean
GROUP BY order_id
HAVING COUNT(DISTINCT customer_id) > 1;

-- whoes total amount in order id is not matiching with the payment value in payment table

SELECT 
    o.order_id, 
    o.customer_id, 
    ROUND(o.total_amount, 2) AS total_amount, 
    ROUND(p.payment_value, 2) AS payment_value
FROM orders_clean o
JOIN order_payments_clean p ON o.order_id = p.order_id
WHERE o.order_id IN (
    SELECT order_id
    FROM orders_clean
    GROUP BY order_id
    HAVING COUNT(DISTINCT customer_id) > 1
)
AND ROUND(o.total_amount, 2) != ROUND(p.payment_value, 2);

-- now deleting such rows

DELETE o
FROM orders_clean o
JOIN order_payments_clean p ON o.order_id = p.order_id
WHERE o.order_id IN (
    SELECT order_id
    FROM orders_clean
    GROUP BY order_id
    HAVING COUNT(DISTINCT customer_id) > 1
)
AND ROUND(o.total_amount, 2) != ROUND(p.payment_value, 2);

--------------- now i am gonna delete, order id and product id same only quantity different , highest quaitty keep , rest delete

--- checking such rows
WITH ranked_orders AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY order_id, product_id
               ORDER BY quantity DESC
           ) AS rn
    FROM orders_clean
)
DELETE o
FROM orders_clean o
JOIN ranked_orders r
    ON o.order_id = r.order_id
   AND o.product_id = r.product_id
   AND o.quantity = r.quantity  -- to target the exact duplicate row
WHERE r.rn > 1;



-- gonna clean, order id with different product id total amount sum not match with that order id total amount with payment

WITH order_totals AS (
    SELECT order_id, ROUND(SUM(total_amount), 2) AS order_total
    FROM orders_clean
    GROUP BY order_id
),
payment_totals AS (
    SELECT order_id, ROUND(SUM(payment_value), 2) AS payment_total
    FROM order_payments_clean
    GROUP BY order_id
)

SELECT 
    o.order_id,
    o.order_total,
    p.payment_total
FROM order_totals o
JOIN payment_totals p ON o.order_id = p.order_id
WHERE o.order_total != p.payment_total;



-- Step 1: Aggregate order and payment values separately
WITH order_totals AS (
    SELECT order_id, ROUND(SUM(total_amount), 2) AS order_total
    FROM orders_clean
    GROUP BY order_id
),
payment_totals AS (
    SELECT order_id, ROUND(SUM(payment_value), 2) AS payment_total
    FROM order_payments_clean
    GROUP BY order_id
),

-- Step 2: Find mismatched order IDs
mismatched_orders AS (
    SELECT o.order_id
    FROM order_totals o
    JOIN payment_totals p ON o.order_id = p.order_id
    WHERE o.order_total != p.payment_total
)

-- Step 3: Build corrected table
SELECT 
    o.customer_id,
    o.order_id,
    o.product_id,
    o.channel,
    o.store_id,
    o.bill_date_timestamp,
    o.cost_per_unit,
    o.mrp,
    o.discount,

    -- Adjusted quantity only for mismatched orders
    CASE 
        WHEN m.order_id IS NOT NULL THEN 1
        ELSE o.quantity
    END AS quantity,

    -- Adjusted total_amount only for mismatched orders
    CASE 
        WHEN m.order_id IS NOT NULL THEN ROUND((o.mrp - o.discount) * 1, 2)
        ELSE ROUND(o.total_amount, 2)
    END AS total_amount

INTO orders_clean_temp
FROM orders_clean o
LEFT JOIN mismatched_orders m ON o.order_id = m.order_id;

-- Step 4: Replace original data
DELETE FROM orders_clean;

INSERT INTO orders_clean (
    customer_id, order_id, product_id, channel, store_id, bill_date_timestamp,
    cost_per_unit, mrp, discount, quantity, total_amount
)
SELECT 
    customer_id, order_id, product_id, channel, store_id, bill_date_timestamp,
    cost_per_unit, mrp, discount, quantity, total_amount
FROM orders_clean_temp;

-- Step 5: Drop the temp table
DROP TABLE orders_clean_temp;



-- now i am gonna drop order id whose sum of total amount doesnt match with the sum of payment value
-- Step 1: Identify mismatched order IDs
WITH order_totals AS (
    SELECT order_id, ROUND(SUM(total_amount), 2) AS order_total
    FROM orders_clean
    GROUP BY order_id
),
payment_totals AS (
    SELECT order_id, ROUND(SUM(payment_value), 2) AS payment_total
    FROM order_payments_clean
    GROUP BY order_id
),
mismatched_orders AS (
    SELECT o.order_id
    FROM order_totals o
    JOIN payment_totals p ON o.order_id = p.order_id
    WHERE o.order_total != p.payment_total
)

-- Step 2: Delete all rows from orders_clean with those order_ids
DELETE FROM orders_clean
WHERE order_id IN (SELECT order_id FROM mismatched_orders);



------deleting order id of orders table which are not in payment table

DELETE FROM orders_clean
WHERE order_id NOT IN (
    SELECT DISTINCT order_id FROM order_payments_clean
);


------------ checking for same order id but differnt store id where channel is instore

SELECT order_id
FROM orders_clean
WHERE channel = 'Instore'
GROUP BY order_id
HAVING COUNT(DISTINCT store_id) > 1;

-- Step 1: Get the preferred store_id for each order_id (instore only)
WITH ranked_stores AS (
    SELECT 
        order_id, 
        store_id,
        SUM(total_amount) AS total_amt,
        RANK() OVER (
            PARTITION BY order_id 
            ORDER BY 
                SUM(total_amount) DESC,
                MIN(store_id) ASC  -- Tie breaker: smaller store_id
        ) AS rk
    FROM orders_clean
    WHERE channel = 'Instore'
    GROUP BY order_id, store_id
),
preferred_store AS (
    SELECT order_id, store_id
    FROM ranked_stores
    WHERE rk = 1
)

-- Step 2: Update instore rows to use preferred store_id
UPDATE o
SET store_id = p.store_id
FROM orders_clean o
JOIN preferred_store p
    ON o.order_id = p.order_id
WHERE o.channel = 'Instore';

select * from orders_clean
where order_id='002f98c0f7efd42638ed6100ca699b42'

select * from order_payments_clean
where order_id='4cf18bf9d25331902ba212fa69a7a01d'

----------------------payment 

--- gonna delete where order id is not present in orders
DELETE FROM order_payments_clean
WHERE order_id NOT IN (
    SELECT DISTINCT order_id FROM orders_clean )


------------review 

-- gonna delete where order id is not present in orders

DELETE FROM order_review_ratings_clean
WHERE order_id NOT IN (
	SELECT DISTINCT order_id FROM orders_clean)

SELECT channel, COUNT(channel) FROM orders_clean
GROUP BY channel

--------- payment new column addition of payment mode 

-- Creates a virtual table (view), no change to your original data

CREATE VIEW order_payments_clean_v AS
SELECT
    order_id,

    -- One column per payment type using CASE WHEN
    SUM(CASE WHEN payment_type = 'credit_card' THEN payment_value ELSE 0 END) AS credit_card,
    SUM(CASE WHEN payment_type = 'UPI/Cash' THEN payment_value ELSE 0 END) AS upi_cash,
    SUM(CASE WHEN payment_type = 'debit_card' THEN payment_value ELSE 0 END) AS debit_card,
    SUM(CASE WHEN payment_type = 'voucher' THEN payment_value ELSE 0 END) AS voucher,

    -- Total of all payment methods
    SUM(payment_value) AS total_payment

FROM order_payments_clean
GROUP BY order_id

select distinct order_id from order_payments_clean_v
where order_id='0016dfedd97fc2950e388d2971d718c7'





---------------- Joining order
--------------order 360
----JOIN THE TABLE ACCORDING TO PRODUCT TOTAL AMOUNT, MAKE THE PAYMENT VALUE IN PARTS FOR THAT and some calculated columns

-- Step 1: Calculate total amount per order_id
WITH order_totals AS (
    SELECT 
        order_id,
        SUM(total_amount) AS order_total
    FROM orders_clean
    GROUP BY order_id
),

-- Step 2: Join orders with payment view and total for ratio
joined_data AS (
    SELECT 
        o.*,
        p.credit_card,
        p.upi_cash,
        p.debit_card,
        p.voucher,
        p.total_payment,
        ot.order_total,
        CAST(o.total_amount AS FLOAT) / NULLIF(ot.order_total, 0) AS payment_ratio,
        pi.category,
        DATENAME(MONTH, TRY_CAST(o.bill_date_timestamp AS DATETIME)) AS order_month,
        CASE 
            WHEN DATEPART(WEEKDAY, TRY_CAST(o.bill_date_timestamp AS DATETIME)) IN (1, 7) THEN 'Weekend'
            ELSE 'Weekday'
        END AS day_type
    FROM orders_clean o
    JOIN order_totals ot ON o.order_id = ot.order_id
    JOIN order_payments_clean_v p ON o.order_id = p.order_id
    LEFT JOIN products_info_clean pi ON o.product_id = pi.product_id
)

-- Step 3: Select final columns into orders_360
SELECT 
    customer_id,
    order_id,
    product_id,
    channel,
    store_id,
    bill_date_timestamp,
    cost_per_unit,
    mrp,
    discount,
    quantity,
    total_amount,

    ROUND(credit_card * payment_ratio, 2) AS credit_card,
    ROUND(upi_cash * payment_ratio, 2) AS upi_cash,
    ROUND(debit_card * payment_ratio, 2) AS debit_card,
    ROUND(voucher * payment_ratio, 2) AS voucher,
    ROUND(total_payment * payment_ratio, 2) AS paid_amount,

    Round(total_amount - (cost_per_unit * quantity),2) AS profit,
    CAST(ROUND(((total_amount - cost_per_unit) / NULLIF(total_amount, 0)) * 100, 2) AS VARCHAR) + '%' 
	AS profit_percentage,

    category,
    order_month,
    day_type

INTO orders_360
FROM joined_data;



-- for verify
SELECT* FROM orders_360
where order_id='f9d9904f1f957c0fd0bf82dc3568936b'

select * from orders_clean
where order_id='f9d9904f1f957c0fd0bf82dc3568936b'

select * from order_payments_clean_v
where order_id='f9d9904f1f957c0fd0bf82dc3568936b'

--------------- 360 of customers  

-- Step 1: Aggregate Order Info
WITH order_stats AS (
    SELECT 
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(total_amount) AS total_revenue,
        ROUND(SUM(total_amount - (cost_per_unit)*quantity),2) AS total_profit,
        MIN(CAST(bill_date_timestamp AS DATE)) AS first_order_date,
        MAX(CAST(bill_date_timestamp AS DATE)) AS last_order_date,
        DATEDIFF(DAY, MIN(CAST(bill_date_timestamp AS DATE)), MAX(CAST(bill_date_timestamp AS DATE))) AS active_period,
        ROUND(AVG(total_amount), 2) AS avg_order_value
    FROM orders_clean
    GROUP BY customer_id
),

-- Step 2: Aggregate Payment Type Count and Total Value
payment_stats AS (
    SELECT 
        o.customer_id,
        COUNT(CASE WHEN p.credit_card > 0 THEN 1 END) AS credit_card_count,
        COUNT(CASE WHEN p.debit_card > 0 THEN 1 END) AS debit_card_count,
        COUNT(CASE WHEN p.upi_cash > 0 THEN 1 END) AS upi_cash_count,
        COUNT(CASE WHEN p.voucher > 0 THEN 1 END) AS voucher_count,

        SUM(p.credit_card) AS credit_card_paid,
        SUM(p.debit_card) AS debit_card_paid,
        SUM(p.upi_cash) AS upi_cash_paid,
        SUM(p.voucher) AS voucher_paid
    FROM orders_clean o
    JOIN order_payments_clean_v p ON o.order_id = p.order_id
    GROUP BY o.customer_id
),

-- Step 3: Average Rating
avg_rating AS (
    SELECT 
        o.customer_id,
        ROUND(AVG(r.customer_satisfaction_score), 2) AS avg_rating
    FROM order_review_ratings_clean r
    JOIN orders_clean o ON r.order_id = o.order_id
    GROUP BY o.customer_id
)

-- Final Output: Assemble Customer 360 with churn and value segment
SELECT 
    c.customer_id,
    c.customer_city,
    c.customer_state,
    c.gender,

    os.total_orders,
    os.total_revenue,
    os.total_profit,
    os.first_order_date,
    os.last_order_date,
    os.active_period,
    os.avg_order_value,

    -- Churn Status
    CASE 
        WHEN os.last_order_date < '2023-04-01' THEN 'churned'
        ELSE 'active'
    END AS churn_status,

    -- Value Segment
    CASE 
        WHEN os.total_revenue >= 1000 THEN 'high'
        WHEN os.total_revenue >= 500 THEN 'medium'
        ELSE 'low'
    END AS value_segment,

    ps.credit_card_count,
    ps.debit_card_count,
    ps.upi_cash_count,
    ps.voucher_count,

    ps.credit_card_paid,
    ps.debit_card_paid,
    ps.upi_cash_paid,
    ps.voucher_paid,

    ar.avg_rating

INTO customer_360
FROM customers_clean c
LEFT JOIN order_stats os ON c.customer_id = os.customer_id
LEFT JOIN payment_stats ps ON c.customer_id = ps.customer_id
LEFT JOIN avg_rating ar ON c.customer_id = ar.customer_id


-- deleting row where total orders is null or zero
DELETE FROM customer_360
WHERE total_orders = 0 OR total_orders IS NULL;


select * from customer_360
where total_orders= 0 or total_orders is NULL

----- store 360


--Total Orders, Revenue, and Profit 

WITH store_order_stats AS (
    SELECT 
        store_id,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(total_amount) AS total_revenue,
        ROUND(SUM(total_amount - (cost_per_unit * quantity)),2) AS total_profit
    FROM orders_clean
    GROUP BY store_id
),
-- Most Sold Category by Quantity

category_by_qty AS (
    SELECT 
        o.store_id,
        p.category,
        SUM(o.quantity) AS total_qty,
        RANK() OVER (PARTITION BY o.store_id ORDER BY SUM(o.quantity) DESC) AS rank_qty
    FROM orders_clean o
    JOIN products_info_clean p ON o.product_id = p.product_id
    GROUP BY o.store_id, p.category
),
-- Most Sold Category by Amount

category_by_amt AS (
    SELECT 
        o.store_id,
        p.category,
        SUM(o.total_amount) AS total_amt,
        RANK() OVER (PARTITION BY o.store_id ORDER BY SUM(o.total_amount) DESC) AS rank_amt
    FROM orders_clean o
    JOIN products_info_clean p ON o.product_id = p.product_id
    GROUP BY o.store_id, p.category
),
-- Most Profitable Category

category_by_profit AS (
    SELECT 
        o.store_id,
        p.category,
        SUM(o.total_amount - o.cost_per_unit) AS total_profit,
        RANK() OVER (PARTITION BY o.store_id ORDER BY SUM(o.total_amount - o.cost_per_unit) DESC) AS rank_profit
    FROM orders_clean o
    JOIN products_info_clean p ON o.product_id = p.product_id
    GROUP BY o.store_id, p.category
)
-- Final Table store_360

SELECT 
    s.store_id,
    s.seller_city,
    s.seller_state,
	s.region,

    so.total_orders,
    so.total_revenue,
    so.total_profit,

    q.category AS top_category_by_quantity,
    a.category AS top_category_by_amount,
    pr.category AS top_category_by_profit

INTO store_360
FROM stores_info_clean s
LEFT JOIN store_order_stats so ON s.store_id = so.store_id
LEFT JOIN category_by_qty q ON s.store_id = q.store_id AND q.rank_qty = 1
LEFT JOIN category_by_amt a ON s.store_id = a.store_id AND a.rank_amt = 1
LEFT JOIN category_by_profit pr ON s.store_id = pr.store_id AND pr.rank_profit = 1;


-- now deleting the stores with are of no use (null or o total orders)

DELETE FROM store_360
WHERE total_orders = 0 OR total_orders IS NULL;


select * from store_360

select * from customer_360

select * from orders_360

select column_name, DATA_type from  INFORMATION_SCHEMA.COLUMNS
where table_name = 'customer_360'





select customer_id, count(customer_id) from customer_360
group by customer_id
order by count(customer_id) desc

select * from customer_360
where customer_id='9798683036'

select * from orders_360
where customer_id='9798683036'

--Customer state wise spend

select customer_state, round(sum(total_profit),2) as customer_state_spend from customer_360
group by customer_state
order by sum(total_profit) desc

select customer_id, sum(total_revenue) from  customer_360
group by customer_id
order by sum(total_revenue) desc


select * from customer_360
where customer_id='1149825632'



select distinct order_id from orders_360

select order_month, sum(profit) from orders_360
group by order_month
order by sum(profit) desc

select category, count(product_id) from orders_360
group by category
order by count(product_id) desc

select category, sum(quantity) from orders_360
group by category
order by sum(quantity) desc

select distinct total_orders, count(customer_id) as customer_count from customer_360
group by total_orders

select customer_id, count(distinct order_id) from orders_clean
group by customer_id
order by count(distinct order_id) desc


select* from customer_360

select * from orders_360

select * from store_360

select seller_city, sum(total_profit) from store_360
group by seller_city
order by sum(total_profit) desc


select column_name from  INFORMATION_SCHEMA.COLUMNS
where table_name = 'Store_360'

select distinct order_id from orders_360



select * from order_payments_clean
where order_id='00bd50cdd31bd22e9081e6e2d5b3577b'
select * from orders_clean
where order_id='00bd50cdd31bd22e9081e6e2d5b3577b'









---------- insights of customers level 360

select * from customer_360


--Total Active Customers
SELECT COUNT(*) AS total_customers
FROM customer_360

--Churn Rate (%)
SELECT 
    ROUND(
        100.0 * COUNT(CASE WHEN last_order_date < '2023-04-01' THEN 1 END) / 
        COUNT(*), 2
    ) AS churn_rate_percentage
FROM customer_360;


select 100 *count(churn_status)/(select count(churn_status) from customer_360)
from customer_360
where churn_status='churned'

--Number of customers for 0 active period

select round(cast(100*count(*)as float)/(select count(*) from customer_360),2) from customer_360
where active_period=0

--Count of one time buyer

select * from customer_360
where total_orders=1


--Total Customers spend

select sum(total_revenue) from customer_360

--Top customer


select customer_id,sum(total_revenue) from customer_360
group by customer_id
order by sum(total_revenue) desc

--Top city by number customers

select customer_city, count(customer_id) from customer_360
group by customer_city
order by count(customer_id) desc

--Bottom city by number of customers

select customer_city, count(customer_id) from customer_360
group by customer_city
order by count(customer_id)

--Top state by number of customers

select customer_state, count(customer_id) from customer_360
group by customer_state
order by count(customer_id) desc



--Bottom state by number of customers

select customer_state, count(customer_id) from customer_360
group by customer_state
order by count(customer_id)

-- Male and female count

select gender, count(customer_id) from customer_360
group by gender

--Which gender spend most and how much

select gender, round(sum(total_revenue),2) from customer_360
group by gender
order by sum(total_revenue) desc

-- Top State by customer spend

select customer_state, sum(total_revenue) from customer_360
group by customer_state
order by sum(total_revenue) desc

--  Bottom State by customer spend


select customer_state, sum(total_revenue) from customer_360
group by customer_state
order by sum(total_revenue)

-- Customer Value Segmentation


SELECT value_segment, COUNT(*) AS customer_count
FROM customer_360
GROUP BY value_segment;

--State-wise Customer Count

SELECT customer_state, COUNT(*) AS customer_count
FROM customer_360
GROUP BY customer_state
ORDER BY customer_count DESC;

-- Gender-wise Revenue Share

SELECT gender, SUM(total_revenue) AS total_revenue
FROM customer_360
GROUP BY gender;

-- Avg. Order Value per Segment

SELECT value_segment, ROUND(AVG(avg_order_value), 2) AS avg_order_value
FROM customer_360
GROUP BY value_segment;

--Customer state wise spend

select customer_state, round(sum(total_revenue),2) as customer_state_spend from customer_360
group by customer_state
order by sum(total_profit) desc


-- State wise churned

select customer_state, count(customer_id) from customer_360
where churn_status='churned'
group by customer_state
order by count(customer_id) desc

--- State wise total customer vs churn

with total as(
select customer_state, count(customer_id) as total_customer from customer_360
group by customer_state
),
chrun as ( select customer_state, count(customer_id) as churned from customer_360
where churn_status='churned'
group by customer_state
)
select 
	t.customer_state,
	t.total_customer,
	c.churned

from total t
join chrun c
on t.customer_state=c.customer_state
order by t.total_customer desc

--Average rating according to Segments

select value_segment,ROUND(AVG(avg_rating), 2) from customer_360
group by value_segment

--Revenue and profit by segment

select value_segment, round(sum(total_revenue),2), round(sum(total_profit),2) from customer_360
group by value_segment

--Customer active vs churned

select churn_status, count(customer_id) from customer_360
group by churn_status

-- Gender wise customer count

select gender, count(customer_id) from customer_360
group by gender

--Gender wise Total customer and churned

with totall as(
select gender, count(customer_id) as totals from customer_360 group by gender
),
churn as (
select gender, count(customer_id) as churn from customer_360 where churn_status='churned' group by gender
)
select t.gender, t.totals, c.churn from totall t join churn c on t.gender=c.gender


---Gender wise segment


with h as (select gender, COUNT(*) as hig from customer_360 where value_segment='high' group by gender),
m as(select gender, COUNT(*) as mediu from customer_360 where value_segment='medium' group by gender),
l as(select gender, COUNT(*) as loww from customer_360 where value_segment='low' group by gender)
select h.gender, h.hig, m.mediu, l.loww from h join m on h.gender=m.gender  join l on h.gender=l.gender


--Top and Bottom 5 cities by customer spend

select top 5 customer_city, round(sum(total_revenue),2) as rev from customer_360
group by customer_city
order by rev desc

select top 5 customer_city, round(sum(total_revenue),2) as rev from customer_360
group by customer_city
order by rev

-- total number city 
select count(distinct customer_city) from customer_360


------------------------ Order 360 insights

select * from orders_360

--Total Orders

SELECT COUNT(DISTINCT order_id) AS total_orders
FROM orders_360;

-- Total unique customer count

select count(distinct customer_id) from orders_360 

--Total Revenue
SELECT SUM(total_amount) AS total_revenue
FROM orders_360;

--Total Profit

SELECT SUM(profit) AS total_profit
FROM orders_360;


--Profit Margin (%)

SELECT ROUND(SUM(profit) * 100.0 / NULLIF(SUM(total_amount), 0), 2) AS profit_margin_percentage
FROM orders_360;


--Top channel used

select channel, count(distinct order_id) from orders_360
group by channel

--Total orders placed by Instore

select channel, count(distinct order_id) from orders_360
group by channel

--Top category by quantity

select category, sum(quantity) from orders_360
group by category
order by sum(quantity) desc

--Top category by Amount

select category, sum(total_amount) from orders_360
group by category
order by sum(quantity) desc

--Top category by profit

select category, sum(profit) from orders_360
group by category
order by sum(quantity) desc

--Bottom category by profit

select category, sum(profit) from orders_360
group by category
order by sum(quantity)

--Top Month by revenue

select order_month, sum(total_amount) from orders_360
group by order_month
order by sum(total_amount) desc

--Bottom Month by revenue

select order_month, sum(total_amount) from orders_360
group by order_month
order by sum(total_amount)

--Most order placed by which day type

select day_type, count(distinct order_id) from orders_360
group by day_type


--Max Quantity by order id

select order_id, sum(quantity) from orders_360
group by order_id
order by sum(quantity) desc




--Category-wise Profit
SELECT category, SUM(profit) AS total_profit
FROM orders_360
GROUP BY category
ORDER BY total_profit DESC;


--Category-wise revenue
SELECT category, SUM(total_amount) AS revenue
FROM orders_360
GROUP BY category
ORDER BY revenue DESC;


--Monthly Revenue Trend

SELECT 
    YEAR(CAST(bill_date_timestamp AS datetime)) AS order_year,
    DATENAME(MONTH, CAST(bill_date_timestamp AS datetime)) AS order_month_name,
    SUM(total_amount) AS monthly_revenue
FROM orders_360
GROUP BY 
    YEAR(CAST(bill_date_timestamp AS datetime)),
    DATENAME(MONTH, CAST(bill_date_timestamp AS datetime)),
    DATEPART(MONTH, CAST(bill_date_timestamp AS datetime))
ORDER BY 
    order_year,
    DATEPART(MONTH, CAST(bill_date_timestamp AS datetime))




--Weekday vs Weekend Orders

SELECT day_type, COUNT(distinct order_id) AS order_count
FROM orders_360
GROUP BY day_type;

--Weekday vs Weekend revenue

SELECT day_type, round(sum(total_amount),2) AS revenue
FROM orders_360
GROUP BY day_type;

--Top 10 Products by Profit
SELECT TOP 10 product_id, SUM(profit) AS total_profit
FROM orders_360
GROUP BY product_id
ORDER BY total_profit DESC;


-- monthly discount trend

SELECT 
    YEAR(CAST(bill_date_timestamp AS datetime)) AS order_year,
    DATENAME(MONTH, CAST(bill_date_timestamp AS datetime)) AS order_month_name,
    SUM(discount) AS monthly_discount
FROM orders_360
GROUP BY 
    YEAR(CAST(bill_date_timestamp AS datetime)),
    DATENAME(MONTH, CAST(bill_date_timestamp AS datetime)),
    DATEPART(MONTH, CAST(bill_date_timestamp AS datetime))
ORDER BY 
    order_year,
    DATEPART(MONTH, CAST(bill_date_timestamp AS datetime))



-- channel wise customer count

select channel, count(distinct order_id) from orders_360
group by channel



-- channel wise revenue generated

select channel, round(sum(total_amount),2) from orders_360
group by channel


---------------------- Stores 360

select * from store_360


--Total Stores

SELECT COUNT(*) AS total_stores
FROM store_360;


--Total orders

Select sum(total_orders) from store_360

--Total Profit

select sum(total_profit) from store_360

--Total revenue

select sum(total_revenue) from store_360

--Top Profitable Store

SELECT TOP 1 store_id, total_profit
FROM store_360
ORDER BY total_profit DESC;

--Top Profitable City

select seller_city, sum(total_profit) as profit from store_360
group by seller_city
order by profit desc


--Top profitable State

select seller_state, sum(total_profit) as profit from store_360
group by seller_state
order by profit desc

--Least profitable State

select seller_state, sum(total_profit) as profit from store_360
group by seller_state
order by profit

--Top profitable Region

select region, sum(total_profit) as profit from store_360
group by region
order by profit desc

--Top revenue generater Region

select region, sum(total_revenue) from store_360
group by region 
order by sum(total_revenue) desc

--Top state by total orders

select seller_state, sum(total_orders) from store_360
group by seller_state 
order by sum(total_orders) desc

--Bottom State by total orders

select seller_state, sum(total_orders) from store_360
group by seller_state 
order by sum(total_orders)

--Top region by total orders

select region, sum(total_orders) from store_360
group by region 
order by sum(total_orders) desc





--Region-wise Revenue

SELECT region, SUM(total_revenue) AS total_revenue, sum(total_profit) as profit
FROM store_360
GROUP BY region
ORDER BY total_revenue DESC;


--Top Category Sold (by Quantity)

SELECT top_category_by_quantity, COUNT(*) AS store_count
FROM store_360
GROUP BY top_category_by_quantity
ORDER BY store_count DESC;


--State vs Order Count

SELECT seller_state, SUM(total_orders) AS total_orders
FROM store_360
GROUP BY seller_state
ORDER BY total_orders DESC;


--Average Revenue per Store, top 10

SELECT top 10 store_id ,ROUND(AVG(total_revenue), 2) AS avg_revenue_per_store
FROM store_360
group by store_id
order by avg_revenue_per_store desc


--Top 10 Stores by Profit

SELECT TOP 10 store_id, total_profit
FROM store_360
ORDER BY total_profit DESC;


-- state wise store count

select seller_state, count(store_id) from store_360
group by seller_state

-- state which dont have store , order count



