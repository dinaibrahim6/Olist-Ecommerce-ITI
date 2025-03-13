use Olist_Ecommerce_DWHG;
go
-- drop foreign keys if they exist
if exists (select * from sys.foreign_keys where name = 'fk_FactOrderPayments_customer_id_sk')
    alter table FactOrderPayments drop constraint fk_FactOrderPayments_customer_id_sk;
go

if exists (select * from sys.foreign_keys where name = 'fk_FactOrderPayments_order_purchase_datekey')
    alter table FactOrderPayments drop constraint fk_FactOrderPayments_order_purchase_datekey;
go

-- drop table if exists
if exists (select * from sys.tables where name = 'FactOrderPayments')
    drop table FactOrderPayments;
go

-- create FactOrderPayments table
create table FactOrderPayments (
    orderpayment_id_sk int not null identity(1,1),  -- surrogate key
    order_id varchar(50) not null,                  -- business key
    payment_sequential int not null,                -- business key
    customer_id_sk int null,                        -- foreign key to DimCustomer
    order_purchase_datekey int null,               -- date key for order purchase
    order_status varchar(20) null, 
    device_type varchar(10) null,
    payment_type varchar(20) null,                  
    payment_installments int not null,                 
    bank_name varchar(50) null,                   
    payment_value float not null,             

    -- scd type 2 columns
    is_current tinyint not null default (1),       -- indicates current record (1 = current, 0 = historical)
    start_date datetime not null default (getdate()), -- start date for scd
    end_date datetime null,                        -- end date for scd

    -- primary key constraint
    constraint pk_FactOrderPayments primary key clustered (orderpayment_id_sk)
);
go

-- add foreign key constraints
alter table FactOrderPayments
add constraint fk_FactOrderPayments_customer_id_sk
foreign key (customer_id_sk) references DimCustomer(customer_id_sk);
go

alter table FactOrderPayments
add constraint fk_FactOrderPayments_order_purchase_datekey
foreign key (order_purchase_datekey) references DimDate(DateSK);
go

-- drop indexes if they exist

if exists (select * from sys.indexes where name = 'idx_FactOrderPayments_order_id' and object_id = object_id('FactOrderPayments'))
    drop index idx_FactOrderPayments_order_id on FactOrderPayments;
go

if exists (select * from sys.indexes where name = 'idx_FactOrderPayments_payment_sequential' and object_id = object_id('FactOrderPayments'))
    drop index idx_FactOrderPayments_payment_sequential on FactOrderPayments;
go

if exists (select * from sys.indexes where name = 'idx_FactOrderPayments_order_status_payment_type' and object_id = object_id('FactOrderPayments'))
    drop index idx_FactOrderPayments_payment_type on FactOrderPayments;
go

-- create non-clustered indexes (order_id,payment_sequential
create nonclustered index idx_FactOrderPayments_order_id
on FactOrderPayments (order_id);
go

create nonclustered index idx_FactOrderPayments_payment_sequential
on FactOrderPayments (payment_sequential);
go

create nonclustered index idx_FactOrderPayments_payment_type
on FactOrderPayments ( payment_type);
go

