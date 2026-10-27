# Global Superstore SQL Analysis

## 1. Project Overview

This project was built to practise and consolidate SQL concepts through hands-on analysis of the Global Superstore retail dataset using MySQL.

It covers data quality checks, business performance, customer behavior, product profitability, and sales trends, applying SQL techniques to explore data and answer business questions.

## 2. Dataset Information

| Attribute | Details |
|---|---|
| Dataset | Global Superstore |
| Source | Kaggle |
| Transaction Records | 51,289 |
| Date Range | 2011–2014 |
| Domain | Retail Sales |
| Database | MySQL 8.0 |

The dataset contains information about orders, customers, products, sales, profit, discounts, shipping, and geographical locations.

*Note: The exact original Kaggle listing URL could not be recovered.*

## 3. Tools and Technologies

- **MySQL 8.0** — Data analysis and querying
- **MySQL Workbench** — Query development and execution
- **Git and GitHub** — Version control and project documentation

## 4. Project Structure

```text
global-superstore-sql-analysis/
│
├── README.md
├── 01_data_quality_checks.sql
├── 02_overall_business_analysis.sql
├── 03_customer_analysis.sql
├── 04_product_analysis.sql
├── 05_sales_trends.sql
│
└── screenshots/
```

## 5. Analysis Modules

| SQL Script | Focus Areas |
|---|---|
| `01_data_quality_checks.sql` | Missing values, duplicates, data validation, relationships, and outliers |
| `02_overall_business_analysis.sql` | Business KPIs, regional and market performance, profitability, and discount analysis |
| `03_customer_analysis.sql` | Customer rankings, RFM segmentation, repeat purchases, and purchase behavior |
| `04_product_analysis.sql` | Product rankings, profitability, underperforming products, and Pareto analysis |
| `05_sales_trends.sql` | Monthly trends, MoM growth, rolling totals, cumulative performance, and seasonality |

## 6. SQL Concepts Practised

- Joins, aggregate functions, and subqueries
- Common Table Expressions (CTEs)
- Temporary tables and session variables
- Window functions: `RANK()`, `DENSE_RANK()`, `NTILE()`, and `LAG()`
- Conditional logic using `CASE`
- Date functions and time-series analysis
- NULL handling and percentage calculations
- Business metrics and performance benchmarks

## 7. Setup and Execution

1. Create a MySQL database and import the dataset.
2. Prepare the required `orders`, `customers`, and `products` tables.
3. Verify that the table and column names match the SQL scripts.
4. Run the scripts in numerical order, starting with data quality checks.
5. For scripts using temporary tables or session variables, execute the required setup statements in the same MySQL session before running dependent queries.

Refer to the comments in each SQL file for specific execution instructions.

## 8. Key Findings and Business Insights


## 9. Screenshots

The `screenshots/` folder contains selected query outputs and business findings from the five analysis modules.

## 10. Conclusion

This project strengthened my practical SQL skills by applying foundational and advanced concepts to a structured retail dataset. It demonstrates my ability to validate data, analyze business performance, investigate customer and product behavior, and explore sales trends using MySQL.

## 11. Database Files

The repository includes five MySQL `.sql` files containing database exports for the Global Superstore analysis project.

| File | Description |
|---|---|
| [`superstore_analysis_customers.sql`](https://github.com/Ziya1512/global-superstore-Mysql-analysis/blob/main/superstore_analysis_customers.sql) | Customer-related database data and table definitions.
| [`superstore_analysis_orders.sql`](https://github.com/Ziya1512/global-superstore-Mysql-analysis/blob/main/superstore_analysis_orders.sql) | Order transaction data and table definitions. |
| [`superstore_analysis_products.sql`](https://github.com/Ziya1512/global-superstore-Mysql-analysis/blob/main/superstore_analysis_products.sql) | Product-related database data and table definitions. |
| [`superstore_analysis_routines.sql`](https://github.com/Ziya1512/global-superstore-Mysql-analysis/blob/main/superstore_analysis_routines.sql) | Database routines, such as stored procedures or functions, if included in the export. |

### Database Import

1. Download the required `.sql` files from the repository.
2. Create or select the target database in MySQL.
3. Import the table files, accounting for dependencies between tables.
4. Import the routines file after the required tables are available.
5. Verify that the database objects and column names match those used in the analysis scripts.

## Author
Ziya
https://github.com/Ziya1512
