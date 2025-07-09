-- ====================================================================
-- Script Purpose:
-- This script performs various quality checks for data consistency,
-- accuracy, and standardization across the 'bronze' layer.
-- It includes checks for:
--  - Null or duplicate primary keys.
--  - Unwanted spaces in string fields.
--  - Data standardization and consistency.
--  - Invalid date ranges and business logic validations.
--  - Data consistency between related fields.
-- ====================================================================

-- ====================================================================
-- SECTION 1: Checking 'bronze.crm_cust_info'
-- ====================================================================

-- Sample top 10 rows
SELECT TOP 10 * FROM bronze.crm_cust_info;

-- Check for NULLs or duplicate customer IDs (Primary Key Violation)
SELECT cst_id, COUNT(*) AS c
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Fetch records with duplicate cst_id for review
SELECT * FROM bronze.crm_cust_info WHERE cst_id = 29466;

-- Add flag to identify latest record per customer by creation date
SELECT *,
       ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
FROM bronze.crm_cust_info
WHERE cst_id = 29466;

-- Get latest record for each customer only (clean data)
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
    FROM bronze.crm_cust_info
) t
WHERE flag_last = 1;

-- Identify leading/trailing spaces in important string fields
SELECT cst_firstname FROM bronze.crm_cust_info WHERE cst_firstname != TRIM(cst_firstname);
SELECT cst_lastname  FROM bronze.crm_cust_info WHERE cst_lastname  != TRIM(cst_lastname);
SELECT cst_gndr      FROM bronze.crm_cust_info WHERE cst_gndr      != TRIM(cst_gndr);

-- Get cleaned version of customer info with trimmed names and standardized gender/marital status
SELECT
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname)  AS cst_lastname,
    CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
         WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
         ELSE 'n/a' END AS cst_marital_status,
    CASE WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
         WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
         ELSE 'n/a' END AS cst_gndr,
    cst_create_date
FROM (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
) t
WHERE flag_last = 1;

-- ====================================================================
-- SECTION 2: Checking 'bronze.crm_prd_info'
-- ====================================================================

-- View all records
SELECT * FROM bronze.crm_prd_info;

-- Check for NULL or duplicate product IDs
SELECT prd_id, COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Extract category ID from product key (first 5 chars) and join mapping check
SELECT prd_id, prd_key, SUBSTRING(prd_key, 1, 5) AS cat_id, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt
FROM bronze.crm_prd_info;

-- View valid category ids
SELECT DISTINCT id FROM bronze.erp_px_cat_g1v2;

-- Replace '-' with '_' in cat_id to match the mapping table
SELECT prd_id, prd_key, REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, prd_nm
FROM bronze.crm_prd_info;

-- Filter out products with unmatched category ID
SELECT *
FROM bronze.crm_prd_info
WHERE REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') NOT IN (SELECT DISTINCT id FROM bronze.erp_px_cat_g1v2);

-- Match product key with sales details table using suffix part
SELECT prd_id, prd_key, SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key
FROM bronze.crm_prd_info;

-- Identify unmatched product keys in sales table
SELECT *
FROM bronze.crm_prd_info
WHERE SUBSTRING(prd_key, 7, LEN(prd_key)) NOT IN (SELECT sls_prd_key FROM bronze.crm_sales_details);

-- Check for leading/trailing spaces and negative/null costs
SELECT prd_nm FROM bronze.crm_prd_info WHERE prd_nm != TRIM(prd_nm);
SELECT prd_cost FROM bronze.crm_prd_info WHERE prd_cost < 0 OR prd_cost IS NULL;

/*
Conditions: 
1.start date should be smaller than the end date and end of the first history should be younger than the start of the next record.
2.Each Record must has a start date
3. it's ok to have start date without end date
*/

/*
Solution1: switch start date and end date
issue: dates are overlapping

Solution 2: 
Drive the end date from the start date
End date = Start of the 'NEXT' record - 1

*/

-- Cleaned product info with standardized product lines and fixed end date
SELECT
    prd_id,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
    prd_nm,
    ISNULL(prd_cost, 0) AS prd_cost,
    CASE UPPER(TRIM(prd_line))
         WHEN 'M' THEN 'Mountain'
         WHEN 'R' THEN 'Road'
         WHEN 'S' THEN 'Other Sales'
         WHEN 'T' THEN 'Touring'
         ELSE 'n/a' END AS prd_line,
    CAST(prd_start_dt AS DATE) AS prd_start_dt,
    CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt ASC) - 1 AS DATE) AS prd_end_date
FROM bronze.crm_prd_info;

-- ====================================================================
-- SECTION 3: Checking 'bronze.crm_sales_details'
-- ====================================================================


-- View sample data
SELECT TOP 10 * FROM bronze.crm_sales_details;

-- Check for unwanted spaces in product keys and order numbers
SELECT *
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)
   OR sls_prd_key != TRIM(sls_prd_key);

-- Identify invalid product references (prd_key not found in product table)
SELECT *
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);

-- Identify invalid customer references (cust_id not found in customer table)
SELECT *
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);

/*
NOTE:
1.Negative Numbers and Zero can't be cast to date
2.Check for dates column sls_order_dt, sls_ship_dt, sls_due_dt		
*/

-- Validate sls_order_dt: check for 0, non-8-digit length, or out-of-range values
SELECT NULLIF(sls_order_dt, 0) AS sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 OR LEN(sls_order_dt) != 8
   OR sls_order_dt > 20500101 OR sls_order_dt < 19000101;

-- Fix date formats: convert integers to valid SQL dates
SELECT 
  sls_ord_num,
  sls_prd_key,
  sls_cust_id,
  CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
       ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) END AS sls_order_dt,
  CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
       ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) END AS sls_ship_dt,
  CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
       ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) END AS sls_due_dt,
  sls_sales,
  sls_quantity,
  sls_price
FROM bronze.crm_sales_details;

-- Validate order date < shipping date and due date
SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

-- Check for business rule: sales = quantity * price; none of the fields should be null or <= 0
SELECT DISTINCT sls_sales, sls_quantity, sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
   OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

/*
Rule 
if the sales is negative, zero or null. drive it using quantity and price
if the price is zero or null then drive it using Sales and Quantity
if price is negative, convert it to a positive value

*/

-- Fix business rule violations: derive missing or incorrect sales/price values
SELECT DISTINCT
  sls_sales AS old_sales,
  sls_quantity AS old_quantity,
  sls_price AS old_price,
  CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * sls_price THEN sls_quantity * ABS(sls_price)
       ELSE sls_sales END AS sls_sales,
  CASE WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales / NULLIF(sls_quantity, 0)
       ELSE sls_price END AS sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
   OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0;

-- Final Cleaned Sales Details
SELECT 
  sls_ord_num,
  sls_prd_key,
  sls_cust_id,
  CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
       ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) END AS sls_order_dt,
  CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
       ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) END AS sls_ship_dt,
  CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
       ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) END AS sls_due_dt,
  CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * sls_price THEN sls_quantity * ABS(sls_price)
       ELSE sls_sales END AS sls_sales,
  sls_quantity,
  CASE WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales / NULLIF(sls_quantity, 0)
       ELSE sls_price END AS sls_price
FROM bronze.crm_sales_details;


-- ====================================================================
-- Quality Checks: bronze.erp_cust_az12
-- ====================================================================

-- Clean and match customer IDs (remove 'NAS')
SELECT 
  CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) ELSE cid END AS cid,
  bdate,
  gen
FROM bronze.erp_cust_az12;

-- Identify invalid customer ID matches
SELECT 
  CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) ELSE cid END AS cid,
  bdate,
  gen
FROM bronze.erp_cust_az12
WHERE CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) ELSE cid END 
      NOT IN (SELECT cst_key FROM silver.crm_cust_info);

-- Remove future or invalid birthdates
SELECT bdate FROM bronze.erp_cust_az12 WHERE bdate < '1924-01-01' OR bdate > GETDATE();

-- Final Cleaned ERP Customer Data
SELECT 
  CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) ELSE cid END AS cid,
  CASE WHEN bdate > GETDATE() THEN NULL ELSE bdate END AS bdate,
  CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
       WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
       ELSE 'n/a' END AS gen
FROM bronze.erp_cust_az12;


-- ====================================================================
-- Quality Checks: bronze.erp_loc_a101
-- ====================================================================

-- Clean and match customer IDs (remove '-')
SELECT REPLACE(cid, '-', '') AS cid, cntry FROM bronze.erp_loc_a101;

-- Identify invalid customer ID matches
SELECT REPLACE(cid, '-', '') AS cid, cntry
FROM bronze.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN (SELECT cst_key FROM silver.crm_cust_info);

-- Normalize country values
SELECT DISTINCT cntry FROM bronze.erp_loc_a101;

-- Final Cleaned ERP Location Data
SELECT
  REPLACE(cid, '-', '') AS cid,
  CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
       WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
       WHEN TRIM(cntry) = '' OR TRIM(cntry) IS NULL THEN 'n/a'
       ELSE TRIM(cntry) END AS cntry
FROM bronze.erp_loc_a101;


-- ====================================================================
-- Quality Checks: bronze.erp_px_cat_g1v2
-- ====================================================================

-- Check for unwanted spaces
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance);

-- Review standardization of category data
SELECT DISTINCT cat FROM bronze.erp_px_cat_g1v2;
SELECT DISTINCT subcat FROM bronze.erp_px_cat_g1v2;
SELECT DISTINCT maintenance FROM bronze.erp_px_cat_g1v2;

-- Final Cleaned Product Category Data
SELECT id, TRIM(cat) AS cat, TRIM(subcat) AS subcat, TRIM(maintenance) AS maintenance
FROM bronze.erp_px_cat_g1v2;
