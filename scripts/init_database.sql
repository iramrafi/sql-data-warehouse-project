/*
=====================================================================
  Create DataWarehouse Database and Multi-Layered Schemas (Bronze, Silver, Gold)
=====================================================================

Purpose:
    This script creates a new SQL Server database named 'DataWarehouse' 
    with a layered schema architecture: 'bronze', 'silver', and 'gold'.
    
    If the 'DataWarehouse' database already exists, it will be dropped 
    and recreated to ensure a clean setup.

WARNING:
    Executing this script will permanently delete the existing 'DataWarehouse' 
    database along with all its data. 
    Make sure you have appropriate backups before proceeding.

Layers Explained:
    - bronze: Raw or minimally processed data from source systems.
    - silver: Cleaned, standardized, or enriched data for analytics.
    - gold  : Final, curated datasets ready for reporting and BI tools.

=====================================================================
*/

USE master;
GO

-- Drop the 'DataWarehouse' database if it exists
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    -- Forces disconnect of all users and rolls back active transactions to safely drop the database.
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- Create a fresh 'DataWarehouse' database
CREATE DATABASE DataWarehouse;
GO

-- Switch context to the new database
USE DataWarehouse;
GO

-- Create multi-layered schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
