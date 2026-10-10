# Central Superstore Analytics: Dashboard Documentation

**Workbook:** `Central_Superstore_Analytics.twbx`
**Data source:** SQL Server, database `CentralSuperstoreDW` (live connection, `localhost\SQLEXPRESS`)
**Data model:** star schema, `fact_Sales` linked by relationships to `dim_Date` (order date), `dim_Customer`, `dim_Product`, `dim_Geography` and `dim_ShipMode`
**Period covered:** orders from 2013 to 2016
**Dashboard size:** all dashboards are Fixed 1400 × 900

---

## Contents

1. [Dashboard overview](#1-dashboard-overview)
2. [Home](#2-home)
3. [Executive Overview](#3-executive-overview)
4. [Profitability Analysis](#4-profitability-analysis)
5. [Profitability Analysis - Products](#5-profitability-analysis---products)
6. [Customer Behavior Analysis](#6-customer-behavior-analysis)
7. [Sales Trends Analysis](#7-sales-trends-analysis)
8. [Sales Trends Analysis - Seasonality](#8-sales-trends-analysis---seasonality)
9. [Geography Map](#9-geography-map)
10. [Geography Analysis](#10-geography-analysis)
11. [Shipping and Orders Analysis](#11-shipping-and-orders-analysis)
12. [Metric definitions](#12-metric-definitions)
13. [Filters and interactions](#13-filters-and-interactions)
14. [Known limitations](#14-known-limitations)

---

## 1. Dashboard overview

| # | Dashboard | Business question | Owner |
|---|---|---|---|
| 1 | Home | Navigation and project overview | n/a |
| 2 | Executive Overview | How is the business performing overall? | Jowairya |
| 3 | Profitability Analysis | Where is profit made and lost? | Shaza |
| 4 | Profitability Analysis - Products | Which products make or lose the most profit? | Shaza |
| 5 | Customer Behavior Analysis | Who are our customers and how do they behave? | Shehab |
| 6 | Sales Trends Analysis | How do revenue and profit move over time? | Haneen |
| 7 | Sales Trends Analysis - Seasonality | When is demand strongest, and how fast are we growing? | Haneen |
| 8 | Geography Map | Where do sales come from, shown on a map? | Momen |
| 9 | Geography Analysis | Which states and cities perform best? | Momen |
| 10 | Shipping and Orders Analysis | How do ship modes compare, and what is the largest order line? | Momen |

Dashboards 3–4, 6–7 and 8–10 were each split from a single longer page so that nothing needs scrolling at 1400 × 900.

---

## 2. Home

**Purpose:** entry page. Introduces the project, lists the five analysis areas and explains how to use the workbook.

**Contents:** a title banner, one card per analysis area (with owner, a short description, the tabs it contains and its filters) and a "How to use this workbook" panel.

**Filters:** none.

---

## 3. Executive Overview

**Purpose:** a headline view for leadership.

**Sheets**

| Sheet | What it shows |
|---|---|
| KPI - Total Sales | Total revenue |
| KPI - Total Profit | Total profit |
| KPI - Profit Margin | Profit as a share of sales |
| KPI - Total Orders | Distinct orders |
| KPI - Total Customers | Distinct customers |
| KPI - Average Order Value | Revenue per order |
| Sales Over Time | Sales trend by month |
| Profit Over Time | Profit trend by month |
| Sales by Category | Revenue split by product category |
| Profit by Category | Profit split by product category |
| Sales by Region | Revenue split by region |
| Top Products | Highest-selling products |

**Filters:** Year, Category, Region, Segment.
**Interaction:** selecting a category on Profit by Category highlights the matching category in the other charts.
**SQL reference:** Queries 1, 2, 9, 14 and `rpt.vw_ExecutiveKPIs`.

---

## 4. Profitability Analysis

**Purpose:** overview of where profit is made and lost.

**Layout:** title, filter row, three KPIs, then two rows of two charts.

| Sheet | What it shows |
|---|---|
| Total Sales KPI, Total Profit KPI, Profit Margin % KPI | Headline figures for the current filters |
| Profit by Category (Profitability) | Profit for each category |
| Profitability by Region | Map of profit by region |
| Profit by Sub-Category | Profit for each sub-category |
| Discount vs Profit Analysis | How discount levels relate to profit |

**Filters:** Year, Category, Sub-Category, Region, State.
**SQL reference:** Queries 2, 3, 4, 15 and Report 1.

---

## 5. Profitability Analysis - Products

**Purpose:** the best and worst products by profit.

| Sheet | What it shows |
|---|---|
| Total Sales KPI, Total Profit KPI, Profit Margin % KPI | Same KPIs as the overview page |
| Top 10 Profitable Products | The 10 products with the highest profit |
| Bottom 10 Products by Profit | The 10 products with the lowest profit (including losses) |

**Filters:** Year, Category, Sub-Category, Region, State.
**How the ranking works:** `Profit Rank (Top)` and `Profit Rank (Bottom)` use `RANK_UNIQUE(SUM(Profit))`, so each product gets a distinct rank and exactly 10 rows show.
**SQL reference:** Query 1 (returns the top 20, so compare the first 10 rows).

---

## 6. Customer Behavior Analysis

**Purpose:** understand customer segments, value and loyalty.

| Sheet | What it shows |
|---|---|
| Revenue by Segment | Revenue for Consumer, Corporate and Home Office |
| Customers by Segment | Customer count per segment |
| Customer Tiers | Customers grouped as Platinum, Gold, Silver or Bronze |
| Top Customers by Segment | Highest-spending customers (count set by the *Top Customers* parameter, default 5) |
| Repeat Customers | Repeat versus one-time customers |
| KPI Cards | Customer-focused headline figures |

**Filters:** Year, Region, Category, Segment, Customer.
**Parameters:** *Top Customers* (how many customers to show).
**Rules:**
- **Tier** is based on each customer's lifetime revenue: 5000 or more is Platinum, 2000 or more is Gold, 500 or more is Silver, otherwise Bronze.
- **Repeat customer** means more than one distinct order.
**SQL reference:** Queries 5, 6, 7, 8, 16 and Report 2.

---

## 7. Sales Trends Analysis

**Purpose:** how revenue and profit change over time.

| Sheet | What it shows |
|---|---|
| Total Revenue, Total Profit, Total Orders | Headline figures for the current filters |
| Monthly Revenue | Revenue by month |
| Monthly Profit | Profit by month |
| Running Revenue | Cumulative revenue over time |
| Year-over-Year comparison | Annual revenue side by side |

**Filters:** Year, Quarter, Month, Region, Category, Segment.
**SQL reference:** Queries 9, 11, 13 and Report 3.

---

## 8. Sales Trends Analysis - Seasonality

**Purpose:** seasonal patterns, growth and month-to-month profit changes.

| Sheet | What it shows |
|---|---|
| Total Revenue, Total Profit, Total Orders | Same KPIs as the trends page |
| Quarterly Revenue | Revenue by quarter |
| Sales Seasonality | Average revenue for each calendar month |
| Major Profit increases/decreases | Next month's profit minus this month's |
| YoY Growth | Revenue growth against the prior year |

**Filters:** Year, Quarter, Month, Region, Category, Segment.
**Calculation notes:**
- `Profit Swing (Next Month)` is `LOOKUP(SUM(Profit), 1) - SUM(Profit)`. It needs **Compute Using > Year Month** to draw. The last month is always empty, because no later month exists.
- `Avg Monthly Revenue` divides total sales by the number of distinct years that have sales.
**SQL reference:** Queries 10, 11, 12 and 20.

---

## 9. Geography Map

**Purpose:** a full-screen map of sales by state.

| Sheet | What it shows |
|---|---|
| Map - Sales by State | A map with Profit as colour and Sales as size, one mark per state |

**Filters:** none on this dashboard.
**Interaction:** clicking a state on the map filters the sheets on **Geography Analysis**.
**Requirement:** the map needs the country set to **United States** (*Map > Edit Locations*). The workbook's saved default country is Egypt.
**SQL reference:** Query 4.

---

## 10. Geography Analysis

**Purpose:** revenue and profit by location, without the map.

| Sheet | What it shows |
|---|---|
| Revenue by State | Revenue for each state |
| Sales by Region (Geography) | Revenue for each region |
| City Profitability | Profit by city, with a profit colour legend |

**Filters:** Region, State, City, Ship Mode, Category, Year.
**SQL reference:** Queries 4 and 19.

---

## 11. Shipping and Orders Analysis

**Purpose:** delivery performance and the biggest individual sales.

| Sheet | What it shows |
|---|---|
| Shipping Analysis | Sales, profit and related measures for each ship mode |
| Largest Order Line | The single largest order line in each category |

**Filters:** Region, State, City, Ship Mode, Category, Year.
**Note:** if two order lines tie for largest, Tableau can show both, whereas SQL Query 18 returns exactly one.
**SQL reference:** Queries 17 and 18.

---

## 12. Metric definitions

| Metric | Definition |
|---|---|
| Total Sales | `SUM(SalesAmount)` |
| Total Profit | `SUM(ProfitAmount)` |
| Profit Margin % | `SUM(Profit) / SUM(Sales)`, blank when sales are zero |
| Total Orders | `COUNTD(OrderID)` |
| Total Customers | `COUNTD(CustomerKey)` |
| Average Order Value | `SUM(Sales) / COUNTD(OrderID)` |
| Revenue per Customer | `SUM(Sales) / COUNTD(CustomerKey)` |
| Avg Orders per Customer | `COUNTD(OrderID) / COUNTD(CustomerKey)` |
| Customer Lifetime Revenue | `{ FIXED CustomerKey : SUM(Sales) }` |
| Revenue Growth % (vs prior period) | `(this period - prior period) / ABS(prior period)` |
| Profit Direction / Profit / Loss | Labels a result Positive/Negative or Profit/Loss |

---

## 13. Filters and interactions

| Dashboards | Filters |
|---|---|
| Executive Overview | Year, Category, Region, Segment |
| Profitability Analysis (both pages) | Year, Category, Sub-Category, Region, State |
| Customer Behavior Analysis | Year, Region, Category, Segment, Customer |
| Sales Trends Analysis (both pages) | Year, Quarter, Month, Region, Category, Segment |
| Geography Analysis, Shipping and Orders Analysis | Region, State, City, Ship Mode, Category, Year |
| Home, Geography Map | none |

All dashboards share one data source, so a filter on the same field behaves the same everywhere.

---

## 14. Known limitations

- **Empty periods:** `dim_Date` runs from 2012-12-25 to 2017-01-07, a buffer around the 2013–2016 sales. Trend charts can show "2 nulls" indicators and 2012 and 2017 on year axes. Totals are not affected. Fix with a data source filter on Year Number (2013–2016) or *Filter data* on the indicator.
- **Profit Swing:** needs Compute Using set to Year Month, otherwise the chart is empty.
- **Map:** needs the country set to United States.
- **Version:** the workbook was saved in Tableau 2026.2, and older versions may fail to load it.
- **Validation:** calculation logic has been compared with the SQL queries. Numeric results have not yet been compared against SQL output.
