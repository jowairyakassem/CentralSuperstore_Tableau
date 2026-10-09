# Central Superstore Analytics Project

## 1. Project Overview

Central Superstore Analytics is a retail data warehousing and business intelligence project that transforms retail sales records into structured analytical data and interactive visualizations.

The project uses SQL Server to stage and organize sales data into a dimensional data warehouse. SQL queries, views, and stored procedures support analytical reporting, while Tableau dashboards present key business performance indicators in an accessible format.

## 2. Project Objectives

The main objectives are to:

- Build a structured SQL Server data warehouse using a star schema.
- Separate transactional sales records from descriptive dimension data.
- Clean, prepare, and organize data for reliable analysis.
- Apply advanced SQL concepts, including joins, common table expressions, and stored procedures.
- Calculate business KPIs related to sales, profitability, customers, and trends.
- Develop Tableau dashboards that support comparisons and business decision-making.
- Document the data model, KPI definitions, implementation, and dashboard design.

## 3. Dataset

The project uses the Central Superstore retail dataset.

The source data includes information such as:

- Order and shipping dates
- Order IDs
- Customer IDs, names, and segments
- Product IDs, names, categories, and sub-categories
- Country, state, city, postal code, and region
- Sales, quantity, discount, and profit

These attributes support analysis of sales performance, product contribution, customer segments, geographical differences, and profitability.

## 4. Technology Stack

| Technology | Purpose |
|---|---|
| Microsoft SQL Server | Database platform and data warehouse implementation |
| SQL Server Management Studio (SSMS) | Database development, query execution, and validation |
| SQL | Data preparation, dimensional modeling, querying, and KPI calculations |
| Tableau Desktop | Interactive dashboards and data visualization |
| Git and GitHub | Version control and collaboration |
| Markdown | Project documentation |

## 5. Data Warehouse Design

The warehouse is implemented in the `CentralSuperstoreDW` database.

The main schemas and tables include:

- `stg.CentralSuperstoreRaw`: Staging table for source records.
- `dw.fact_Sales`: Central fact table containing sales transaction measures and dimension keys.
- `dw.dim_Customer`: Customer attributes.
- `dw.dim_Date`: Calendar attributes.
- `dw.dim_Geography`: Geographical attributes.
- `dw.dim_Product`: Product attributes.
- `dw.dim_ShipMode`: Shipping-method attributes.

The star schema supports analysis across multiple business dimensions while keeping numerical measures centralized in the fact table.

## 6. Key Performance Indicators

The project focuses on the following KPIs:

| KPI | Description |
|---|---|
| Total Sales | Total sales amount across the selected records |
| Total Profit | Total profit across the selected records |
| Profit Margin | Total profit divided by total sales |
| Total Orders | Number of distinct orders |
| Total Customers | Number of distinct customers |
| Average Order Value | Total sales divided by the number of distinct orders |

The KPIs can be recalculated when users apply dashboard filters.

## 7. Tableau Executive Overview

The Executive Overview dashboard provides a consolidated view of retail performance.

### KPI Cards
- Total Sales
- Total Profit
- Profit Margin
- Total Orders
- Total Customers
- Average Order Value

### Charts
- Sales Trend Over Time
- Profit Trend Over Time
- Sales by Product Category
- Profit by Product Category
- Top Products by Sales
- Sales by Region

### Filters
- Year
- Category
- Region
- Segment

The dashboard is designed to help users compare performance across time periods, product categories, products, geographical regions, and customer segments.

## 8. Analytical Scope

The project supports analysis of:

- Sales and profit trends over time.
- Product and category contribution to overall sales.
- Profitability differences across categories.
- Highest-selling products.
- Regional sales performance.
- Customer activity and segment-level performance.
- Changes in KPIs under different filter selections.

The analysis describes patterns in the available dataset and does not, by itself, establish the causes of business performance changes.

## 9. Repository Structure

The project repository organizes SQL scripts, source data, documentation, and Tableau deliverables.

```text
CentralSuperstore_Tableau/
├── DataSet/
├── Documentation/
│   ├── Project-Overview.md
│   ├── Data-Model.md
│   ├── KPI-Definitions.md
│   └── Dashboard-Documentation.md
├── SQL/
├── Screenshots/
└── Tableau/
    └── Jowairya_Executive/
        └── Executive_Overview.twbx
```

This structure represents the intended organization. Existing repository folder names should be preserved if they differ.

## 10. Validation

Validation includes checking:

- Source and warehouse record counts.
- Fact-to-dimension relationships.
- SQL aggregation results against Tableau KPI values.
- Distinct order and customer counts.
- Dashboard behavior when filters are applied.
- Consistency between displayed values and the underlying data.

For the currently validated unfiltered dataset, the expected baseline KPI values are:

| KPI | Baseline |
|---|---:|
| Total Sales | 501,239.89 |
| Total Profit | 39,706.36 |
| Profit Margin | 7.92% |
| Total Orders | 1,175 |
| Total Customers | 629 |
| Average Order Value | 426.59 |

These values should be compared with SQL and Tableau using the same source data and filter settings.

## 11. Deliverables

The main deliverables include:

- SQL Server data warehouse and dimensional model.
- SQL scripts for warehouse implementation and analytical queries.
- Tableau Executive Overview packaged workbook (`.twbx`).
- KPI and dashboard documentation.
- Data model and project overview documentation.
- Dashboard screenshots, where included in the repository.

## 12. Conclusion

Central Superstore Analytics combines SQL-based data warehousing with Tableau business intelligence to make retail performance easier to explore and compare. The project provides a structured foundation for analyzing sales, profitability, products, customers, and geographical performance through consistent KPIs and interactive visualizations.
