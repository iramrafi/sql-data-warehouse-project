/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
Purpose:
    Loads data into the 'bronze' schema from external CSV files.

    Actions Performed:
    - Truncates each bronze table before loading
    - Loads data from .csv files using BULK INSERT
    - Tracks and prints the duration of each load step

Parameters:
    None

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    -- Declare variables to track time for performance logging
    DECLARE @start_time DATETIME, @end_time DATETIME;
    DECLARE @batch_start_time DATETIME, @batch_end_time DATETIME;

    BEGIN TRY
        -------------------------------------------------------------------
        -- Start the batch and print initial log
        -------------------------------------------------------------------
        SET @batch_start_time = GETDATE();
        PRINT '::: Starting Bronze Layer Load :::';
        PRINT '--------------------------------------------';

        -------------------------------------------------------------------
        -- CRM TABLES LOAD SECTION
        -------------------------------------------------------------------
        PRINT '::: Loading CRM Tables :::';

        -- Load data into bronze.crm_cust_info
        SET @start_time = GETDATE();
        PRINT '--> Truncating Table: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT '--> Loading data from cust_info.csv';
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\sql\dwh_project\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,               -- Skip header row
            FIELDTERMINATOR = ',',      -- CSV delimiter
            TABLOCK                     -- Lock table for performance
        );
        SET @end_time = GETDATE();
        PRINT CONCAT('--> Load Duration: ', DATEDIFF(SECOND, @start_time, @end_time), ' seconds');

        -- Load data into bronze.crm_prd_info
        SET @start_time = GETDATE();
        PRINT '--> Truncating Table: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT '--> Loading data from prd_info.csv';
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\sql\dwh_project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT CONCAT('--> Load Duration: ', DATEDIFF(SECOND, @start_time, @end_time), ' seconds');

        -- Load data into bronze.crm_sales_details
        SET @start_time = GETDATE();
        PRINT '--> Truncating Table: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT '--> Loading data from sales_details.csv';
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\sql\dwh_project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT CONCAT('--> Load Duration: ', DATEDIFF(SECOND, @start_time, @end_time), ' seconds');

        -------------------------------------------------------------------
        -- ERP TABLES LOAD SECTION
        -------------------------------------------------------------------
        PRINT '::: Loading ERP Tables :::';

        -- Load data into bronze.erp_loc_a101
        SET @start_time = GETDATE();
        PRINT '--> Truncating Table: bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT '--> Loading data from loc_a101.csv';
        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\sql\dwh_project\datasets\source_erp\loc_a101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT CONCAT('--> Load Duration: ', DATEDIFF(SECOND, @start_time, @end_time), ' seconds');

        -- Load data into bronze.erp_cust_az12
        SET @start_time = GETDATE();
        PRINT '--> Truncating Table: bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT '--> Loading data from cust_az12.csv';
        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\sql\dwh_project\datasets\source_erp\cust_az12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT CONCAT('--> Load Duration: ', DATEDIFF(SECOND, @start_time, @end_time), ' seconds');

        -- Load data into bronze.erp_px_cat_g1v2
        SET @start_time = GETDATE();
        PRINT '--> Truncating Table: bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT '--> Loading data from px_cat_g1v2.csv';
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\sql\dwh_project\datasets\source_erp\px_cat_g1v2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT CONCAT('--> Load Duration: ', DATEDIFF(SECOND, @start_time, @end_time), ' seconds');

        -------------------------------------------------------------------
        -- Batch Completion Log
        -------------------------------------------------------------------
        SET @batch_end_time = GETDATE();
        PRINT '==========================================';
        PRINT 'Bronze Layer Load Completed Successfully';
        PRINT CONCAT('Total Load Time: ', DATEDIFF(SECOND, @batch_start_time, @batch_end_time), ' seconds');
        PRINT '==========================================';
    END TRY

    BEGIN CATCH
        -------------------------------------------------------------------
        -- Error Handling Block
        -------------------------------------------------------------------
        PRINT '*** ERROR OCCURRED DURING BRONZE LOAD ***';
        PRINT CONCAT('Error Message   : ', ERROR_MESSAGE());
        PRINT CONCAT('Error Number    : ', ERROR_NUMBER());
        PRINT CONCAT('Error State     : ', ERROR_STATE());
        PRINT '==========================================';
    END CATCH
END
