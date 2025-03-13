use Olist_Ecommerce_DWHG;
-- Drop Foreign Keys if Exists
if exists (select * from sys.foreign_keys where name = 'fk_factorderitem_dimorderreview')
    alter table FactOrderItem
    drop constraint fk_factorderitem_dimorderreview;
go

-- Drop Table if Exists
if exists (select * from sys.tables where name = 'DimOrderReview')
    drop table DimOrderReview;
go

-- Create Dimension Table: DimOrderReview

create table DimOrderReview (
    review_id_sk int not null identity(1,1),  -- surrogate key
    review_id varchar(50) not null,  -- business key
    order_id varchar(50) null,
    review_score int null,
    review_status varchar(10) null,
    review_creation_date datetime null,
    review_answer_timestamp datetime null,

    is_current tinyint not null default (1),  -- SCD Type 2
    start_date datetime not null default (getdate()),  -- SCD Start Date
    end_date datetime null,  -- SCD End Date

    constraint pk_dimorderreview primary key clustered (review_id_sk)
);
go


-- Add Foreign Key Constraint for FactOrderItem
if exists (select * from sys.tables where name = 'FactOrderItem')
    alter table FactOrderItem
    add constraint fk_factorderitem_dimorderreview foreign key (review_id_sk)
    references DimOrderReview(review_id_sk);
go


--  Dropping existing indexes if they already exist to avoid conflicts.

if exists (select * from sys.indexes where name = 'dimorderreview_review_id' and object_id = object_id('DimOrderReview'))
    drop index DimOrderReview.dimorderreview_review_id;
go

if exists (select * from sys.indexes where name = 'dimorderreview_review_score' and object_id = object_id('DimOrderReview'))
    drop index DimOrderReview.dimorderreview_review_score;
go

-- Creating non-clustered indexes on key columns ((review_id, order_id),review_score) 
--    to enhance search efficiency and improve query execution speed.
create index dimorderreview_review_id
on DimOrderReview(review_id,order_id);

create index dimorderreview_review_score
on DimOrderReview(review_score);
go
