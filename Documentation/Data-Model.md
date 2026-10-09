# Data Model Documentation

## 1. Overview

The Central Superstore Data Warehouse uses a **Star Schema** to organize retail sales data for reporting and business analysis. The model separates transactional sales data from descriptive information about customers, products, dates, geography, and shipping methods.

The central fact table is `dw.fact_Sales`, connected to dimension tables that provide context for analyzing sales and profitability.

## 2. Database Information

- **Database:** `CentralSuperstoreDW`
- **Staging table:** `stg.CentralSuperstoreRaw`
- **Fact table:** `dw.fact_Sales`
- **Dimension tables:** Customer, Date, Geography, Product, and Ship Mode
- **Primary purpose:** Support analytical queries, KPI calculations, and Tableau dashboards.

## 3. Data Warehouse Architecture

The data warehouse follows this general flow:

1. **Source Data:** The original Central Superstore retail dataset.
2. **Staging Layer:** `stg.CentralSuperstoreRaw` stores the source records for preparation and processing.
3. **Data Warehouse Layer:** The fact and dimension tables organize the data into a star schema.
4. **Analytics Layer:** SQL queries, views, and stored procedures support business analysis.
5. **Visualization Layer:** Tableau presents the results through interactive dashboards.

## 4. Fact Table

### `dw.fact_Sales`

The fact table stores sales transaction records and numerical measures used for analysis.

**Key fields include:**
- `SalesKey`: Transaction-row identifier, if defined in the implemented schema.
- `Order ID`: Identifies the order associated with a sales record.
- `OrderDateKey`: Links each record to the date dimension.
- `CustomerKey`: Links each record to the customer dimension.
- `ProductKey`: Links each record to the product dimension.
- `GeographyKey`: Links each record to the geography dimension.
- `ShipModeKey`: Links each record to the shipping-method dimension.
- Sales amount, profit amount, quantity, and discount measures.

The exact column names should be verified against the implemented SQL table definition.

**Grain:** The fact table represents sales transaction rows rather than one row per order. An order may contain multiple products and therefore multiple fact records.

**Main purpose:** Analyze sales, profit, order activity, product performance, and business trends.

## 5. Dimension Tables

### `dw.dim_Customer`

Stores customer-related descriptive attributes.

Typical attributes include:
- Customer key
- Customer ID
- Customer name
- Segment

**Purpose:** Analyze sales and profitability by customer and customer segment.

### `dw.dim_Date`

Stores calendar attributes used for time-based analysis.

Typical attributes include:
- Date key
- Full date
- Year
- Quarter
- Month
- Day

**Purpose:** Support yearly, quarterly, monthly, and daily sales and profit analysis.

### `dw.dim_Geography`

Stores geographical attributes associated with sales transactions.

Typical attributes include:
- Geography key
- Country
- State
- City
- Postal code
- Region

**Purpose:** Compare sales and profitability across regions and locations.

### `dw.dim_Product`

Stores product-related descriptive attributes.

Typical attributes include:
- Product key
- Product ID
- Product name
- Category
- Sub-category

**Purpose:** Analyze product sales, category performance, and product profitability.

### `dw.dim_ShipMode`

Stores shipping-method information.

Typical attributes include:
- Ship mode key
- Ship mode name

**Purpose:** Support analysis by shipping method and order fulfillment category.

The attribute lists above describe the intended roles of the dimensions. Confirm the actual columns in SQL Server before treating them as a complete physical schema.

## 6. Relationships

The fact table connects to the dimensions using the following key relationships:

| Fact Table Column | Dimension Table Column | Relationship |
|---|---|---|
| `OrderDateKey` | `dim_Date.DateKey` | Many-to-one |
| `CustomerKey` | `dim_Customer.CustomerKey` | Many-to-one |
| `ProductKey` | `dim_Product.ProductKey` | Many-to-one |
| `GeographyKey` | `dim_Geography.GeographyKey` | Many-to-one |
| `ShipModeKey` | `dim_ShipMode.ShipModeKey` | Many-to-one |

Each fact record references its corresponding dimension records. A dimension record can be associated with multiple fact records.

## 7. Tableau Data Model

The Executive Overview dashboard uses the following tables:

- `dw.fact_Sales`
- `dw.dim_Date`
- `dw.dim_Customer`
- `dw.dim_Geography`
- `dw.dim_Product`

The relationships are configured using the corresponding key fields listed above.

The shipping-method dimension is part of the warehouse design but is not required for the current Executive Overview dashboard.

## 8. Analytical Measures

The Tableau dashboard uses the following measures:

| KPI | Calculation |
|---|---|
| Total Sales | `SUM(Sales Amount)` |
| Total Profit | `SUM(Profit Amount)` |
| Profit Margin | `SUM(Profit Amount) / SUM(Sales Amount)` |
| Total Orders | `COUNTD(Order ID)` |
| Total Customers | `COUNTD(Customer Key)` |
| Average Order Value | `SUM(Sales Amount) / COUNTD(Order ID)` |

Profit margin is formatted as a percentage. Average Order Value is calculated using distinct orders to avoid counting an order multiple times when it contains multiple products.

## 9. Data Quality and Validation

Data quality checks should verify:

- Fact and dimension keys match correctly.
- Date fields are stored and interpreted consistently.
- Sales and profit measures use appropriate numeric data types.
- Missing or invalid values are identified and handled appropriately.
- Order counts use distinct order IDs.
- Dashboard totals reconcile with SQL query results under equivalent filters.

## 10. Summary

The star schema separates measurable sales transactions from descriptive business attributes. This structure supports consistent reporting, efficient analytical queries, and flexible Tableau visualizations across time, customers, products, and geography.
