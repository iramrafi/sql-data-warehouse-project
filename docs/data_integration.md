# Data Integration: Table Relationships Across CRM and ERP

This documentation outlines how different tables from **CRM (Customer Relationship Management)** and **ERP (Enterprise Resource Planning)** systems are related and integrated to form a unified business view.

---

## CRM System Tables

These tables are responsible for tracking **sales transactions**, **customer details**, and **product information**.

| Table Name           | Type       | Description                                         | Key Columns        |
|----------------------|------------|-----------------------------------------------------|--------------------|
| `crm_sales_details`  | Fact Table | Transactional sales and order data                  | `prd_key`, `cst_id` |
| `crm_prd_info`       | Dimension  | Product details and historical records              | `prd_key`           |
| `crm_cust_info`      | Dimension  | Customer master data (basic personal info)          | `cst_id`, `cst_key` |

 **Note**:  
- `cst_id` is used to link sales to the customer  
- `prd_key` connects sales to products  

---

## ERP System Tables

These tables enrich CRM data with additional **customer** and **product metadata**.

| Table Name             | Type       | Description                                         | Key Columns |
|------------------------|------------|-----------------------------------------------------|-------------|
| `erp_px_cat_g1v2`      | Dimension  | Product category and maintenance information        | `id`        |
| `erp_cust_az12`        | Dimension  | Extended customer information (e.g. birthdate)      | `cid`       |
| `erp_loc_a101`         | Dimension  | Location details of customers (e.g. country)        | `cid`       |

 **Note**:  
- ERP's `cid` column joins with CRM's `cst_id`  
- ERP product category's `id` column joins with CRM’s `prd_key`  

---

## Data Relationships & Join Keys

| Relationship Type      | From Table         | To Table            | Join Key(s)              |
|------------------------|--------------------|----------------------|--------------------------|
| Sales → Product        | `crm_sales_details`| `crm_prd_info`       | `prd_key`                |
| Sales → Customer       | `crm_sales_details`| `crm_cust_info`      | `cst_id`                 |
| Customer → ERP Info    | `crm_cust_info`    | `erp_cust_az12`      | `cst_id` = `cid`         |
| Customer → Location    | `crm_cust_info`    | `erp_loc_a101`       | `cst_id` = `cid`         |
| Product → Category     | `crm_prd_info`     | `erp_px_cat_g1v2`    | `prd_key` = `id`         |

---

## Integration Purpose

| Integrated Entity | Source Tables Involved                                         | Purpose                                                   |
|-------------------|---------------------------------------------------------------|-----------------------------------------------------------|
| **Customer**      | `crm_cust_info`, `erp_cust_az12`, `erp_loc_a101`              | Builds a rich profile of customer demographics            |
| **Product**       | `crm_prd_info`, `erp_px_cat_g1v2`                             | Enriches product info with category and maintenance data  |
| **Sales**         | `crm_sales_details`, linked via customer and product keys     | Stores transactional records for revenue and analysis     |

---

## Summary: Integrated Architecture


---

## Use Cases

- **Sales Analysis:** Combines transactional, customer, and product data
- **Customer Segmentation:** Based on location and demographics
- **Product Analytics:** Track categories, maintenance status, and performance

---




