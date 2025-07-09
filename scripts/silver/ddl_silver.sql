/*

DDL Script: Define silver Layer Tables

Purpose:
    Drops and recreates all silver schema tables used for raw data ingestion.
    Ensures a clean, controlled table structure before loading fresh data.

*/

-- Drop and recreate silver.crm_cust_info
IF OBJECT_ID(N'silver.crm_cust_info', N'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;
GO

CREATE TABLE silver.crm_cust_info (
    cst_id             INT,
    cst_key            NVARCHAR(50),
    cst_firstname      NVARCHAR(50),
    cst_lastname       NVARCHAR(50),
    cst_gndr           NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_create_date    DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

-- Drop and recreate silver.crm_prd_info
IF OBJECT_ID(N'silver.crm_prd_info', N'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;
GO

CREATE TABLE silver.crm_prd_info (
    prd_id        INT,
	cat_id        NVARCHAR(50),
    prd_key       NVARCHAR(50),
    prd_nm        NVARCHAR(50),
    prd_line      NVARCHAR(50),
    prd_cost      INT,
    prd_start_dt  DATE,
    prd_end_dt    DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()

);
GO

-- Drop and recreate silver.crm_sales_details
IF OBJECT_ID(N'silver.crm_sales_details', N'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;
GO

CREATE TABLE silver.crm_sales_details (
    sls_ord_num   NVARCHAR(50),
    sls_prd_key   NVARCHAR(50),
    sls_cust_id   INT,
    sls_order_dt  DATE,
    sls_due_dt    DATE,
    sls_ship_dt   DATE,
    sls_quantity  INT,
    sls_price     INT,
    sls_sales     INT,
	dwh_create_date DATETIME2 DEFAULT GETDATE()

);
GO

-- Drop and recreate silver.erp_loc_a101
IF OBJECT_ID(N'silver.erp_loc_a101', N'U') IS NOT NULL
    DROP TABLE silver.erp_loc_a101;
GO

CREATE TABLE silver.erp_loc_a101 (
    cid    NVARCHAR(50),
    cntry  NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()

);
GO

-- Drop and recreate silver.erp_cust_az12
IF OBJECT_ID(N'silver.erp_cust_az12', N'U') IS NOT NULL
    DROP TABLE silver.erp_cust_az12;
GO

CREATE TABLE silver.erp_cust_az12 (
    cid    NVARCHAR(50),
    gen    NVARCHAR(50),
    bdate  DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()

);
GO

-- Drop and recreate silver.erp_px_cat_g1v2
IF OBJECT_ID(N'silver.erp_px_cat_g1v2', N'U') IS NOT NULL
    DROP TABLE silver.erp_px_cat_g1v2;
GO

CREATE TABLE silver.erp_px_cat_g1v2 (
    id           NVARCHAR(50),
    cat          NVARCHAR(50),
    subcat       NVARCHAR(50),
    maintenance  NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()

);
GO
