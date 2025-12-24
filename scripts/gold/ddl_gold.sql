/*
========================================================================================================================
DDL Script: Create Gold Views
========================================================================================================================
Script Purpose:
		This script creates views for the GOld layer in the data warehouse.
		The Gold layer represents the final	dimesnion and fact tables (star Schema)
		
		Each view performs transformations and combines data from silver layer
		to produce a clean, enriched, and business-ready dataset.

Usage: 
		These views can be queried quickly for analytics and reporting.
========================================================================================================================
*/


-- =====================================================================================================================
-- Create Dimension: gold.dim_customers
-- =====================================================================================================================

if OBJECT_ID ('gold.dim_customers', 'V') is not null
		DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
select 
	ROW_NUMBER() over(order by cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_first_name AS first_name,
	ci.cst_lastname AS last_name,
	la.cntry AS country,
	ci.cst_marital_status AS marital_status,
	case
		when ci.cst_gndr != 'n/a' Then ci.cst_gndr
		else coalesce(ca.gen, 'n/a')
	end as gender,
	ca.bdate AS birthdate,
	ci.cst_create_date AS create_date
from silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON      ci.cst_key = ca.cid	
LEFT JOIN silver.erp_loc_a101 la
ON		ci.cst_key = la.cid

---------------------------------------------------------------------------------------------------------------------------------
GO
-- =====================================================================================================================
-- Create Dimension: gold.dim_products
-- =====================================================================================================================

if OBJECT_ID ('gold.dim_products', 'V') is not null
		DROP VIEW gold.dim_products;
GO
CREATE VIEW gold.dim_products AS
SELECT
ROW_NUMBER() OVER(order by pn.prd_start_dt,pn.prd_key) as product_key,
pn.prd_id AS product_id,
pn.prd_key as product_number,
pn.prd_nm as product_name,
pn.cat_id as category_id,
pc.cat as category,
pc.subcat as subcategory,
pc.maintenance,
pn.prd_cost as cost,
pn.prd_line as product_line,
pn.prd_start_dt as start_date
FROM silver.crm_prd_info pn
LEFT Join silver.erp_px_cat_g1v2 pc
ON  pn.cat_id = pc.id
where prd_end_dt is null; -- filter out all the historical data.
GO
-------------------------------------------------------------------------------------------------------
-- =====================================================================================================================
-- Create Dimension: gold.fact_sales
-- =====================================================================================================================

if OBJECT_ID ('gold.fact_salest', 'V') is not null
		DROP VIEW gold.fact_sales;

GO
Create VIEW gold.fact_sales AS
select 
sd.sls_ord_num AS order_number,
pr.product_key,
cu.customer_key,
sd.sls_order_dt as order_date,
sd.sls_ship_dt as shipping_date,
sd.sls_due_dt as due_date,
sd.sls_sales as sales_amount,
sd.sls_quantity as quantity,
sd.sls_price as price
from silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
ON sd.sls_cust_id = cu.customer_id
 
Go















