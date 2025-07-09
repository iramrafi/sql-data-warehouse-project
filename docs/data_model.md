# Sales Data Mart (Star Schema)

This document describes the **Star Schema** design of the **Sales Data Mart**. The schema is optimized for analytical queries and reporting, with a central **Fact Table** surrounded by multiple **Dimension Tables**.

---

## Tables Overview

### 1. `gold.fact_sales` (Fact Table)
Stores transactional sales data including quantities, pricing, and calculated sales amounts.

| Column Name     | Type    | Description                                              |
|-----------------|---------|----------------------------------------------------------|
| order_number    | STRING  | Unique identifier for each sales order                   |
| product_key     | INT     | Foreign Key → `gold.dim_products.product_key`            |
| customer_key    | INT     | Foreign Key → `gold.dim_customers.customer_key`          |
| order_date      | DATE    | Date when the order was placed                           |
| shipping_date   | DATE    | Date when the order was shipped                          |
| due_date        | DATE    | Due date for order payment                               |
| sales_amount    | INT     | Total amount for the order (calculated)                  |
| quantity        | INT     | Number of product units sold                             |
| price           | INT     | Unit price of the product                                |

 **Sales Calculation**:  
sales_amount = quantity × price


---

### 2. `gold.dim_customers` (Dimension Table)
Contains enriched customer demographic data used for segmentation and analysis.

| Column Name      | Type         | Description                            |
|------------------|--------------|----------------------------------------|
| customer_key     | INT (PK)     | Surrogate key for customer             |
| customer_id      | INT          | Unique CRM/ERP customer ID             |
| customer_number  | STRING       | Alphanumeric customer identifier       |
| first_name       | STRING       | First name of the customer             |
| last_name        | STRING       | Last name of the customer              |
| country          | STRING       | Customer’s country                     |
| marital_status   | STRING       | Marital status: 'Married', 'Single'    |
| gender           | STRING       | Gender of the customer                 |
| birthdate        | DATE         | Customer’s date of birth               |

---

### 3. `gold.dim_products` (Dimension Table)
Contains detailed information about products including categorization, pricing, and maintenance flags.

| Column Name         | Type         | Description                                  |
|---------------------|--------------|----------------------------------------------|
| product_key         | INT (PK)     | Surrogate key for product                    |
| product_id          | INT          | Unique product ID                            |
| product_number      | STRING       | SKU or alphanumeric product code             |
| product_name        | STRING       | Descriptive name of the product              |
| category_id         | STRING       | Identifier for the product category          |
| category            | STRING       | Product category (e.g., Bikes, Accessories)  |
| subcategory         | STRING       | Subcategory (e.g., Mountain, Road)           |
| maintenance         | STRING       | Maintenance requirement: 'Yes' or 'No'       |
| cost                | INT          | Cost of the product                          |
| product_line        | STRING       | Product line (e.g., Road, Mountain)          |
| start_date          | DATE         | Date when the product became available       |

---

##  Relationship Diagram

```text
          +--------------------+                    +---------------------+                   +--------------------+
          | gold.dim_customers |<-------------------|   gold.fact_sales   |------------------>| gold.dim_products  |
          +--------------------+   FK: customer_key +---------------------+ FK: product_key   +--------------------+
