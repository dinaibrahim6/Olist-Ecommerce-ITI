-- GenerateSalesReport:
create procedure GenerateSalesReport @StartDate Date, @EndDate Date
as 
Begin 
	Select Cast(order_purchase_timestamp as Date) as [Order Date], 
			Sum(Price) as [Total Revenue], 
			Count(Distinct Order_Items.order_id) as [Order Volum],
			Sum(Price) / Count(Distinct Order_Items.order_id) as [Avg Order value]
	from Orders join Order_Items
	on Orders.order_id = Order_Items.order_id
	where order_purchase_timestamp between @StartDate and @EndDate
	group by Cast(order_purchase_timestamp as Date)
	order by [Order Date]
End

Exec GenerateSalesReport @StartDate = '10-2-2017' , @EndDate ='1-12-2018'



-- GenerateCustomerDemographicsReport:
create procedure CustomerDemographics @StartDate Date, @EndDate Date
as
Begin
	select CONCAT(customer_state,', ', customer_city) as [Customer Location],
			COUNT(Distinct Customers.customer_unique_id) as [No. Customers],
			Count(distinct Order_Items.order_id) as [No. Orders],
			Sum(price) as [Total Sales]
	from Customers left join Orders
	on customers.customer_unique_id = Orders.customer_unique_id
	Left join Order_Items
	on Orders.order_id = Order_Items.order_id
	where order_purchase_timestamp between @StartDate and @EndDate
	group by CONCAT(customer_state,', ', customer_city), Customer_Login_type
End

Exec CustomerDemographics @StartDate = '10-2-2017' , @EndDate ='1-12-2018'



create Procedure Product_Performance_Proc @StartDate Date,@EndDate date,@product_name Varchar(100) AS
Select 
        p.product_id,
        Product_name ,
        Brand_name,
        Seller_name,
        product_category_English_name,
        count(OI.product_id) as[No. Units Sold],
        sum(price) as [Total Revenue]
From Order_Items OI 
join Products P on OI.product_id=P.product_id
join Brand B on P.brand_id=B.brand_id
join Sellers S on Oi.seller_id=S.seller_id
join Orders O on Oi.order_id=O.order_id
where p.product_name=@product_name and order_purchase_timestamp between @StartDate and @EndDate
Group by Product_name,product_category_English_name,p.product_id,brand_name,seller_name

Exec Product_Performance_Proc '2016-09-01', '2018-12-31','Essential Cool Stuff Max D156'




-- GenerateSellerPerformanceReport:
create Procedure Seller_Performance_Proc @StartDate Date ,@EndDate Date ,@seller_name VARCHAR(50) AS
Select 
        S.seller_id,
        Seller_Name,
        Brand_name,
        p.product_name,
        product_category_english_name,
        count(distinct oi.order_id) as [No. Orders],
        sum(price) as [Total Revenue],
        count(order_item_id) as [No Sold Units]
From Order_Items Oi
join Products P on Oi.product_id=P.product_id
join Sellers S on S.seller_id= oi.seller_id
join Brand B on p.brand_id=b.brand_id
join Orders o on oi.order_id=o.order_id
where oi.seller_id in (select seller_id
                    from Sellers
					where seller_name = @seller_name) 
					and order_purchase_timestamp between @StartDate and @EndDate
group by S.seller_id,Seller_Name,Brand_name,p.product_name,product_category_english_name

exec Seller_Performance_Proc '2016-09-01', '2017-12-31','Williams and Sons'



-- GenerateCustomerSatisfactionReport:
create procedure CustomerSatisfaction  @StartDate Date, @EndDate Date
as
Begin
	select avg(review_score) as [AverageCSAT],
			count(customer_unique_id) as [No. Customers],
			sum(Case when Review_Status = 'positive' then 1 else 0 End) * 100 / count(*) as PositiveReviewPercentage,
			sum(Case when Review_Status = 'negative' then 1 else 0 End) * 100 / count(*) as NegativeReviewPercentage,

			(select top 1 seller_name 
			 from Orders join Order_Reviews 
			 on Orders.order_id = Order_Reviews.order_id
			 join Order_Items on Orders.order_id = Order_Items.order_id
			 join Sellers on Sellers.seller_id = Order_Items.seller_id
			 where order_purchase_timestamp between @StartDate and @EndDate
			 group by seller_name
			 order by Count(Case when Review_Status = 'positive' then 1 End) Desc ) as MostSatisfiedSeller,

             (select top 1 seller_name
			 from Orders join Order_Reviews 
			 on Orders.order_id = Order_Reviews.order_id
			 join Order_Items on Orders.order_id = Order_Items.order_id
			 join Sellers on Sellers.seller_id = Order_Items.seller_id
			 where order_purchase_timestamp between @StartDate and @EndDate
			 group by seller_name
			 order by Count(Case when Review_Status = 'negative' then 1 End) Desc ) as LeastSatisfiedSeller
	from Orders join Order_Reviews 
	on Orders.order_id = Order_Reviews.order_id
	where order_purchase_timestamp between @StartDate and @EndDate
End

Exec CustomerSatisfaction @StartDate = '10-2-2016' , @EndDate ='1-12-2018'



-- GeneratePaymentMethodsReport:
create procedure PaymentMethods @StartDate Date, @EndDate Date
as
Begin
	select payment_type as [Payment Method],
			SUM(payment_value) as [Total Revenue],
			count(Order_Payments.order_id) as [No. Transactions]
	from Order_Payments join Orders
	on Orders.order_id = Order_Payments.order_id
	where order_purchase_timestamp between @StartDate and @EndDate
	group by payment_type
	order by [Total Revenue]
End

Exec PaymentMethods @StartDate = '10-2-2017' , @EndDate ='1-12-2018'



-- GenerateCustomerCategoryReport:
create procedure CustomerCategory @StartDate Date, @EndDate Date
as
Begin
	select Customer_Login_type as [Customer Category],
			count(Customers.customer_unique_id) as [No. Customers]
	from Customers join Orders
	on Customers.customer_unique_id = Orders.customer_unique_id
	where order_purchase_timestamp between @StartDate and @EndDate
	group by Customer_Login_type
End

Exec CustomerCategory @StartDate = '10-2-2017' , @EndDate ='1-12-2018'



-- MonthlySalesReport:
create procedure MonthlySales @Year int
as
Begin
	select MONTH(order_purchase_timestamp) as [Month],
			DATENAME(month, order_purchase_timestamp) as [Month Name],
			count(Distinct Order_Items.order_id) as [No. Orders],
			sum(price) as [Total Sales],
			sum(price) / count(Distinct Order_Items.order_id) as [Avg Order Value],
			count(order_item_id) as [No. Units Sold]
	from Orders join Order_Items
	on Orders.order_id = Order_Items.order_id
	where Year(order_purchase_timestamp) = @Year
	group by MONTH(order_purchase_timestamp), DATENAME(month, order_purchase_timestamp)
	order by [Total Sales] Desc
End

Exec MonthlySales @Year = 2017



-- GetTop-SellingProducts:
create procedure TopSellingProducts @TopN int
as
begin
	select top (@TopN) Products.product_id as [Product ID], 
			product_name as [Product Name],
			product_category_English_name as [Product Category],
			sum(price) as [Total Sales],
			count(Order_item_id) as [No. Units Sold]
	from Products join Order_Items
	on Products.product_id = Order_Items.product_id
	group by Products.product_id, product_name, product_category_English_name
	order by [No. Units Sold] Desc
End

Exec TopSellingProducts @TopN = 5



-- Insert New Order with Data Validation:
create procedure insertorder 
@orderid varchar(50),
@customerid varchar(50),
@devicetype varchar(10),
@orderstatus varchar(20),
@order_purchase_timestamp DateTime,
@order_estimated_delivery_date DateTime
as
Begin
	if Not Exists (select 1 from customers where customer_unique_id = @customerid)
	Begin 
		select 'Error, the customer does not found'
	End

	Insert into Orders (order_id,customer_unique_id,Device_Type,order_status,order_purchase_timestamp,order_estimated_delivery_date)
	values(@orderid, @customerid, @devicetype, @orderstatus, @order_purchase_timestamp, @order_estimated_delivery_date)
End

