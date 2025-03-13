use Olist_Ecommerce_DWHG

-- If the FactOrderItem table exists, drop the foreign key constraint that references DimSeller
if exists (select * from sys.tables where name = 'FactOrderItem')
    alter table FactOrderItem
    drop CONSTRAINT fk_factorderitem_dimseller;
go

-- Drop the DimSeller table if it exists
if exists (select *
           from   sys.tables
           where  name = 'DimSeller')
	drop table DimSeller;
go
-- Create the DimSeller table (Dimension Table for Sellers)
create table DimSeller
  (
     seller_id_sk  int not null identity(1, 1),             -- Surrogate key
     seller_id  varchar(50) not null,                        -- Business key
     seller_zip_code_prefix int null ,
	 seller_city varchar(50) null ,
	 seller_state	varchar(5) null,
     seller_name  varchar(50) not null,
	 is_current         tinyint not null DEFAULT (1),            -- SCD
	 start_date         datetime not null DEFAULT (Getdate()),   -- SCD
     end_date           datetime null,							 -- SCD
     constraint pk_dim_seller PRIMARY KEY CLUSTERED (seller_id_sk)
  );
-- If FactOrderItem exists, re-add the foreign key constraint referencing DimSeller
if exists (select * from sys.tables where name = 'FactOrderItem')
    alter table FactOrderItem
    add CONSTRAINT fk_factorderitem_dimseller FOREIGN KEY (seller_id_sk)
	REFERENCES DimSeller(seller_id_sk);
go
-- Drop the existing non-clustered index on DimSeller if it exists  to avoid conflicts.
if exists (select * from sys.indexes where name = 'dimseller_seller_id' and object_id = object_id('DimSeller'))
    drop index DimSeller.dimseller_seller_id;
if exists (select * from sys.indexes where name = 'dimseller_seller_city' and object_id = object_id('DimSeller'))
drop index DimSeller.dimseller_seller_city;
if exists (select * from sys.indexes where name = 'dimseller_seller_name' and object_id = object_id('DimSeller'))
    drop index DimSeller.dimseller_seller_name;
go
-- Create a non-clustered index on (seller_id,seller_city,seller_name) to improve query performance
create index dimseller_seller_id
on DimSeller(seller_id);
create index dimseller_seller_city
on DimSeller(seller_city);
create index dimseller_seller_name
on DimSeller(seller_name);
go