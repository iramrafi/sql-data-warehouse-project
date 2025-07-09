# Gold Layer Data Dictionary

The **Gold Layer** is designed to provide clean, business-ready data for analytics and reporting. It consists of well-defined **dimension tables** and **fact tables** representing business entities and measurable events.

---

##  gold.dim_customers

**Description:** Contains enriched customer profile information with standardized values and demographic attributes.

| Column Name      | Data Type     | Description                                                                 |
|------------------|---------------|-----------------------------------------------------------------------------|
| `customer_key`   | INT           | Surrogate key — uniquely identifies a customer (used as PK in dimension).   |
| `customer_id`    | INT           | Natural/business identifier for each customer.                              |
| `customer_number`| NVARCHAR(50)  | Alphanumeric customer code (public-facing or business-referenced).          |
| `first_name`     | NVARCHAR(50)  | Customer's first name.                                                      |
| `last_name`      | NVARCHAR(50)  | Customer's last name.                                                       |
| `country`        | NVARCHAR(50)  | Country of residence (e.g., 'Canada', 'United States').                     |
| `marital_status` | NVARCHAR(50)  | 'Single', 'Married', or 'n/a'.                                              |
| `gender`         | NVARCHAR(50)  | 'Male', 'Female', or 'n/a'.                                                 |
| `birthdate`      | DATE          | Date of birth in YYYY-MM-DD format.                                         |
| `create_date`    | DATE          | Timestamp of when the customer record was created.                          |

---

##  gold.dim_products

**Description:** Stores metadata about the products, their classifications, pricing, and availability timeline.

| Column Name          | Data Type     | Description                                                                |
|----------------------|---------------|----------------------------------------------------------------------------|
| `product_key`        | INT           | Surrogate key for uniquely identifying products.                           |
| `product_id`         | INT           | Natural/business identifier of the product.                                |
| `product_number`     | NVARCHAR(50)  | Structured alphanumeric product code.                                      |
| `product_name`       | NVARCHAR(50)  | Descriptive product name with details like color/type.                     |
| `category_id`        | NVARCHAR(50)  | ID for mapping to product category.                                        |
| `category`           | NVARCHAR(50)  | High-level product grouping (e.g., Bikes, Components).                     |
| `subcategory`        | NVARCHAR(50)  | Sub-level classification for deeper categorization.                        |
| `maintenance_required` | NVARCHAR(50)| Indicates if maintenance is needed — 'Yes' or 'No'.                        |
| `cost`               | INT           | Base cost of the product in whole currency.                                |
| `product_line`       | NVARCHAR(50)  | Grouping like 'Mountain', 'Road', etc.                                     |
| `start_date`         | DATE          | When the product was launched or made available.                           |

---

##  gold.fact_sales

**Description:** Central fact table storing all sales transaction metrics and foreign keys to dimensions.

| Column Name     | Data Type     | Description                                                                 |
|-----------------|---------------|-----------------------------------------------------------------------------|
| `order_number`  | NVARCHAR(50)  | Unique alphanumeric order ID.                                               |
| `product_key`   | INT           | FK to `dim_products.product_key`.                                           |
| `customer_key`  | INT           | FK to `dim_customers.customer_key`.                                         |
| `order_date`    | DATE          | Date the order was placed.                                                 |
| `shipping_date` | DATE          | Date the order was shipped.                                                |
| `due_date`      | DATE          | Payment due date for the order.                                            |
| `sales_amount`  | INT           | Total value of the sale (quantity * price).                                |
| `quantity`      | INT           | Number of product units sold.                                              |
| `price`         | INT           | Unit price at which the product was sold.                                  |

---

>  This data model supports clean joins, consistent analytics, and clear auditability between source and target entities.

