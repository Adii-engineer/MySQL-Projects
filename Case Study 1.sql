use retailer;

select * from customer_profiles;
select * from product_inventory;
select * from sales_transaction;


select max(price) from product_inventory
where price < (
select max(price) from product_inventory
where price < (select max(price) from product_inventory));


select price  from product_inventory p1
where price >
(select avg(price) from product_inventory g1
where p1.price <> g1.price);

select productID from sales_transaction
inner join product_inventory on product_inventory.productID = sales_transaction.productID

select productid from sales_transaction ;

-- -------------------------------------------------------------------------------------------------------
-- question 1=>Write a query to identify the number of duplicates in "sales_transaction" table. Also, create a separate table containing the unique values and remove the the original table from the databases and replace the name of the new table with the original name.
SELECT transactionID, count(*)
from sales_transaction
group by transactionID
having count(*) >1;

CREATE TABLE sales_transaction_nodupe
as SELECT distinct * from sales_transaction

Drop TABLE sales_transaction

alter TABLE sales_transaction_nodupe rename to sales_transaction
select * from sales_transaction

-- question 2=>Write a query to identify the discrepancies in the price of the same product in "sales_transaction" and "product_inventory" tables. Also, update those discrepancies to match the price in both the tables.
select st.transactionid, st.price,pi.price
from sales_transaction st
join product_inventory pi
on st.productId = pi.productID
where st.price <> pi.price 

UPDATE sales_transaction st
set price =
( select price from product_inventory pi 
where st.productid = pi.productid
)
where productid in 
( select productid from product_inventory pii
where st.price <> pii.price and st.productid = pii.productid 
)

SELECT *
from sales_trasaction st 
join product_inventory pi where st.productid = pi.productid

-- set sql_safe_updates = 0
-- question 3=>Write a SQL query to identify the null values in the dataset and replace those by “Unknown”.

select *
from customer_profiles where location = ''

update customer_profiles
set location = 'UNKNOWN'
WHERE location = ''

select * from customer_profiles

-- question 4=>Write a SQL query to clean the DATE column in the dataset.
-- channge date type

create table Transactiondate_update as  select * from sales_transaction;
select *,cast(transactiondate as date) as Transactiondate_updated from transactiondate_update

-- question 5=>Write a SQL query to summarize the total sales and quantities sold per product by the company.

select Productid, sum(quantitypurchased) as TotalUnitSold, sum(quantitypurchased*price) as TotalSales
from sales_transaction
group by productid
order by TotalSales desc

-- question 6=> Write a SQL query to count the number of transactions per customer to understand purchase frequency.

select customerid, count(*) as NumberOfTransaction
from sales_transaction
group by customerid
order by NumberOfTransaction desc

-- question 8=> Write a SQL query to find the top 10 products with the highest total sales revenue from the sales transactions. This will help the company to identify the High sales products which needs to be focused to increase the revenue of the company.


select distinct productid,sum(quantitypurchased*price) as Totalrevenue
from sales_transaction
group by productid
order by Totalrevenue desc
limit 10

-- QUESTION 9=> Write a SQL query to find the ten products with the least amount of units sold from the sales transactions, provided that at least one unit was sold for those products.
select productid as productid,sum(quantitypurchased) as totalunitssold
from sales_transaction
group by productid
having totalunitssold > 0
order by totalunitssold asc
limit 10


-- question 10=>Write a SQL query to identify the sales trend to understand the revenue pattern of the company.

select DATE_FORMAT(str_to_date(transactiondate,'%d/%m/%y'), '%Y-%m-%d') as DATETRANS, count(transactionID) as Transaction_count, sum(quantitypurchased) as TotalUnitSold
, sum(quantitypurchased*price) as Totalsales
from sales_transaction
group by DATETRANS
order by DATETRANS desc

-- question 11=> Write a SQL query to understand the month on month growth rate of sales of the company which will help understand the growth trend of the company.


with helpertable as (
select extract(month from str_to_date(transactiondate,'%d/%m/%y')) as month,
sum(quantitypurchased*price) as total_sales
from sales_transaction
group by month
)

select month, total_sales , 
lag(total_sales) over(order by month) as previous_month_sales,
((total_sales - lag(total_sales) over(order by month)) / lag(total_sales) over(order by month))*100 as percentage_change
from helpertable
order by month

-- question 12 => Write a SQL query that describes the number of transaction along with the total amount spent by each customer which are on the higher side and will help us understand the customers who are the high frequency purchase customers in the company.

select CustomerID, count(*) as NumberOfTransaction, sum(quantitypurchased*price) as TotalSpent
from sales_transaction
group by customerid
having count(*) > 10 and TotalSpent >1000
order by TotalSpent desc

-- question 13=> Write a SQL query that describes the number of transaction along with the total amount spent by each customer, which will help us understand the customers who are occasional customers or have low purchase frequency in the company.


select customerid, count(*) as numberoftransactions, sum(quantitypurchased * price) as Totalspent
from sales_transaction
group by customerid
order by numberoftransactions asc, Totalspent desc

-- question 14=>Write a SQL query that describes the total number of purchases made by each customer against each productID to understand the repeat customers in the company.

select customerid, productid,   count(*) as TimesPurchased
from sales_transaction
group by customerid, productid
having count(*) > 1
order by TimesPurchased desc

-- question 15=> Write a SQL query that describes the duration between the first and the last purchase of the customer in that particular company to understand the loyalty of the customer.

with helper_table as
( select * , Date_format(str_to_date(transactiondate,'%d/%m/%y'),'%Y/%m/%d') as transactiondate_update
from sales_transaction)
select CustomerID, min(transactiondate_update) as FirstPurchase ,max(transactiondate_update) as LastPurchase, 
max(transactiondate_update)-min(transactiondate_update) as DaysBetweenPurchase
from helper_table
group by customerid
-- having DaysBetweenPurchase > 0
order by DaysBetweenPurchase desc

-- question 16=> Write a SQL query that segments customers based on the total quantity of products they have purchased. Also, count the number of customers in each segment which will help us target a particular segment for marketing.

-- with helper_table as (
-- select customerid,
-- case
--         when count(*) <11 then 'Low'
--         when count(*)<31 then 'Mid'
--         else 'High Value'
-- end as CustomerSegment, count(*)

-- from sales_transaction
-- group by customerid
-- )
-- select CustomerSegment, count(*)
-- from helper_table
-- group by CustomerSegment

CREATE TABLE Customer_Segment AS
(SELECT
    CASE
             WHEN total_quantity < 10 THEN 'Low'
             WHEN total_quantity <= 30 THEN 'Med'
             ELSE 'High' END AS CustomerSegment,
             COUNT(*)  
             FROM (
SELECT c.CustomerID, SUM(st.QuantityPurchased) AS total_quantity
FROM sales_transaction st
JOIN customer_profiles c
ON c.CustomerID = st.CustomerID
GROUP BY c.CustomerID
) AS CustomerSegment
GROUP BY  CustomerSegment);


SELECT * FROM Customer_Segment;
-- ---------------------------------------------------------------------------------------
-- question 7=> Write a SQL query to evaluate the performance of the product categories based on the total sales which help us understand the product categories which needs to be promoted in the marketing campaigns.
select p.category, sum(s.quantitypurchased), sum(s.quantitypurchased*s.price) as totalSales
from product_inventory p
left join sales_transaction s on p.productid = s.productid
group by p.category
order by totalSales desc
-- -----------------------------------------------------------------------------------------
