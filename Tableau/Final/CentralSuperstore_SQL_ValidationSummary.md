# Central Superstore Analytics: SQL Validation Summary

**Workbook:** `Central_Superstore_Analytics.twbx`
**SQL source of truth:** `Central_Superstore_-_DataWarehouse.sql` (database `CentralSuperstoreDW`)
**Validation type:** Logic review (static comparison)

> **Status: numeric validation NOT yet complete.**
> The SQL file is the warehouse build script. It loads data from a CSV on the author's computer that was not provided, and it cannot be run in this environment. No Tableau figures or SQL results were available to compare. This document compares **logic** only. No numbers have been checked, and no changes were made to the workbook.

---

## 1. SQL Queries Reviewed

| # | Query / Object | Purpose |
|---|---|---|
| 1 | Query 1 | Top 20 products by profit |
| 2 | Query 2 | Profit and margin by category |
| 3 | Query 3 | Margin bands by sub-category |
| 4 | Query 4 | Revenue and rank by state |
| 5 | Query 5 | Top 15 customers by revenue |
| 6 | Query 6 | Segment summary (customers, orders, AOV) |
| 7 | Query 7 | Customer tiers (Platinum, Gold, Silver, Bronze) |
| 8 | Query 8 | Repeat vs one-time customers |
| 9 | Query 9 | Monthly revenue, profit and orders |
| 10 | Query 10 | Quarterly revenue and profit by year |
| 11 | Query 11 | Year-over-year revenue growth (`LAG`) |
| 12 | Query 12 | Seasonality (average revenue by calendar month) |
| 13 | Query 13 | Running revenue by month |
| 14 | Query 14 | Executive KPI snapshot |
| 15 | Query 15 | Products with above-average discounting |
| 16 | Query 16 | Top 5 customers per segment (`DENSE_RANK`) |
| 17 | Query 17 | Ship mode performance |
| 18 | Query 18 | Largest order line per category (`ROW_NUMBER`) |
| 19 | Query 19 | City-level profitability |
| 20 | Query 20 | Month-over-month profit swing (`LEAD`) |
| 21 | `rpt.vw_ExecutiveKPIs` | Headline KPI view |
| 22 | `rpt.usp_GetSalesKPIsByDateRange` | KPIs for a date window |
| 23 | Reports 1–3 | Profitability, customer behavior and sales trends reports |

---

## 2. Validation Checks Performed

Each Tableau calculation was compared with its SQL equivalent.

| Metric | Tableau formula | SQL equivalent | Logic match |
|---|---|---|---|
| Total Sales | `SUM(SalesAmount)` | `SUM(f.SalesAmount)` (Q14) | Yes |
| Total Profit | `SUM(ProfitAmount)` | `SUM(f.ProfitAmount)` (Q14) | Yes |
| Profit Margin % | `SUM(Profit) / SUM(Sales)`, zero-guarded | `SUM(Profit) * 100.0 / NULLIF(SUM(Sales), 0)` (Q2) | Yes (SQL shows 12.34, Tableau shows 12.34%) |
| Total Orders | `COUNTD(OrderID)` | `COUNT(DISTINCT OrderID)` (Q14) | Yes |
| Total Customers | `COUNTD(CustomerKey)` | `COUNT(DISTINCT CustomerKey)` (Q14) | Yes |
| Average Order Value | `SUM(Sales) / COUNTD(OrderID)` | `SUM(Sales) / COUNT(DISTINCT OrderID)` (Q14) | Yes |
| Customer Tier | 5000 / 2000 / 500 thresholds | Same thresholds (Q7) | Yes |
| Repeat Customer | Orders per customer greater than 1 | `COUNT(DISTINCT OrderID) > 1` (Q8) | Yes |
| Profit Swing | `LOOKUP(SUM(Profit), 1) - SUM(Profit)` | `LEAD(MonthlyProfit) - MonthlyProfit` (Q20) | Yes (see Discrepancy 2) |
| Avg Monthly Revenue | `SUM(Sales) / COUNTD(years with sales)` | Average of monthly totals across years (Q12) | Equivalent |
| Date relationship | `fact_Sales.OrderDateKey = dim_Date.DateKey` | `d.DateKey = f.OrderDateKey` | Yes (order date, not ship date) |
| Sales by Category / Region / State | Sum by dimension | Q2, Q4 | Yes (same grouping) |
| Sales and Profit Trends | By `YearMonth` | Q9, Q10, Q13 | Yes (but see Discrepancy 1) |

Relationships checked in the workbook (all on surrogate keys, as in the SQL joins):
`CustomerKey`, `OrderDateKey`, `GeographyKey`, `ProductKey`, `ShipModeKey`.

---

## 3. Discrepancies Discovered

### Discrepancy 1: Empty periods from the date dimension (confirmed from SQL)
- **Cause:** `dw.dim_Date` is built from **2012-12-25 to 2017-01-07**, a buffer around sales that run 2013–2016.
- **Effect:** the workbook uses relationships, which keep dimension values with no sales. The extra dates appear as empty periods:
  - "2 nulls" and "1 null" indicators on trend and quarterly charts
  - 2012 and 2017 points on the Year-over-Year axis
- **Why SQL does not show it:** the SQL queries use `INNER JOIN` to `dim_Date`, so empty periods never appear.
- **Impact on totals:** none. Sales and profit totals are unaffected, and only empty marks appear.

### Discrepancy 2: Profit Swing returns all nulls (calculation direction)
- **Cause:** the table calculation has no explicit **Compute Using** setting in the workbook, so it can evaluate in the wrong direction, with no "next" value to look up.
- **Effect:** the Major Profit increases/decreases chart shows 50 nulls and no bars.

### Discrepancy 3: Top Products count differs
- SQL Query 1 returns the **top 20**. The Tableau chart shows the **top 10**.
- Compare only the first 10 rows.

### Discrepancy 4: Largest Order Line ties
- SQL Query 18 uses `ROW_NUMBER`, so exactly one row is returned per category.
- Tableau uses `RANK`, which can return two rows when sales amounts tie.

---

## 4. Corrections

> **None applied to the workbook.** Earlier hand-edits to the workbook caused a load error in Tableau, so these corrections should be made in Tableau Desktop.

| # | Correction | How |
|---|---|---|
| 1 | Remove empty dates | **Data Source** tab > **Add** data source filter > **Year Number** = 2013–2016. Order dates fall within these years; the buffer only covers late shipments. |
| 2 | Fix Profit Swing | Open the **Major Profit increases/decreases** worksheet, right-click the **Profit Swing (Next Month)** pill, then **Compute Using > Year Month**. |
| 3 | Hide leftover indicators | On any chart still showing a null indicator, click it and choose **Filter data**. Do **not** use "Show data at default position". |
| 4 | Largest Order Line (optional) | Use `INDEX()` or `RANK_UNIQUE()` instead of `RANK` to match `ROW_NUMBER`. |

---

## 5. Comparison Template (to complete the validation)

Run each query in SQL Server (SSMS), then fill in the Tableau values.

| Metric | SQL query | SQL result | Tableau result | Match? |
|---|---|---|---|---|
| Total Sales | Q14 / `rpt.vw_ExecutiveKPIs` | | | |
| Total Profit | Q14 | | | |
| Profit Margin % | `rpt.vw_ExecutiveKPIs` | | | |
| Total Orders | Q14 | | | |
| Total Customers | Q14 | | | |
| Average Order Value | Q14 | | | |
| Sales by Category | Q2 | | | |
| Profit by Category | Q2 | | | |
| Sales by State | Q4 | | | |
| Top Products (first 10) | Q1 | | | |
| Monthly Revenue / Profit | Q9 | | | |
| Quarterly Revenue | Q10 | | | |
| Year-over-Year growth | Q11 | | | |
| Seasonality | Q12 | | | |
| Running Revenue | Q13 | | | |
| Profit Swing | Q20 | | | |
| Segment summary | Q6 | | | |
| Ship mode performance | Q17 | | | |

---

## 6. Final Confirmation

**Tableau results have not yet been confirmed to match the SQL validation queries.**

What is confirmed: the Tableau calculation logic and the data relationships are consistent with the SQL. What remains: comparing the actual numbers. Send the SQL results (at minimum Queries 14, 2, 9 and 11) and the matching Tableau figures, and the template above can be completed and any differences investigated.
