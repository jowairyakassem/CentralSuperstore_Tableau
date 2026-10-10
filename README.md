# Central Superstore: Data Warehouse & Business Analytics Project

> **How to use this guide:** click any link in the contents to jump to that section. Sections marked **▶** open and close when clicked. This works on GitHub, VS Code preview and most Markdown viewers. In viewers that don't support collapsing, everything simply shows expanded.

**Stack:** SQL Server (T-SQL star schema) → Tableau Desktop (live connection)
**Database:** `CentralSuperstoreDW` on `localhost\SQLEXPRESS`
**Data:** Central-region Superstore orders, order dates 2013–2016

---

## Contents

1. [The questions this project answers](#1-the-questions-this-project-answers)
2. [Question → SQL → Tableau map](#2-question--sql--tableau-map)
3. [The data and the SQL warehouse](#3-the-data-and-the-sql-warehouse)
4. [The Tableau workbook](#4-the-tableau-workbook)
5. [Key calculations explained](#5-key-calculations-explained)
6. [How to run it yourself](#6-how-to-run-it-yourself)
7. [Validation and known issues](#7-validation-and-known-issues)

---

## 1. The questions this project answers

> These questions are reconstructed from the Home page of the workbook and the 20 SQL analytics queries. If your original project brief words them differently, edit this section to match it.

Each business question has an owner, as listed on the workbook's Home page.

<details>
<summary><b>▶ Q-A. How is the business performing overall?</b> (Executive Overview, owner: Jowairya)</summary>

- What are total sales, total profit, profit margin, orders, customers and average order value?
- How have sales and profit moved over time?
- How do category and region contribute?
- Which products sell the most?

</details>

<details>
<summary><b>▶ Q-B. Where is profit made and lost?</b> (Profitability Analysis, owner: Shaza)</summary>

- Which categories and sub-categories are most and least profitable?
- Which 10 products make the most profit, and which 10 lose the most?
- Is discounting eroding profit?
- How does profit vary by region and state?

</details>

<details>
<summary><b>▶ Q-C. Who are our customers and how do they behave?</b> (Customer Behavior Analysis, owner: Shehab)</summary>

- Which segments bring the most revenue?
- Which customers fall into the Platinum, Gold, Silver and Bronze tiers?
- How many customers are repeat versus one-time?
- Who are the top customers, and how much revenue does each customer bring?

</details>

<details>
<summary><b>▶ Q-D. How do sales change over time?</b> (Sales Trends Analysis, owner: Haneen)</summary>

- What are monthly and quarterly revenue and profit?
- How fast is revenue growing year over year?
- Which months are strongest (seasonality)?
- How does revenue accumulate over time?
- Which months have the biggest profit swings?

</details>

<details>
<summary><b>▶ Q-E. Where do we sell, and how do we ship? </b> (Geography and Shipping, owner: Momen)</summary>

- Which states and cities bring the most revenue and profit?
- How do ship modes compare?
- What is the largest single order line in each category?

</details>

---

## 2. Question → SQL → Tableau map

Use this table to follow any question from the database to the finished chart.

| Question | SQL query (in `Central_Superstore_-_DataWarehouse.sql`) | Tableau dashboard and sheets |
|---|---|---|
| Overall KPIs | Query 14, `rpt.vw_ExecutiveKPIs`, `rpt.usp_GetSalesKPIsByDateRange` | **Executive Overview**: KPI sheets, Sales Over Time, Profit Over Time |
| Category and region mix | Query 2 | Executive Overview: Sales by Category, Profit by Category, Sales by Region |
| Top products | Query 1 | Executive Overview: Top Products; **Profitability Analysis - Products**: Top 10 and Bottom 10 |
| Sub-category profitability | Query 3, Report 1 | **Profitability Analysis**: Profit by Sub-Category |
| Discounting vs profit | Query 15 | Profitability Analysis: Discount vs Profit Analysis |
| Profit by state / region | Query 4 | Profitability Analysis: Profitability by Region (map) |
| Segments | Queries 6, 16, Report 2 | **Customer Behavior Analysis**: Revenue by Segment, Customers by Segment, Top Customers by Segment |
| Customer tiers | Query 7 | Customer Behavior Analysis: Customer Tiers |
| Repeat customers | Query 8 | Customer Behavior Analysis: Repeat Customers |
| Top customers | Query 5 | Customer Behavior Analysis: KPI Cards, Top Customers by Segment |
| Monthly trends | Query 9 | **Sales Trends Analysis**: Monthly Revenue, Monthly Profit |
| Quarterly trends | Query 10 | **Sales Trends Analysis - Seasonality**: Quarterly Revenue |
| Year-over-year growth | Query 11, Report 3 | Sales Trends Analysis: Year-over-Year comparison; Seasonality page: YoY Growth |
| Seasonality | Query 12 | Seasonality page: Sales Seasonality |
| Running revenue | Query 13 | Sales Trends Analysis: Running Revenue |
| Profit swings | Query 20 | Seasonality page: Major Profit increases/decreases |
| State revenue | Query 4 | **Geography Map**: Map - Sales by State; **Geography Analysis**: Revenue by State |
| City profitability | Query 19 | Geography Analysis: City Profitability |
| Ship modes | Query 17 | **Shipping and Orders Analysis**: Shipping Analysis |
| Largest order line | Query 18 | Shipping and Orders Analysis: Largest Order Line |

---

## 3. The data and the SQL warehouse

### 3.1 Source data

One flat CSV export of the Central region sheet, with these columns: Row ID, Order ID, Order Date, Ship Date, Ship Mode, Customer ID, Customer Name, Segment, Country, City, State, Postal Code, Region, Product ID, Category, Sub-Category, Product Name, Sales, Quantity, Discount, Profit.

### 3.2 The star schema

The CSV is loaded into a staging table, then split into one fact table and five dimensions.

```
                 dim_Customer
                      │
dim_Date ──── fact_Sales ──── dim_Geography
                 │   │
          dim_Product  dim_ShipMode
```

| Table | Role | Key |
|---|---|---|
| `dw.fact_Sales` | One row per order line (grain = Row ID). Holds Sales, Quantity, Discount, Profit | `RowID`, plus keys to every dimension |
| `dw.dim_Date` | Calendar (year, quarter, month, `YearMonth`) | `DateKey` (YYYYMMDD) |
| `dw.dim_Customer` | Who bought | `CustomerKey` |
| `dw.dim_Product` | What was bought | `ProductKey` |
| `dw.dim_Geography` | Where it shipped | `GeographyKey` |
| `dw.dim_ShipMode` | How it shipped | `ShipModeKey` |
| `stg.CentralSuperstoreRaw` | Landing table for the raw CSV | `RowID` |

<details>
<summary><b>▶ How the script works, step by step</b></summary>

1. **Setup:** creates the database and three schemas: `dw` (warehouse), `stg` (staging) and `rpt` (reporting).
2. **Staging:** creates `stg.CentralSuperstoreRaw` and loads the CSV with `BULK INSERT`.
3. **Tables:** creates the five dimensions and the fact table.
4. **Indexes:** a clustered index on `OrderDateKey`, nonclustered indexes on each foreign key, two covering indexes (products and customers) and supporting dimension indexes.
5. **Dimension load:** `dim_Date` is generated from 2012-12-25 to 2017-01-07. The other dimensions come from the distinct values in staging.
6. **Fact load:** every natural key is resolved to its surrogate key with inner joins.
7. **Analytics:** 20 business queries, one view and one stored procedure.
8. **Reports:** three executive reports.

The script can be re-run. Each load step skips rows that already exist.

</details>

<details>
<summary><b>▶ The SQL techniques demonstrated</b></summary>

| Technique | Where |
|---|---|
| Inner joins | Queries 1–16 |
| Left joins | Queries 17, 19 |
| CTEs | Queries 7, 11, 13, 16, 18, 20 |
| Subquery | Query 15 |
| `CASE` classification | Queries 3, 7, 8 |
| `RANK` | Query 4 |
| `DENSE_RANK` | Query 16 |
| `ROW_NUMBER` | Query 18 |
| `LAG` | Query 11 |
| `LEAD` | Query 20 |
| Running total | Query 13 |
| View | `rpt.vw_ExecutiveKPIs` |
| Stored procedure with `TRY/CATCH` | `rpt.usp_GetSalesKPIsByDateRange` |

</details>

---

## 4. The Tableau workbook

### 4.1 Connection

A live connection to SQL Server (`localhost\SQLEXPRESS`, database `CentralSuperstoreDW`) using Windows authentication. The workbook links the fact table to the five dimensions with **relationships** (not joins). The date relationship uses **order date**, the same as the SQL.

### 4.2 Dashboards

All dashboards use one standard size: **Fixed 1400 × 900**.

| Dashboard | Contents |
|---|---|
| **Home** | Project overview and a card for each analysis area |
| **Executive Overview** | KPIs, sales and profit trends, category and region mix, top products |
| **Profitability Analysis** | KPIs, profit by category, region map, profit by sub-category, discount vs profit |
| **Profitability Analysis - Products** | KPIs, top 10 and bottom 10 products |
| **Customer Behavior Analysis** | Segments, customer tiers, repeat customers, top customers |
| **Sales Trends Analysis** | KPIs, monthly revenue and profit, running revenue, year-over-year comparison |
| **Sales Trends Analysis - Seasonality** | KPIs, quarterly revenue, seasonality, profit swings, YoY growth |
| **Geography Map** | Sales by state map |
| **Geography Analysis** | Revenue by state, sales by region, city profitability |
| **Shipping and Orders Analysis** | Ship mode performance, largest order line |

<details>
<summary><b>▶ Filters used across dashboards</b></summary>

Every dashboard shares one data source, so a filter on the same field behaves identically everywhere.

| Dashboards | Filters |
|---|---|
| Profitability | Year, Category, Sub-Category, Region, State |
| Customer Behavior | Year, Region, Category, Segment, Customer |
| Sales Trends | Year, Quarter, Month, Region, Category, Segment |
| Geography and Shipping | Region, State, City, Ship Mode, Category, Year |

</details>

<details>
<summary><b>▶ Parameters</b></summary>

- **Top Customers:** how many customers to show (default 5)
- **Profit Bin Size:** bucket width for profit distributions (default 200)

</details>

---

## 5. Key calculations explained

| Field | Formula | In plain words |
|---|---|---|
| Total Sales | `SUM(SalesAmount)` | All revenue |
| Total Profit | `SUM(ProfitAmount)` | All profit |
| Profit Margin % | `SUM(Profit) / SUM(Sales)` | Profit as a share of revenue; blank if sales are zero |
| Total Orders | `COUNTD(OrderID)` | Distinct orders |
| Total Customers | `COUNTD(CustomerKey)` | Distinct customers |
| Average Order Value | `SUM(Sales) / COUNTD(OrderID)` | Revenue per order |
| Revenue per Customer | `SUM(Sales) / COUNTD(CustomerKey)` | Revenue per customer |
| Customer Lifetime Revenue | `{ FIXED CustomerKey : SUM(Sales) }` | Each customer's total spend, regardless of the chart |
| Customer Tier | Lifetime revenue ≥ 5000 / 2000 / 500 | Platinum, Gold, Silver, otherwise Bronze |
| Customer Type | Orders per customer > 1 | Repeat or One-Time |
| Profit Rank (Top / Bottom) | `RANK_UNIQUE(SUM(Profit))` | Ranking used for the top 10 and bottom 10 products |
| Profit Swing (Next Month) | `LOOKUP(SUM(Profit), 1) - SUM(Profit)` | Next month's profit minus this month's |
| Avg Monthly Revenue | `SUM(Sales) / COUNTD(years with sales)` | Average revenue per calendar month across the years |

---

## 6. How to run it yourself

<details>
<summary><b>▶ Build the database (SQL Server)</b></summary>

1. Install SQL Server Express and SQL Server Management Studio (SSMS).
2. Export the Central region sheet to **`Central_Superstore.csv`**.
3. Open `Central_Superstore_-_DataWarehouse.sql` in SSMS.
4. In the `BULK INSERT` statement, change the file path to where your CSV is saved.
5. Run the script from top to bottom.
6. Check the result with `SELECT * FROM rpt.vw_ExecutiveKPIs;`.

</details>

<details>
<summary><b>▶ Open the dashboards (Tableau)</b></summary>

1. Use a Tableau Desktop version that is the same as or newer than the one that saved the workbook (2026.2 or later). Older versions show load errors.
2. Open `Central_Superstore_Analytics.twbx`.
3. If Tableau asks for the connection, point it at `localhost\SQLEXPRESS` and the `CentralSuperstoreDW` database.
4. Go to the **Home** tab and follow the cards.

</details>

---

## 7. Validation and known issues

### 7.1 Validation status

The Tableau calculations were compared with the SQL queries **by logic**, and they are consistent (see `SQL_Validation_Summary.md`). The numbers have **not** yet been compared, because that needs the SQL results and the Tableau figures side by side.

### 7.2 Known issues and fixes

<details>
<summary><b>▶ "2 nulls" on trend charts</b></summary>

- **Cause:** `dim_Date` runs from 2012-12-25 to 2017-01-07, a buffer around the real 2013–2016 sales. Relationships keep these empty periods.
- **Impact:** no effect on totals. Only empty marks appear.
- **Fix:** add a data source filter on **Year Number** = 2013–2016, or click the indicator and choose **Filter data**.

</details>

<details>
<summary><b>▶ Major Profit increases/decreases shows nothing</b></summary>

- **Cause:** the table calculation has no direction set.
- **Fix:** right-click the **Profit Swing (Next Month)** pill, then **Compute Using > Year Month**.

</details>

<details>
<summary><b>▶ Map is blank or Latitude/Longitude are red</b></summary>

- **Cause:** the workbook's default country is saved as Egypt, but the states are US states.
- **Fix:** use **Map > Edit Locations** and set the country to **United States**. If the Latitude and Longitude pills stay red, drag Country and State onto Detail and double-click the generated Latitude and Longitude fields.

</details>

<details>
<summary><b>▶ Workbook won't load (error D2E8DA72)</b></summary>

- **Cause:** the workbook was saved in a newer Tableau version than the one opening it.
- **Fix:** update Tableau Desktop to 2026.2 or later.

</details>

---

*Related files: `Central_Superstore_-_DataWarehouse.sql`, `Central_Superstore_Analytics.twbx`, `SQL_Validation_Summary.md`.*
