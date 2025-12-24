/*
============================================================================================
Stored Procedure: Load Silver Layer (Bronze - > Silver)
============================================================================================
Script Purpose:
		This stored procedure loads data into the 'Silver' schema from external CSV Files.
		It performs the following actions:
		- Truncates the silver tables before loading.
		- Uses the 'BULK INSERT' command to load data from csv files to silver tables.

Parameters:
		None.
		This stored procedure does not accept any parameters or returns any values.

Usage example:
		EXEC silver.load_silver;
============================================================================================
*/


CREATE OR ALTER PROCEDURE silver.load_silver AS  -- CREATION OF STORE PROCEDURE.
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY  -- THE CODE BLOCK WHICH CAN GIVE ERROR IS PUT INSIDE THIS BLOCK.

		SET @batch_start_time = GETDATE();
		PRINT '=================================================================';
		PRINT 'Loading Silver Layer';
		PRINT '=================================================================';

		PRINT '-----------------------------------------------------------------';
		PRINT ' Loading CRM Tables';
		PRINT '-----------------------------------------------------------------';


		-- loading silver.crm_cust_info
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: Silver.crm_cust_info';
		Truncate Table silver.crm_cust_info;
		Print'>> Inserting Data into silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_first_name,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date)
		select cst_id,
				cst_key,
				trim(cst_first_name) as cst_firstname,
				trim(cst_lastname) as cst_lastname,
				CASE
					WHEN upper(trim(cst_marital_status)) = 'S' THEN 'Single'
					WHEN upper(trim(cst_marital_status)) = 'M' Then 'Married'
					else 'n/a'
				end cst_marital_status,
				CASE 
					When upper(trim(cst_gndr)) = 'M' THEN 'Male'
					When upper(trim(cst_gndr)) = 'F' Then 'Female'
					else 'n/a'
				end cst_gndr,
				cst_create_date
		from (select *,
		ROW_NUMBER() over(partition by cst_id order by cst_create_date desc) as flag_last
		from bronze.crm_cust_info
		) t where flag_last = 1 and cst_id is not null;
		SET @end_time = GETDATE();
		PRINT'>> Load Duration: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '--------------------------------------';


		-- loading silver.crm_prd_info
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_prd_info';
		Truncate Table silver.crm_prd_info;
		Print'>> Inserting Data into silver.crm_prd_info';
		INSERT INTO silver.crm_prd_info (
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
		)
		select 
			prd_id,
			REPLACE(SUBSTRING(prd_key, 1, 5), '-' , '_') AS cat_id, -- extract category ID
			SUBSTRING(prd_key, 7, LEN(prd_key))	as prd_key, -- Extract product key
			prd_nm,
			isnull(prd_cost,0) AS prd_cost,
			CASE upper(trim(prd_line))
				When 'M' Then 'Mountain'
				When 'R' Then 'Road'
				When 'S' Then 'Other Sales'
				When 'T' Then 'Touring'
				else 'n/a'
			END AS prd_line,
			CAST(prd_start_dt AS DATE) AS prd_start_dt,
			CAST(LEAD(prd_start_dt) over(partition by prd_key order by prd_start_dt)-1 as DATE) AS prd_end_dt
		from bronze.crm_prd_info
		SET @end_time = GETDATE();
		PRINT'>> Load Duration: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '--------------------------------------';


		-- loading silver.crm_sales_details
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_sales_details';
		Truncate Table silver.crm_sales_details;
		Print'>> Inserting Data into silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details(
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price
		)
		select 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE
				WHEN sls_order_dt = 0 or len(sls_order_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS varchar) AS DATE)
			END AS sls_order_dt,
			CASE
				WHEN sls_ship_dt = 0 or len(sls_ship_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS varchar) AS DATE)
			END AS sls_ship_dt,
			CASE
				WHEN sls_due_dt = 0 or len(sls_due_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_due_dt AS varchar) AS DATE)
			END AS sls_due_dt,
			CASE
			WHEN sls_sales  is null or sls_sales <= 0 or sls_sales != sls_quantity * ABS(sls_price)
				Then sls_quantity * ABS(sls_price)
				else sls_sales
		END AS sls_sales, -- recalculate sales if original value is missing or incorrect.
			sls_quantity,
			CASE
			WHEN sls_price is null or sls_price <= 0 
			THEN sls_sales	/ NULLIF(sls_quantity, 0)
			else sls_price
		END as sls_price
		from bronze.crm_sales_details
		SET @end_time = GETDATE();
		PRINT'>> Load Duration: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '--------------------------------------';



		PRINT '-----------------------------------------------------------------';
		PRINT ' Loading ERP Tables';
		PRINT '-----------------------------------------------------------------';

		-- loading silver.erp_cust_az12
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_cust_az12';
		Truncate Table silver.erp_cust_az12;
		Print'>> Inserting Data into silver.erp_cust_az12';
		Insert into silver.erp_cust_az12 (cid, bdate, gen)
		select 
		CASE
		WHEN cid like 'NAS%' THEN SUBSTRING(cid, 4, len(cid))
		else cid
		end as cid,
		CASE 
			WHEN bdate > getdate() then Null
			ELSE bdate
		END AS bdate,
		CASE
			WHEN upper(trim(gen)) in ('F', 'FEMALE') then 'Female'
			WHEN upper(trim(gen)) in ('M', 'MALE') then 'Male'
			ELSE 'n/a'
		END AS gen
		from bronze.erp_cust_az12
		SET @end_time = GETDATE();
		PRINT'>> Load Duration: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '--------------------------------------';


		-- loading silver.erp_loc_a101
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_loc_a101';
		Truncate Table silver.erp_loc_a101;
		Print'>> Inserting Data into silver.erp_loc_a101';
		Insert into silver.erp_loc_a101
		(cid, cntry)
		select 
		replace(cid, '-', '') cid,
		CASE 
			WHEN TRIM(cntry) = 'DE' THEN 'Germany'
			WHEN TRIM(cntry) in ('US', 'USA') Then 'United States'
			WHEN TRIM(cntry) = '' or cntry is NULL THEN 'n/a'
			ELSE TRIM(cntry)
		END AS cntry
		from bronze.erp_loc_a101
		SET @end_time = GETDATE();
		PRINT'>> Load Duration: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '--------------------------------------';


		-- loading silver.erp_px_cat_g1v2
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
		Truncate Table silver.erp_px_cat_g1v2;
		Print'>> Inserting Data into silver.erp_px_cat_g1v2';
		insert into silver.erp_px_cat_g1v2
		(id, cat, subcat, maintenance)
		select 
		id,
		cat,
		subcat,
		maintenance
		from bronze.erp_px_cat_g1v2;
		SET @end_time = GETDATE();
		PRINT'>> Load Duration: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '--------------------------------------';


		SET @batch_end_time = GETDATE();
		PRINT '====================================================================';
		PRINT 'Loading Bronze layer is completed';
		PRINT '====================================================================';


		PRINT 'Total Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '====================================================================';

	END TRY   -- THE CODE BLOCK WHICH CAN GIVE ERROR IS PUT INSIDE THIS BLOCK.
	BEGIN CATCH  -- THIS IS USED TO SHOW / HANDLE ERRORS.
		PRINT '======================================================';
		PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' +  CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=======================================================';
	END CATCH  -- THIS IS USED TO SHOW / HANDLE ERRORS.
END  -- USED TO GROUP MULTIPLE SQL QUERIES IN A UNIT.





