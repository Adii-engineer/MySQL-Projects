use ecommers;


-- select * from orders
-- question 1
describe customers;
describe products;
describe orders;
describe orderDetails
-- -----------------------------------------------------------------------------
select month, AvgOrderValue, round(AvgOrderValue-Changer,2) as ChangeInValue
from
(select lag(avgordervalue)over(order by month) as Changer,month,avgordervalue
from
(select date_format(str_to_date(order_date,'%Y-%m-%d'),'%Y-%m') as month,
avg(total_amount) as AvgOrderValue
from orders
group by month) as ok
group by month) as okk
group by month;
-- -----------------------------------------------------------------


select product_id, count(quantity) as c
from orderdetails
group by product_id
order by c desc
limit 5
-- -----------------------------------------------------------------

SELECT 
    MONTH(first_purchase_date) AS month,
    COUNT(customer_id) AS new_customers
FROM (
    SELECT 
        customer_id,
        MIN(order_date) AS first_purchase_date
    FROM 
        Orders
    GROUP BY 
        customer_id
) AS first_purchase_per_customer
GROUP BY 
    month
ORDER BY 
    month ASC;
    
-- ------------------------------------------------------------------------------
select * from products;
select * from customers;
select * from orders;
select * from orderdetails;

select p.product_id , p.name, c.customer_id*0.4
from (
select *
from orders o
join orderdetails od on o.order_id = od.order_id
join products p on p.product_id = od.product_id
join customers c on c.customer_id = o.customer_id
)

-- --------------------------------------------------------------------------------------
questio 2=> Identify the top 3 cities with the highest number of customers to determine key markets for targeted marketing and logistic optimization.

-- select * from customers

select location, count(*) as number_of_customers
from customers
group by location
order by count(*) desc
limit 3

-- --------------------------------------------------------------------------------------
question 3=> Determine the distribution of customers by the number of orders placed. This insight will help in segmenting customers into one-time buyers, occasional shoppers, and regular customers for tailored marketing strategies.

with helper_table as(
select customer_id,count(*) as numberoforders
from orders
group by customer_id)
select numberoforders,count(*) as customercount
from helper_table
group by numberoforders 
order by numberoforders asc;
-- ----------------------------------------------------------------------------------------
question 4=> Identify products where the average purchase quantity per order is 2 but with a high total revenue, suggesting premium product trends.

select product_id, avg(quantity) as AvgQuantity, sum(quantity*Price_per_unit )as TotalRevenue
from orderdetails
group by product_id
having AvgQuantity = 2 and TotalRevenue > 100000
-- order by TotalRevenue desc, AvgQuantity
-- ---------------------------------------------------------------------------------
Question 5=> For each product category, calculate the unique number of customers purchasing from it. This will help understand which categories have wider appeal across the customer base.

-- select * from products.category, distinct orders.customer_id
-- select * from orders

SELECT 
    p.category,
    COUNT(DISTINCT o.customer_id) AS unique_customers
FROM 
    Products p
INNER JOIN 
    OrderDetails od ON p.product_id = od.product_id
INNER JOIN 
    Orders o ON od.order_id = o.order_id
GROUP BY 
    p.category
ORDER BY 
    unique_customers DESC;
-- ------------------------------------------------------------------------------------------------------------
Question 6=> Analyze the month-on-month percentage change in total sales to identify growth trends.

select month,TotalSales, round(((totalsales-per)/per)*100,2) as PercentChange
from
(select month,TotalSales, lag(TotalSales)over(order by month) as per
from
(select Date_format(str_to_date(order_date,'%Y-%m-%d'),'%Y-%m') as Month, 
Sum(total_amount) as TotalSales
from orders
group by Month) as firsts
group by month) as seconds
order by month
-- ----------------------------------------------------------------------------------------------------
Question 7>Examine how the average order value changes month-on-month. Insights can guide pricing and promotional strategies to enhance order value.

select month, AvgOrderValue, round(AvgOrderValue-Changer,2) as ChangeInValue
from
(select lag(avgordervalue)over(order by month) as Changer,month,avgordervalue
from
(select date_format(str_to_date(order_date,'%Y-%m-%d'),'%Y-%m') as month,
avg(total_amount) as AvgOrderValue
from orders
group by month) as ok
group by month) as okk
group by month
-- ----------------------------------------------------------------------------------------------------------
Question 8 => Based on sales data, identify products with the fastest turnover rates, suggesting high demand and the need for frequent restocking.

select product_id, count(quantity) as salesFrequency
from orderdetails
group by product_id
order by salesFrequency desc
limit 5
-- -------------------------------------------------------------------------------------------------------
Question 9=> List products purchased by less than 40% of the customer base, indicating potential mismatches between inventory and customer interest.

select p.product_id, p.name, count(distinct customer_id) as UniqueCustomerCount, p.price
from products p
left join orderdetails od on p.product_id = od.product_id
left join orders o on od.order_id = o.order_id
group by product_id, name, price
having count(distinct customer_id) < (select 0.4*count(distinct customer_id) from customers)
-- -----------------------------------------------------------------------------------------------------------
Question 10=> Evaluate the month-on-month growth rate in the customer base to understand the effectiveness of marketing campaigns and market expansion efforts


SELECT 
    date_format(first_purchase_date,'%Y-%m') AS FirstPurchaseMonth,
    COUNT(customer_id) AS TotalNewCustomers
FROM (
    SELECT 
        customer_id,
        MIN(str_to_date(order_date,'%Y-%m-%d')) AS first_purchase_date
    FROM 
        Orders
    GROUP BY 
        customer_id
) AS first_purchase_per_customer
GROUP BY 
    FirstPurchaseMonth
ORDER BY 
    FirstPurchaseMonth ASC;
-- ---------------------------------------------------------------------------------------------------------
Question 11=> Identify the months with the highest sales volume, aiding in planning for stock levels, marketing efforts, and staffing in anticipation of peak demand periods.

select date_format(str_to_date(order_date,'%Y-%m-%d'),'%Y-%m') as month,
sum(total_amount) as TotalSales
from orders
group by month
order by totalsales desc
limit 3
-- ------------------------------------------------------------------------------------------------------------