--Retrieve missing geolocation rows from customer table:
select distinct c.customer_zip_code_prefix, c.customer_city, c.customer_state
from Customers c
left join Geolocation g 
    on c.customer_zip_code_prefix = g.geolocation_zip_code_prefix 
    and c.customer_city = g.geolocation_city 
    and c.customer_state = g.geolocation_state
where g.geolocation_zip_code_prefix is null

--Insert missing geolocation rows:
insert into Geolocation (geolocation_zip_code_prefix, geolocation_city, geolocation_state)
select distinct c.customer_zip_code_prefix, c.customer_city, c.customer_state
from Customers c
left join Geolocation g 
    on c.customer_zip_code_prefix = g.geolocation_zip_code_prefix 
    and c.customer_city = g.geolocation_city 
    and c.customer_state = g.geolocation_state
where g.geolocation_zip_code_prefix is null

--Retrieve missing geolocation rows from seller table:
select distinct s.seller_zip_code_prefix, s.seller_city, s.seller_state
from Sellers s
left join Geolocation g 
    on s.seller_zip_code_prefix = g.geolocation_zip_code_prefix 
    and s.seller_city = g.geolocation_city 
    and s.seller_state = g.geolocation_state
where g.geolocation_zip_code_prefix is null

--Insert missing geolocation rows:
insert into Geolocation (geolocation_zip_code_prefix, geolocation_city, geolocation_state)
select distinct s.seller_zip_code_prefix, s.seller_city, s.seller_state
from Sellers s
left join Geolocation g 
    on s.seller_zip_code_prefix = g.geolocation_zip_code_prefix 
    and s.seller_city = g.geolocation_city 
    and s.seller_state = g.geolocation_state
where g.geolocation_zip_code_prefix is null

--update customers login_type:
update Customers 
set Customer_Login_type = 'First Sign Up'
where Customer_Login_type ='First SignUp'