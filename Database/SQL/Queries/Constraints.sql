-- Add constraints to Customers table:
alter table Customers
add constraint check_age check (Age >= 18)

alter table Customers
add constraint check_gender check (Gender in ('Male', 'Female'))

alter table Customers
add constraint check_login check (Customer_Login_type in ('Member', 'New', 'First Sign Up', 'Guest'))

alter table Customers
drop constraint FK_Customers_Geolocation

alter table Customers
add constraint FK_Customers_Geolocation foreign key (customer_zip_code_prefix, Customer_city, Customer_state)
references Geolocation (geolocation_zip_code_prefix, geolocation_city, geolocation_state) on update cascade 


-- Add constraints to Sellers table:
alter table Sellers
drop constraint FK_Sellers_Geolocation

alter table Sellers
add constraint FK_Sellers_Geolocation foreign key (seller_zip_code_prefix, seller_city, seller_state)
references Geolocation (geolocation_zip_code_prefix, geolocation_city, geolocation_state) on update cascade 


-- Add constraints to Brand table:
alter table Brand 
add constraint check_status check (brand_status in ('active','inactive'))

alter table Brand 
add constraint check_tier check (brand_tier in ('standard','premium'))

alter table Brand 
add constraint defualt_country default 'Brazil' for brand_country 


-- Add constraints to Products table:
alter table Products
drop constraint FK_Products_Brand

alter table Products
add constraint FK_Products_Brand foreign key (brand_id)
references Brand (brand_id) on update cascade 


-- Add constraints to Orders table:
alter table Orders
add constraint check_DeviceType check (Device_Type in ('Web', 'Mobile'))

alter table Orders
add constraint check_Orderstatus check (Order_Status in ('approved', 'canceled','created','invoiced','delivered','shipped','processing','unavailable'))

alter table Orders
drop constraint FK_Orders_Customers

alter table Orders
add constraint FK_Orders_Customers foreign key (customer_unique_id)
references Customers (customer_unique_id) on update cascade 


-- Add constraints to order_items table:
alter table Order_Items
add constraint check_price check (price > 0)

alter table Order_Items
add constraint check_freight check (Freight_value >= 0)

alter table Order_Items
drop constraint FK_Order_Items_Sellers

alter table Order_Items
add constraint FK_Order_Items_Sellers foreign key (seller_id)
references Sellers (seller_id) on update cascade 

alter table Order_Items
drop constraint FK_Order_Items_Products

alter table Order_Items
add constraint FK_Order_Items_Products foreign key (product_id)
references Products (product_id) on update cascade 


-- Add constraints to order_Reviews table:
alter table Order_Reviews
add constraint check_Score check (review_score in (1,2,3,4,5))

alter table Order_Reviews
add constraint check_Review_status check (Review_Status in ('positive','negative'))


-- Add constraints to Order_Payments table:
alter table Order_Payments
add constraint check_Sequential check (payment_sequential > 0)

alter table Order_Payments
add constraint check_paytype check (payment_type in ('credit_card','boleto','voucher','not_defined','debit_card'))



