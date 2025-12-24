/*
============================================================================================
Stored Procedure: Load Bronze Layer (Source - > Bronze)
============================================================================================
Script Purpose:
		This stored procedure loads data into the 'bronze' schema from external CXS Files.
		It performs the following actions:
		- Truncates the bronze tables before loading.
		- Uses the 'BULK INSERT' command to load data from csv files to bronze tables.

Parameters:
		None.
		This stored procedure does not accept any parameters or returns any values.

Usage example:
		EXEC bronze.load_bronze;
============================================================================================
*/
EXEC bronze.load_bronze; -- STORE PROCEDURE.

CREATE OR ALTER PROCEDURE bronze.load_bronze AS  -- CREATION OF STORE PROCEDURE.
BEGIN -- USED TO GROUP MULTIPLE SQL QUERIES IN A UNIT.

	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY -- THE CODE BLOCK WHICH CAN GIVE ERROR IS PUT INSIDE THIS BLOCK.
		SET @batch_start_time = GETDATE();
		PRINT '=================================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '=================================================================';

		PRINT '-----------------------------------------------------------------';
		PRINT ' Loading CRM Tables';
		PRINT '-----------------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;
		PRINT '>> Inserting into Table: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		from 'C:\Users\user\Data Analyst projects and Classes\EDA & Python\Portfolio Projects\SQL Warehouse Project files\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		SET @end_time = GETDATE();
		PRINT'>> Load Duration: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '--------------------------------------';


		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;
		PRINT '>> Inserting into Table: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		from 'C:\Users\user\Data Analyst projects and Classes\EDA & Python\Portfolio Projects\SQL Warehouse Project files\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS Nvarchar) + ' seconds';
		PRINT '--------------------------------------';


		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;
		PRINT '>> Inserting into Table: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		from 'C:\Users\user\Data Analyst projects and Classes\EDA & Python\Portfolio Projects\SQL Warehouse Project files\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS Nvarchar) + ' seconds';
		PRINT '--------------------------------------';




		PRINT '-----------------------------------------------------------------';
		PRINT ' Loading ERP Tables';
		PRINT '-----------------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;
		PRINT '>> Inserting into Table: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		from 'C:\Users\user\Data Analyst projects and Classes\EDA & Python\Portfolio Projects\SQL Warehouse Project files\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS Nvarchar) + ' seconds';
		PRINT '--------------------------------------';


		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;
		PRINT '>> Inserting into Table: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		from 'C:\Users\user\Data Analyst projects and Classes\EDA & Python\Portfolio Projects\SQL Warehouse Project files\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS Nvarchar) + ' seconds';
		PRINT '--------------------------------------';


		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		PRINT '>> Inserting into Table: bronze.px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		from 'C:\Users\user\Data Analyst projects and Classes\EDA & Python\Portfolio Projects\SQL Warehouse Project files\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS Nvarchar) + ' seconds';
		PRINT '--------------------------------------';

		SET @batch_end_time = GETDATE();
		PRINT '====================================================================';
		PRINT 'Loading Bronze layer is completed';

		PRINT 'Total Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '====================================================================';
	END TRY  -- THE CODE BLOCK WHICH CAN GIVE ERROR IS PUT INSIDE THIS BLOCK.
	BEGIN CATCH -- THIS IS USED TO SHOW / HANDLE ERRORS.
		PRINT '======================================================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' +  CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=======================================================';
	END CATCH -- THIS IS USED TO SHOW / HANDLE ERRORS.

END -- USED TO GROUP MULTIPLE SQL QUERIES IN A UNIT.
