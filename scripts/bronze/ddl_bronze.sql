/*
===============================================================================
DDL Script: Define Bronze Layer Tables

Purpose:
    Drops and recreates all bronze schema tables used for raw data ingestion.
    Ensures a clean, controlled table structure before loading fresh data.
===============================================================================
*/

-- Drop and recreate bronze.crm_cust_info
IF OBJECT_ID(N'bronze.crm_cust_info', N'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;
GO

CREATE TABLE bronze.crm_cust_info (
    cst_id             INT,
    cst_key            NVARCHAR(50),
    cst_firstname      NVARCHAR(50),
    cst_lastname       NVARCHAR(50),
    cst_gndr           NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_create_date    DATE
);
GO

-- Drop and recreate bronze.crm_prd_info
IF OBJECT_ID(N'bronze.crm_prd_info', N'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;
GO

CREATE TABLE bronze.crm_prd_info (
    prd_id        INT,
    prd_key       NVARCHAR(50),
    prd_nm        NVARCHAR(50),
    prd_line      NVARCHAR(50),
    prd_cost      INT,
    prd_start_dt  DATETIME,
    prd_end_dt    DATETIME
);
GO

-- Drop and recreate bronze.crm_sales_details
IF OBJECT_ID(N'bronze.crm_sales_details', N'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;
GO

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num   NVARCHAR(50),
    sls_prd_key   NVARCHAR(50),
    sls_cust_id   INT,
    sls_order_dt  INT,
    sls_due_dt    INT,
    sls_ship_dt   INT,
    sls_quantity  INT,
    sls_price     INT,
    sls_sales     INT
);
GO

-- Drop and recreate bronze.erp_loc_a101
IF OBJECT_ID(N'bronze.erp_loc_a101', N'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;
GO

CREATE TABLE bronze.erp_loc_a101 (
    cid    NVARCHAR(50),
    cntry  NVARCHAR(50)
);
GO

-- Drop and recreate bronze.erp_cust_az12
IF OBJECT_ID(N'bronze.erp_cust_az12', N'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;
GO

CREATE TABLE bronze.erp_cust_az12 (
    cid    NVARCHAR(50),
    gen    NVARCHAR(50),
    bdate  DATE
);
GO

-- Drop and recreate bronze.erp_px_cat_g1v2
IF OBJECT_ID(N'bronze.erp_px_cat_g1v2', N'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;
GO

CREATE TABLE bronze.erp_px_cat_g1v2 (
    id           NVARCHAR(50),
    cat          NVARCHAR(50),
    subcat       NVARCHAR(50),
    maintenance  NVARCHAR(50)
);
GO
