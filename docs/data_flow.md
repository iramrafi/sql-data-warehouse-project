# Data Flow: Data Lineage Overview

This document describes the data lineage across the **Bronze**, **Silver**, and **Gold** layers in a modern data warehouse architecture. It maps the journey of data from **CRM** and **ERP** source systems through each transformation stage.

---

## Source Systems

Data originates from two primary operational systems:

| Source System | Description                                 |
|---------------|---------------------------------------------|
| **CRM**       | Customer Relationship Management system      |
| **ERP**       | Enterprise Resource Planning system          |

Each source system contains raw data used for various operational and analytical purposes.

---

## Bronze Layer (Raw Ingestion)

The **Bronze Layer** contains raw data ingested directly from source systems. It is minimally processed and retains full data fidelity.

| Table Name            | Source | Description                                     |
|-----------------------|--------|-------------------------------------------------|
| `crm_sales_details`   | CRM    | Raw transactional sales data from CRM          |
| `crm_cust_info`       | CRM    | Raw customer information                        |
| `crm_prd_info`        | CRM    | Product details as per CRM                     |
| `erp_cust_az12`       | ERP    | Additional customer demographics               |
| `erp_loc_a101`        | ERP    | Customer location data                         |
| `erp_px_cat_g1v2`     | ERP    | Product category and maintenance metadata      |

---

## Silver Layer (Cleansed & Standardized)

The **Silver Layer** contains cleaned, deduplicated, and standardized data. This layer prepares the data for business logic integration in the Gold Layer.

| Table Name            | Source Table in Bronze     | Description                                      |
|-----------------------|----------------------------|--------------------------------------------------|
| `crm_sales_details`   | `bronze.crm_sales_details` | Cleaned and validated sales transactions         |
| `crm_cust_info`       | `bronze.crm_cust_info`     | Trimmed names, validated IDs, standardized gender|
| `crm_prd_info`        | `bronze.crm_prd_info`      | Standardized product lines and cost checks       |
| `erp_cust_az12`       | `bronze.erp_cust_az12`     | Cleaned customer demographic data                |
| `erp_loc_a101`        | `bronze.erp_loc_a101`      | Trimmed and normalized location values           |
| `erp_px_cat_g1v2`     | `bronze.erp_px_cat_g1v2`   | Cleaned product categorization metadata          |

---

## Gold Layer (Business-Ready Data)

The **Gold Layer** is optimized for reporting, dashboards, and analytics. It consists of **star schema models** with **dimension** and **fact** tables.

| Table Name      | Source Tables (Silver)                                | Description                                      |
|------------------|--------------------------------------------------------|--------------------------------------------------|
| `fact_sales`     | `crm_sales_details`                                   | Fact table capturing sales transactions          |
| `dim_customers`  | `crm_cust_info`, `erp_cust_az12`, `erp_loc_a101`      | Customer dimension with enriched info            |
| `dim_products`   | `crm_prd_info`, `erp_px_cat_g1v2`                     | Product dimension with category and attributes   |

---

## End-to-End Flow Summary

CRM + ERP (Raw Sources) -> Bronze Layer (Raw, Ingested) -> Silver Layer (Cleaned, Standardized) -> Gold Layer (Analytical, Business-Ready


---

## Key Concepts

- **Data Lineage**: Ensures transparency in how data flows from raw to curated form.
- **Data Governance**: Ensures trust by tracing data origin and transformations.
- **Star Schema**: Implemented in Gold Layer for performance-optimized analytics.

---

## Notes

- The CRM system contributes mostly to **customer and sales** data.
- The ERP system enriches customer and product info via demographic, location, and category metadata.
- Final tables are ready for BI tools like Power BI, Tableau, or Excel dashboards.

---




