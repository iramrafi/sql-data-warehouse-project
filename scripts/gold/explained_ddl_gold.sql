
-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================

--Here we are joining three different tables crm_cust_info, erp_cust_az12, erp_loc_a101 as a single object

select 
	ci.cst_id,
    ci.cst_key,
    ci.cst_firstname,
    ci.cst_lastname,
	ci.cst_gndr,
    ci.cst_marital_status,
	ci.cst_create_date,
	ca.bdate,
	ca.gen,
	la.cntry
from silver.crm_cust_info as ci
LEFT JOIN silver.erp_cust_az12 as ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid;


---After joining table, check if any duplicates were introduced by the join logic
--Expectations: No Result
select cst_id, COUNT(*) FROM
(
select 
	ci.cst_id,
    ci.cst_key,
    ci.cst_firstname,
    ci.cst_lastname,
	ci.cst_gndr,
    ci.cst_marital_status,
	ci.cst_create_date,
	ca.bdate,
	ca.gen,
	la.cntry
from silver.crm_cust_info as ci
LEFT JOIN silver.erp_cust_az12 as ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid
) t
GROUP BY cst_id
HAVING COUNT(*) > 1;

-- here we have two columns with same type cst_gndr and gen but both have different values combination 
-- So, in this case we have to check Which Source is master for these value check
--Here, master source of data is CRM!
select 
	ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
	ci.cst_marital_status AS marital_status,
	case when ci.cst_gndr != 'n/a' then ci.cst_gndr--CRM is the master
	     else coalesce(ca.gen, 'n/a')
		 end as gender,        --new integrated column from cst_gndr column and gen column 
	ci.cst_create_date AS create_date,
	ca.bdate AS birthdate,
	la.cntry AS country
from silver.crm_cust_info as ci
LEFT JOIN silver.erp_cust_az12 as ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid;

--Sort the columns into logical groups to improve readability
select 
	ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
	la.cntry AS country,
	ci.cst_marital_status AS marital_status,
	case when ci.cst_gndr != 'n/a' then ci.cst_gndr--CRM is the master
	     else coalesce(ca.gen, 'n/a')
		 end as gender,        --new integrated column from cst_gndr column and gen column 
	ca.bdate AS birthdate,
	ci.cst_create_date AS create_date
from silver.crm_cust_info as ci
LEFT JOIN silver.erp_cust_az12 as ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid;


/*
Surrogate Key
System-generated unique identifier assigned to each record in a table.

There are two ways-
1. DDL based generattion
2. Query based using Window function (Row_Number)

Why do we use surrogate key?
We can use the surrogate key in order to connect the data model.
*/

--Surrogate key using Window Function
select 
	ROW_NUMBER() OVER(ORDER BY cst_id ) AS customer_key, -- Surrogate key
	ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
	la.cntry AS country,
	ci.cst_marital_status AS marital_status,
	case when ci.cst_gndr != 'n/a' then ci.cst_gndr--CRM is the master
	     else coalesce(ca.gen, 'n/a')
		 end as gender,        --new integrated column from cst_gndr column and gen column 
	ca.bdate AS birthdate,
	ci.cst_create_date AS create_date
from silver.crm_cust_info as ci
LEFT JOIN silver.erp_cust_az12 as ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid;


--Create View

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
select 
	ROW_NUMBER() OVER(ORDER BY cst_id ) AS customer_key, -- Surrogate key
	ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
	la.cntry AS country,
	ci.cst_marital_status AS marital_status,
	case when ci.cst_gndr != 'n/a' then ci.cst_gndr--CRM is the master
	     else coalesce(ca.gen, 'n/a')
		 end as gender,        --new integrated column from cst_gndr column and gen column 
	ca.bdate AS birthdate,
	ci.cst_create_date AS create_date
from silver.crm_cust_info as ci
LEFT JOIN silver.erp_cust_az12 as ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid;

GO

--Quality Check of gold.dim_customers
--Expectations: No Result

SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;


SELECT DISTINCT gender from gold.dim_customers;


-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================

--Here we are joining two different tables crm_prd_info, erp_px_cat_g1v2 as a single object

/*
--Select Only current information of the product
--if the End Date is NULL then it is Current info of the Product
*/

select 
	pn.prd_id,
	pn.cat_id,
	pn.prd_key,
	pn.prd_nm,
	pn.prd_line,
	pn.prd_cost,
	pn.prd_start_dt,
	pn.prd_end_dt
	from silver.crm_prd_info pn
	where pn.prd_end_dt is null;    --Filter Out all historical data

select * from silver.crm_prd_info;

select * from silver.erp_px_cat_g1v2;


--Removed prd_end_dt (not needed now)
--Join Tables Using common column
select 
	pn.prd_id,
	pn.cat_id,
	pn.prd_key,
	pn.prd_nm,
	pn.prd_line,
	pn.prd_cost,
	pn.prd_start_dt,
	pc.cat,
	pc.subcat,
	pc.maintenance
from silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
where pn.prd_end_dt is null;   --Filter Out all historical data


--Quality Check: Check for Duplicates
select prd_key, COUNT(*) FROM (
select 
	pn.prd_id,
	pn.cat_id,
	pn.prd_key,
	pn.prd_nm,
	pn.prd_line,
	pn.prd_cost,
	pn.prd_start_dt,
	pc.cat,
	pc.subcat,
	pc.maintenance
from silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
where pn.prd_end_dt is null
) t GROUP BY prd_key
HAVING COUNT(*) > 1;


--Sort the column into logical groups to improve readability adn give proper name
--Create surrogate key
select 
	ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
	pn.prd_id AS product_id,
	pn.prd_key AS product_number,
	pn.prd_nm AS product_name,
	pn.cat_id AS category_id,
	pc.cat AS category,
	pc.subcat AS subcategory,
	pc.maintenance,
	pn.prd_cost AS cost,
	pn.prd_line AS product_line,
	pn.prd_start_dt AS start_date
from silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
where pn.prd_end_dt is null;  


--Create View

IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
select 
    ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
	pn.prd_id AS product_id,
	pn.prd_key AS product_number,
	pn.prd_nm AS product_name,
	pn.cat_id AS category_id,
	pc.cat AS category,
	pc.subcat AS subcategory,
	pc.maintenance,
	pn.prd_cost AS cost,
	pn.prd_line AS product_line,
	pn.prd_start_dt AS start_date
from silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
where pn.prd_end_dt is null;   -- filter Out all historical data
GO


-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================

select * from silver.crm_sales_details 

select * from silver.crm_cust_info;

select * from silver.crm_prd_info;



SELECT 
sd.sls_ord_num,
sd.sls_prd_key,
sd.sls_cust_id,
sd.sls_order_dt,
sd.sls_ship_dt,
sd.sls_due_dt,
sd.sls_sales,
sd.sls_quantity,
sd.sls_price
FROM silver.crm_sales_details sd;

/*
Building Fact
Use the dimension's surrogate keys instead of IDs to easily connect facts with dimensions
*/


SELECT 
    sd.sls_ord_num  AS order_number,
    pr.product_key  AS product_key, --Dimension	Key
    cu.customer_key AS customer_key, --Dimension Key
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt  AS shipping_date,
    sd.sls_due_dt   AS due_date,
    sd.sls_sales    AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price    AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
ON sd.sls_cust_id = cu.customer_id;



--Create View
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num  AS order_number,
    pr.product_key  AS product_key,
    cu.customer_key AS customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt  AS shipping_date,
    sd.sls_due_dt   AS due_date,
    sd.sls_sales    AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price    AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;
GO

