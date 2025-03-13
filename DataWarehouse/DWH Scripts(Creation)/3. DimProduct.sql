use Olist_Ecommerce_DWHG

-- Drop foregin Keys if exists
 if exists (select * from sys.tables where name = 'FactOrderItem')
    alter table FactOrderItem
    drop constraint fk_factorderitem_dimproduct;
go
-- Check if the DimProduct table already exists, and drop it if it does
if exists (select *
           from   sys.tables
           where  name = 'DimProduct')
	drop table DimProduct;
go
-- Create Product Dimension Table (DimProduct)
create table DimProduct
  (
     product_id_sk  int not null identity(1, 1),  -- Surrogate key
     product_id  varchar(50) not null, -- Business key
	 product_name varchar(100) null,
	 product_category_name_English varchar(100) null ,
     product_category_name varchar(100) null ,
	 product_name_length int null ,
	 product_description_length	int null,
     product_photos_qty  int null,
	 product_weight_g int null,
	 product_length_cm int null,
	 product_height_cm int null, 
	 product_width_cm int null, 
	 brand_name varchar(20) null, 
	 brand_description varchar(100) null, 
	 brand_website varchar(50) null,
	 brand_status varchar(10) not null,
	 brand_tier varchar(10) not null, 
	 -- Slowly Changing Dimension (SCD Type 2)
	 is_current         tinyint not null DEFAULT (1),            -- SCD
	 start_date         datetime not null DEFAULT (Getdate()),   -- SCD
     end_date           datetime null,							 -- SCD
     constraint pk_dim_product PRIMARY KEY CLUSTERED (product_id_sk)
  );

-- Add Foreign Key Constraint for FactOrderItem
  if exists (select * from sys.tables where name = 'FactOrderItem')
    alter table FactOrderItem
    add constraint fk_factorderitem_dimproduct foreign key (product_id_sk)
    references DimProduct(product_id_sk);
go

-- Drop index if it already exists to avoid duplication
if exists (select * from sys.indexes where name = 'idx_dimproduct_product_id' and object_id = object_id('Dimproduct'))
    drop index DimProduct.idx_dimproduct_product_id;
go
if exists (select * from sys.indexes where name = 'idx_dimproduct_category' and object_id = object_id('Dimproduct'))
    drop index DimProduct.idx_dimproduct_category;
go
-- Creating non-clustered indexes on key columns (product_id, product_category_name_English) 
--    to enhance search efficiency and improve query execution speed.
create index idx_dimproduct_product_id on DimProduct(product_id);
create index idx_dimproduct_category on DimProduct(product_category_name_English);
go

