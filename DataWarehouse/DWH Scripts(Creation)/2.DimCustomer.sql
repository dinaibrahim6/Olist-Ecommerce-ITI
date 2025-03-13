use Olist_Ecommerce_DWHG;

-- Drop foregin Keys if exists
if exists (select * from sys.tables where name = 'FactOrderItem')
    alter table FactOrderItem
    drop constraint fk_factorderitem_dimcustomer ;
go

if exists (select * from sys.tables where name = 'FactOrderPayments')
    alter table FactOrderPayments
    drop constraint fk_FactOrderPayments_customer_id_sk ;
go
-- drop the table if it exists
if exists (select * from sys.tables where name = 'DimCustomer')
	drop table DimCustomer;
go

-- create the dimension table (DimCustomer)
create table DimCustomer (
    customer_id_sk int not null identity(1,1),  -- surrogate key
    customer_id varchar(50) not null,  -- business key
    customer_zip_code_prefix int null,
    customer_city varchar(50) null,
    customer_state varchar(5) null,
    gender varchar(10) null,
    customer_login_type varchar(20) not null,
    age int  null,
    is_current tinyint not null default (1),  -- scd type 2
    start_date datetime not null default (getdate()),  -- scd
    end_date datetime null,  -- scd

    constraint pk_dim_customer primary key clustered (customer_id_sk)
);
go
-- Add Foreign Key Constraint for FactOrderItem
if exists (select * from sys.tables where name = 'FactOrderItem')
    alter table FactOrderItem
    add constraint fk_factorderitem_dimcustomer foreign key (customer_id_sk)
    references DimCustomer(customer_id_sk);
go
-- Add Foreign Key Constraint for FactOrderPayment
if exists (select * from sys.tables where name = 'FactOrderPayment')
    alter table FactOrderPayment
    add constraint fk_FactOrderPayments_customer_id_sk
	foreign key (customer_id_sk)
	references DimCustomer(customer_id_sk);

go

--  Dropping existing indexes if they already exist to avoid conflicts.
if exists (select * from sys.indexes where name = 'dimcustomer_customer_id' and object_id = object_id('DimCustomer'))
    drop index DimCustomer.dimcustomer_customer_id;
go
if exists (select * from sys.indexes where name = 'dimcustomer_customer_state' and object_id = object_id('DimCustomer'))
    drop index DimCustomer.dimcustomer_customer_state;
if exists (select * from sys.indexes where name = 'dimcustomer_customer_city' and object_id = object_id('DimCustomer'))
drop index DimCustomer.dimcustomer_customer_city;
go
 -- Creating non-clustered indexes on key columns (customer_id, customer_state, customer_city) 
--    to enhance search efficiency and improve query execution speed.
create index dimCustomer_customer_id
on Dimcustomer(customer_id);
create index dimCustomer_customer_state
on Dimcustomer(customer_state);
create index dimCustomer_customer_city
on Dimcustomer(customer_city);
go