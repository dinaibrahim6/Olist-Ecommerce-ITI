use Olist_Ecommerce_DWHG;
go
-- Drop foreign key constraints if they exist
if exists (select * from sys.foreign_keys where name = 'fk_factorderitem_dimcustomer')
    alter table FactOrderItem drop constraint fk_factorderitem_dimcustomer;
go

if exists (select * from sys.foreign_keys where name = 'fk_factorderitem_dimseller')
    alter table FactOrderItem drop constraint fk_factorderitem_dimseller;
go

if exists (select * from sys.foreign_keys where name = 'fk_factorderitem_dimproduct')
    alter table FactOrderItem drop constraint fk_factorderitem_dimproduct;
go

if exists (select * from sys.foreign_keys where name = 'fk_factorderitem_purchase_date')
    alter table FactOrderItem drop constraint fk_factorderitem_purchase_date;
go

if exists (select * from sys.foreign_keys where name = 'fk_factorderitem_approved_date')
    alter table FactOrderItem drop constraint fk_factorderitem_approved_date;
go

if exists (select * from sys.foreign_keys where name = 'fk_factorderitem_carrier_date')
    alter table FactOrderItem drop constraint fk_factorderitem_carrier_date;
go

if exists (select * from sys.foreign_keys where name = 'fk_factorderitem_customer_date')
    alter table FactOrderItem drop constraint fk_factorderitem_customer_date;
go

if exists (select * from sys.foreign_keys where name = 'fk_factorderitem_estimated_date')
    alter table FactOrderItem drop constraint fk_factorderitem_estimated_date;
go

if exists (select * from sys.foreign_keys where name = 'fk_factorderitem_shipping_limit_date')
    alter table FactOrderItem drop constraint fk_factorderitem_shipping_limit_date;
go

-- Drop the FactOrderItem table if it exists
if exists (select * from sys.tables where name = 'FactOrderItem')
    drop table FactOrderItem;
go

-- Create the FactOrderItem table
create table FactOrderItem (
    order_id_sk int not null identity(1, 1),
    order_item_id int not null,
    order_id varchar(50) not null,
    price float not null,
    freight_value float not null,
    order_status varchar(20)  null,
    device_type varchar(10)  null,
	--foreignKeys
    customer_id_sk int null,
    seller_id_sk int  null,
    product_id_sk int null,
    review_id_sk int  null,
    order_purchase_timestamp_datekey int  null,
    order_approved_at_datekey int null,
    order_delivered_carrier_datekey int null,
    order_delivered_customer_datekey int null,
    order_estimated_delivery_datekey int null,
    shipping_limit_datekey int  null,
    is_current tinyint not null default (1),
    start_date datetime not null default (getdate()),
    end_date datetime null,
    constraint pk_factorderitem primary key clustered (order_id_sk),
    constraint fk_factorderitem_dimcustomer foreign key (customer_id_sk) references DimCustomer(customer_id_sk),
    constraint fk_factorderitem_dimseller foreign key (seller_id_sk) references DimSeller(seller_id_sk),
    constraint fk_factorderitem_dimproduct foreign key (product_id_sk) references DimProduct(product_id_sk),
	constraint fk_factorderitem_dimorderreview foreign key (review_id_sk) references DimOrderReview(review_id_sk),
    constraint fk_factorderitem_purchase_date foreign key (order_purchase_timestamp_datekey) references DimDate(DateSK),
    constraint fk_factorderitem_approved_date foreign key (order_approved_at_datekey) references DimDate(DateSK),
    constraint fk_factorderitem_carrier_date foreign key (order_delivered_carrier_datekey) references DimDate(DateSK),
    constraint fk_factorderitem_customer_date foreign key (order_delivered_customer_datekey) references DimDate(DateSK),
    constraint fk_factorderitem_estimated_date foreign key (order_estimated_delivery_datekey) references DimDate(DateSK),
    constraint fk_factorderitem_shipping_limit_date foreign key (shipping_limit_datekey) references DimDate(DateSK)
);
go

-- Drop the existing non-clustered index if it exists  to avoid conflicts.
if exists (select * from sys.indexes where name = 'idx_factorderitem_customer_id_sk' and object_id = object_id('FactOrderItem'))
    drop index idx_factorderitem_customer_id_sk on FactOrderItem;
go
if exists (select * from sys.indexes where name = 'idx_factorderitem_seller_id_sk' and object_id = object_id('FactOrderItem'))
    drop index idx_factorderitem_seller_id_sk on FactOrderItem;
go
if exists (select * from sys.indexes where name = 'idx_factorderitem_product_id_sk' and object_id = object_id('FactOrderItem'))
    drop index idx_factorderitem_product_id_sk on FactOrderItem;
go
if exists (select * from sys.indexes where name = 'idx_factorderitem_purchase_datekey' and object_id = object_id('FactOrderItem'))
    drop index idx_factorderitem_purchase_datekey on FactOrderItem;
go
---- Create a non-clustered index on (customer_id_sk,seller_id_sk,product_id_sk,order_purchase_timestamp_datekey) to improve query performance
create index idx_factorderitem_customer_id_sk on FactOrderItem(customer_id_sk);
create index idx_factorderitem_seller_id_sk on FactOrderItem(seller_id_sk);
create index idx_factorderitem_product_id_sk on FactOrderItem(product_id_sk);
create index idx_factorderitem_purchase_datekey on FactOrderItem(order_purchase_timestamp_datekey);
go

