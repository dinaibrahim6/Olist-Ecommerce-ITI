-- Sales by Product Category view:
create view vw_sales_by_category as
select product_category_English_name as [Product Category], SUM(price) as [Total Sales]
from Products join Order_Items
on Products.product_id = Order_Items.product_id
group by product_category_English_name

select * from vw_sales_by_category


-- Product Performance View:
create view vw_product_performance as
select product_category_English_name, Products.product_id, product_name, SUM(price) as [Total Sales], COUNT(Distinct Order_Items.order_id) as [Total Orders] , COUNT(Order_Items.order_item_id) as [No. Units Sold] 
from Products join Order_Items
on Products.product_id = Order_Items.product_id
group by product_category_English_name, Products.product_id, product_name


select * from vw_product_performance


-- Seller Performance Overview view:
create view vw_seller_performance as
select Sellers.seller_id, seller_name, SUM(Price) as [Total Revenue], COUNT(order_item_id) as [Total Items]
from Sellers join Order_Items
on Sellers.seller_id = Order_Items.seller_id
group by Sellers.seller_id, seller_name

select * from vw_seller_performance


-- Top 10 Selling Products view:
create view vw_top_selling_products as
select Top(10) product_name, sum(price) as [Total Sales]
from Products join Order_Items
on Products.product_id = Order_Items.product_id
group by product_name
order by [Total Sales] Desc

select * from vw_top_selling_products


-- Monthly Sales Summary view:
create view vw_monthly_sales as
select Datename(Month, order_purchase_timestamp)as [Month], SUM(price) as [Total Sales], COUNT(distinct Orders.order_id) as [Total Orders]
from Orders join Order_Items
on Orders.order_id = Order_Items.order_id
group by Datename(Month, order_purchase_timestamp)

select * from vw_monthly_sales


-- Yearly Sales Summary view:
create view Yearly_Sales_Summary AS 
select
    FORMAT(O.order_purchase_timestamp, 'yyyy-MM') AS sales_month,
    COUNT(DISTINCT O.order_id) AS total_orders,
    SUM(OI.price) AS total_revenue,
    Count(OI.order_item_id) AS total_units_sold,
    SUM(OI.Price) / COUNT(DISTINCT O.order_id) AS avg_order_value
FROM orders O
JOIN order_items OI ON O.order_id = OI.order_id
WHERE O.order_status = 'delivered'
GROUP BY FORMAT(O.order_purchase_timestamp, 'yyyy-MM')

select * from Yearly_Sales_Summary


-- Customer Purchase History view:
create view vw_customer_purchase as
select Customers.customer_unique_id as [Customer ID],
Orders.order_id as [Order ID], 
Year(order_purchase_timestamp)as [Year],
Datename(Month, order_purchase_timestamp)as [Month], 
sum(price) as [Total Spent],
COUNT(distinct Order_Items.order_item_id) as [Total Items Sold],
COUNT(Distinct Order_Items.order_id) as [Total Orders],
Customer_Login_type
from Orders join Order_Items  
on Orders.order_id = Order_Items.order_id
join customers on Orders.customer_unique_id = Customers.customer_unique_id
group by Customers.customer_unique_id, Orders.order_id, Year(order_purchase_timestamp), Datename(Month, order_purchase_timestamp), Customer_Login_type

select * from vw_customer_purchase


-- Average Delivery days Per Seller view:
create view vw_avg_delivery_days as
select seller_name, AVG(DATEDIFF(Day,order_purchase_timestamp,order_delivered_customer_date)) as [Avg Delivery Days]
from Sellers join Order_Items
on Sellers.seller_id = Order_Items.seller_id
join Orders 
on Orders.order_id = Order_Items.order_id
where order_delivered_customer_date is not null
group by seller_name

select * from vw_avg_delivery_days


-- Payment Methods Summary view:
create view vw_payment_summary as
select Bank_Name, payment_type, SUM(payment_value) as [Total values] , count(Distinct order_id) as [Order ID]
from Order_Payments
where Bank_Name is not null
group by Bank_Name, payment_type

select * from vw_payment_summary


-- High-Value Customers view:
create view vw_high_value_customer as
select Customers.customer_unique_id as [Customer ID], 
sum(price) as [Total Spent]
from Customers join Orders
on Customers.customer_unique_id = Orders.customer_unique_id
join Order_Items 
on Orders.order_id = Order_Items.order_id
group by Customers.customer_unique_id
having sum(price) > 1000

select * from vw_high_value_customer


-- Top Sellers View:
create view vw_Top_sellers as
select top(10) seller_name, SUM(Price) as [Total Revenue], COUNT(order_item_id) as [Total Items]
from Sellers join Order_Items
on Sellers.seller_id = Order_Items.seller_id
group by Sellers.seller_id, seller_name
order by [Total Revenue] Desc

select * from vw_Top_sellers


-- Pending Orders View:
create view vw_pending_orders as
select orders.order_id, Customers.customer_unique_id, customer_state, order_purchase_timestamp, order_status
from Orders join Customers
on Orders.customer_unique_id = Customers.customer_unique_id
where order_status in ('created', 'processing')

select * from vw_pending_orders
