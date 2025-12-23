/*
=============================================================
Create Database and Schemas
=============================================================

Script Purpose 
		This script creates a new Database called 'DataWarehouse' after checking if it already exists.
		If the database exists, dropped it and recreated it. Additionally the scripts sets up three schemas
		within the database: 'bronze', 'silver', 'gold'.

Warning:-
		Running this script will drop the entire 'Datawarehouse' database if it exists.
		All data in the database will be deleted permanently. proceed with caution and ensure
		you have proper backups before running the script.
*/

Use master;
go


--	Drop and recreate the 'Datawarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases where name = 'Datawarehouse')
Begin
	Alter DATABASE Datawarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE Datawarehouse;
END;
GO


-- create DataBase 'Data Warehouse'
CREATE DATABASE DataWarehouse;
GO

use DataWarehouse;

-- Create Schemas
CREATE SCHEMA bronze;
GO


CREATE SCHEMA silver;
GO


CREATE SCHEMA gold;
GO
