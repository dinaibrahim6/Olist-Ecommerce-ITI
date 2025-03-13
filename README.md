# Olist-Ecommerce-ITI 

## Overview
Welcome! This project focuses on the **design and implementation of a database and data warehouse** for Olist, a Brazilian e-commerce platform. It aims to provide a structured approach for managing transactional data, supporting efficient query processing, and enabling advanced business intelligence solutions.

The dataset used in this project is a **Brazilian e-commerce public dataset** of orders made at Olist Store. It contains information on **100,000 orders** from **2016 to 2018** across multiple marketplaces in Brazil.

## Project Goals
- **Design and implement a relational database** (OLTP) to store and manage transactions efficiently.
- **Implement stored procedures, triggers, and views** to ensure data consistency and optimize performance.
- **Develop a data warehouse** (OLAP) for business intelligence and analytics.
- **Perform ETL processes** (Extract, Transform, Load) to clean, integrate, and prepare data for analysis.
- **Develop an SSAS Tabular Model** for multi-dimensional analysis and advanced reporting.
- **Create dashboards and reports using SSRS, Power BI, Excel, and Tableau** for data visualization and decision-making.

## Project Structure

## Database Design
### Entity-Relationship Diagram (ERD)
![ERD](https://github.com/dinaibrahim6/Olist-Ecommerce-ITI/blob/main/Database/ERD_and_Mapping/ERD.PNG)

### Mapping ERD to Relational Model
![Relational Model](https://github.com/dinaibrahim6/Olist-Ecommerce-ITI/blob/main/Database/ERD_and_Mapping/Olist%20E-commerce%20Mapping%20Schema.png)

### Database Diagram
![Database Diagram](https://github.com/dinaibrahim6/Olist-Ecommerce-ITI/blob/main/Database/ERD_and_Mapping/DB_Diagram.PNG)

## Database Programming

### Views
#### Sales and Product Performance Views
- `vw_sales_by_category`: Aggregates total sales by product category.
- `vw_product_performance`: Tracks sales, total orders, and units sold for each product.
- `vw_seller_performance`: Summarizes total revenue and item count per seller.
- `vw_top_selling_products`: Lists the top 10 best-selling products by revenue.

#### Time-Based Sales Summaries
- `vw_monthly_sales`: Summarizes total sales and order count per month.
- `Yearly_Sales_Summary`: Provides a yearly breakdown of orders, revenue, and average order value for delivered orders.

#### Customer and Order Insights
- `vw_customer_purchase`: Tracks customer purchases, including total spending and order details.
- `vw_high_value_customer`: Identifies customers who have spent over a defined threshold.
- `vw_pending_orders`: Lists orders that are still in processing or created status.

#### Delivery and Payment Analytics
- `vw_avg_delivery_days`: Calculates the average delivery time per seller.
- `vw_payment_summary`: Summarizes payment methods and total payment values.

#### Seller Performance Insights
- `vw_Top_sellers`: Lists the top 10 sellers by total revenue and items sold.

### Stored Procedures
- **GenerateSales**: Generates a sales report within a specified date range.

- **CustomerDemographics**: Provides demographic insights based on customer location and login type.

- **Product Performance**: Analyzes the sales performance of a specific product.
  
- **Seller Performance**: Evaluates a seller's performance based on orders, revenue, and units sold.
  
- **Customer Satisfaction**: Provides insights into customer satisfaction based on review scores.
  
- **Payment Methods**: Summarizes the usage of different payment methods within a given timeframe.
  
- **Customer Category**: Categorizes customers based on their login type within a given timeframe.
  
- **Monthly Sales**: Generates a sales report for a specific year, broken down by month.
  
- **Top-Selling Products**: Retrieves the top N selling products based on sales volume.
  
- **Insert Order with Data Validation**: Ensures customer existence before inserting an order.

### Triggers
- **Prevent Orders with Zero Value** (`prevent_order_zero_value`)
   - Ensures orders have a positive total value; rolls back transactions if value is zero or negative.

- **Prevent Custom Payment Values ≤ 10% of Order Value** (`prevent_wrong_payment`)
   - Ensures that a custom payment value is at least 10% of the total order value.

- **Enforce Review Creation After Order Completion** (`Review_After_Delivery`)
   - Ensures that reviews can only be created for completed orders.

- **Track Late Deliveries** (`log_late_deliveries`)
   - Logs late deliveries in `Late_Delivery_Log` if the actual delivery date exceeds the estimated delivery date.

- **Prevent Order Deletion** (`prevent_order_deletion`)
   - Prevents deletion of records from the Orders table.

- **Prevent Over-Payment** (`Prevent_Over_Payment`)
   - Ensures total payments for an order do not exceed the total order price.

#  Data Warehouse (DWH)

## Overview
This Data Warehouse is designed to support analytical processing for an e-commerce platform. It uses a **Galaxy Schema**, which consists of **two fact tables** and multiple **dimension tables**. The schema facilitates advanced reporting and analytics by efficiently handling large-scale transactional data.

## Why Do We Choose the Galaxy Schema?
In this e-commerce business model, we have two different levels of granularity in our transactional data:

- **Order Items Level (`Order_ItemsFact`)**: Each row represents an individual product in an order. A single order can contain multiple items.
- **Order Payments Level (`Order_PaymentsFact`)**: Payment details are stored at the order level, not at the item level.

### Why Not Use a Single Fact Table?
Using a single fact table would introduce **data redundancy** and **incorrect aggregations**, leading to:

- **Duplicated payment data** for each item in an order.
- **Overcounted metrics** such as total revenue and payment installments.
- **Complex and inefficient queries** when analyzing payments separately from orders.

By adopting a **Galaxy Schema**, we ensure a structured, scalable, and optimized data model for efficient analytics and reporting.

## Data Modeling:
- **Dimensional Modeling**

![Dimensional Modeling](https://github.com/dinaibrahim6/Olist-Ecommerce-ITI/blob/main/DataWarehouse/Dimensional%20Modeling/OIist_E-Commerce_DWH-Galaxy.jpg)

## Data Warehouse Implementation
**Data Warehouse Schema**

  The dimensional model was implemented in SSMS (SQL Server Management Studio) through SQL scripts. A diagram detailing the data warehouse schema is provided below.

![DWH Diagram](https://github.com/dinaibrahim6/Olist-Ecommerce-ITI/blob/main/DataWarehouse/DWH%20Schema/Schema.PNG)



## ETL Process

### Introduction

The **ETL (Extract, Transform, Load) process** is essential for transferring data from the operational database (**Olist_Ecommerce_DB**) to the data warehouse (**Olist_Ecommerce_DWH**). This process ensures that the data is **cleansed, transformed, and optimized** for analytical reporting.

### ETL Tool Used

We used **SQL Server Integration Services (SSIS)** to automate the ETL workflow, ensuring efficiency and accuracy in data movement.

### ETL Steps

1. **Extract**
   - Retrieve data from **Olist_Ecommerce_DB**.
   - Ensure completeness and accuracy before proceeding.

2. **Transform**
   - Cleanse and standardize data.
   - Apply business rules and data validation.
   - Implement **Slowly Changing Dimensions (SCD Type 2)** for historical tracking.

3. **Load**
   - Insert transformed data into **Olist_Ecommerce_DWH**.
   - Optimize indexing for fast query performance.

By leveraging **SSIS**, we ensure a seamless, automated, and efficient ETL process that enhances data consistency and supports business intelligence initiatives.

### ETL Process for Dimension Tables
- **DimCustomer**

  ![DimCustomer](https://github.com/dinaibrahim6/Olist-Ecommerce-ITI/blob/main/SSIS/ETL_Screens/DimCustomer.png)

- **DimProduct**
  
  ![DimProduct](https://github.com/dinaibrahim6/Olist-Ecommerce-ITI/blob/main/SSIS/ETL_Screens/DimProduct.PNG)

- **DimOrderReview**
  
  ![DimOrderReview](https://github.com/dinaibrahim6/Olist-Ecommerce-ITI/blob/main/SSIS/ETL_Screens/DimReviews.PNG)

- **DimSeller**

![DimOrderReview](https://github.com/dinaibrahim6/Olist-Ecommerce-ITI/blob/main/SSIS/ETL_Screens/DimSeller.PNG)


## ETL Process for Fact Tables

 - **FactOrderItem**
 
 ![FactOrderItem](https://github.com/dinaibrahim6/Olist-Ecommerce-ITI/blob/main/SSIS/ETL_Screens/FactOrderItem.PNG)

 - **FactOrderPayments**

  ![FactOrderPayments](https://github.com/dinaibrahim6/Olist-Ecommerce-ITI/blob/main/SSIS/ETL_Screens/FactOrderPayment.PNG)

  ## Data Warehouse Indexes

Indexes are used to optimize data warehouse query performance. The following tables and columns are indexed:

* **DimCustomer:**
    * `customer_id`: Accelerates lookups and joins.
    * `customer_state`: Optimizes searches by state.
    * `customer_city`: Improves filtering by city.
* **DimProduct:**
    * `product_id`: Speeds up lookups.
    * `product_category_name_English`: Improves filtering by category.
* **DimOrderReview:**
    * `review_id, order_id`: Ensures fast lookups and joins.
    * `review_score`: Speeds up queries that analyze scores.
* **DimSeller:**
    * `seller_id`: Optimizes joins.
    * `seller_city`: Enhances queries filtering by city.
    * `seller_name`: Speeds up searches.
* **FactOrderItem:**
    * `customer_id_sk`: Optimizes joins.
    * `seller_id_sk`: Speeds up lookups for seller-related transactions.
    * `product_id_sk`: Improves filtering based on products.
    * `order_purchase_timestamp_datekey`: Enhances performance for date-based queries.
* **FactOrderPayments:**
    * `order_id`: Speeds up searches.
    * `payment_sequential`: Optimizes filtering.
    * `payment_type`: Improves filtering by payment type.
 
  ## Handling Unknown or Missing Data
  To ensure data integrity and prevent foreign key violations, default records are used in the `DimOrderReview` and `DimDate` tables for missing or unknown data.

* **DimOrderReview:** A default record with `review_id_sk = -1` is used when an order lacks review data. This prevents errors and ensures consistency in joins and aggregations.
  
    ![MissValuesForReview](https://github.com/dinaibrahim6/Olist-Ecommerce-ITI/blob/main/SSIS/ETL_Screens/HandlingMissingValues2.PNG)
  
* **DimDate:** A default record with the date '1900-01-01' is used for missing dates, avoiding NULL-related errors in date-based queries.
  
    ![MissValuesForDate](https://github.com/dinaibrahim6/Olist-Ecommerce-ITI/blob/main/SSIS/ETL_Screens/HandlingMisingValues.PNG)

This approach maintains data integrity and facilitates smooth ETL processing.

## SSAS Tabular Model 

This stage involved the development of a SQL Server Analysis Services (SSAS) Tabular Model for the Olist E-commerce project. The SSAS Tabular Model was implemented to provide enhanced data analysis and Online Analytical Processing (OLAP) capabilities. This enables efficient reporting, trend analysis, and the generation of business intelligence insights.

  ![SSAS model](https://github.com/dinaibrahim6/Olist-Ecommerce-ITI/blob/main/SSAS/SSAS-Screens/Model.png)

**Reasons for Choosing SSAS Tabular Model**

The SSAS Tabular Model was selected over the SSAS Multidimensional Model due to several advantages:

1.  **Performance and Speed:** The Tabular Model utilizes VertiPaq compression and in-memory processing, resulting in improved query performance, even with large datasets. 
2.  **Ease of Development:** Compared to the multidimensional model, the Tabular Model offers easier design and implementation, requiring less complex data modeling. 
3.  **DAX for Powerful Calculations:** The Data Analysis Expressions (DAX) language enables dynamic aggregations, Key Performance Indicators (KPIs), and time intelligence functions, providing greater flexibility in analytics. 
4.  **Seamless Power BI Integration:** The Tabular Model offers direct integration with Power BI, Excel, and other reporting tools, facilitating the creation of real-time interactive dashboards. 

**Model Components**

* **Data Sources and Integration:** The model integrates data from various sources, including order transactions, customer demographics, seller information, product categories, and payment details. Data is extracted from transactional databases, preprocessed using SQL Server, and organized in a Galaxy schema to optimize querying.
* **Model Implementation:**
    * **Tables and Relationships:** The model comprises fact tables, such as FactOrders, FactPayments, and FactReviews, along with dimension tables, including DimCustomers, DimSellers, DimProducts, and DimDates. 
    * **Measures and KPIs:** DAX measures were developed to calculate and analyze key business metrics. 

 

 
  




