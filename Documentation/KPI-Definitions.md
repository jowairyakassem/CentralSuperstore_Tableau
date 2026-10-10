# Central Superstore Analytics: KPI Definitions

**Workbook:** `Central_Superstore_Analytics.twbx`
**Source:** SQL Server database `CentralSuperstoreDW` (star schema, `dw.fact_Sales` at the centre)
**Grain:** one row per order line. Every KPI below is calculated from that table, filtered by whatever dashboard filters are active.

---

## Contents

1. [Headline KPIs](#1-headline-kpis)
2. [Customer KPIs](#2-customer-kpis)
3. [Trend and growth KPIs](#3-trend-and-growth-kpis)
4. [Ranking and classification fields](#4-ranking-and-classification-fields)
5. [Reading the KPIs correctly](#5-reading-the-kpis-correctly)

---

## 1. Headline KPIs

### Total Sales
| | |
|---|---|
| **Meaning** | All revenue from sold items |
| **Tableau** | `SUM([SalesAmount])` |
| **SQL** | `SUM(f.SalesAmount)` (Query 14, `rpt.vw_ExecutiveKPIs`) |
| **Unit** | Currency |
| **Shown on** | Executive Overview, Profitability Analysis (both pages), Sales Trends (both pages, labelled Total Revenue) |

### Total Profit
| | |
|---|---|
| **Meaning** | Revenue left after costs. Can be negative |
| **Tableau** | `SUM([ProfitAmount])` |
| **SQL** | `SUM(f.ProfitAmount)` (Query 14) |
| **Unit** | Currency |
| **Shown on** | Executive Overview, Profitability Analysis (both pages), Sales Trends (both pages) |

### Profit Margin %
| | |
|---|---|
| **Meaning** | How much of each sales dollar is kept as profit |
| **Tableau** | `IF SUM([SalesAmount]) = 0 THEN NULL ELSE SUM([ProfitAmount]) / SUM([SalesAmount]) END` |
| **SQL** | `SUM(Profit) * 100.0 / NULLIF(SUM(Sales), 0)` (Query 2, view) |
| **Unit** | Percent |
| **Note** | SQL returns it already multiplied by 100 (for example 12.34). Tableau returns a ratio and formats it as a percentage |
| **Shown on** | Executive Overview, Profitability Analysis (both pages) |

### Total Orders
| | |
|---|---|
| **Meaning** | Number of distinct orders. An order with several lines counts once |
| **Tableau** | `COUNTD([OrderID])` |
| **SQL** | `COUNT(DISTINCT f.OrderID)` (Query 14) |
| **Unit** | Count |
| **Shown on** | Executive Overview, Sales Trends (both pages) |

### Average Order Value (AOV)
| | |
|---|---|
| **Meaning** | Average revenue per order |
| **Tableau** | `IF COUNTD([OrderID]) = 0 THEN NULL ELSE SUM([SalesAmount]) / COUNTD([OrderID]) END` |
| **SQL** | `SUM(Sales) / NULLIF(COUNT(DISTINCT OrderID), 0)` (Queries 6, 14) |
| **Unit** | Currency per order |
| **Shown on** | Executive Overview |

---

## 2. Customer KPIs

### Total Customers
| | |
|---|---|
| **Meaning** | Number of distinct customers who bought |
| **Tableau** | `COUNTD([CustomerKey])` |
| **SQL** | `COUNT(DISTINCT f.CustomerKey)` (Query 14) |
| **Unit** | Count |
| **Shown on** | Executive Overview |

### Revenue per Customer
| | |
|---|---|
| **Meaning** | Average spend per customer |
| **Tableau** | `SUM([SalesAmount]) / COUNTD([CustomerKey])` |
| **SQL** | Called `CustomerLifetimeValue` in Query 14: `SUM(Sales) / NULLIF(COUNT(DISTINCT CustomerKey), 0)` |
| **Unit** | Currency per customer |

### Avg Orders per Customer
| | |
|---|---|
| **Meaning** | How many orders a typical customer places |
| **Tableau** | `COUNTD([OrderID]) / COUNTD([CustomerKey])` |
| **SQL** | `AVG(1.0 * Orders)` per customer (Report 2) |
| **Unit** | Orders per customer |

### Customer Lifetime Revenue
| | |
|---|---|
| **Meaning** | One customer's total spend across all years |
| **Tableau** | `{ FIXED [CustomerKey (dim_Customer)] : SUM([SalesAmount]) }` |
| **SQL** | `SUM(f.SalesAmount)` grouped by customer (Queries 5, 7) |
| **Note** | The FIXED expression ignores the chart's dimensions, so each customer keeps their full total |

### Orders Per Customer
| | |
|---|---|
| **Meaning** | Distinct orders placed by one customer |
| **Tableau** | `{ FIXED [CustomerKey (dim_Customer)] : COUNTD([OrderID]) }` |
| **SQL** | `COUNT(DISTINCT OrderID)` per customer (Query 8) |

### Customer Type
| Value | Rule |
|---|---|
| Repeat Customer | Orders Per Customer is greater than 1 |
| One-Time Customer | Orders Per Customer is 1 |

SQL equivalent: Query 8 (it labels the second group "One Time Customer").

### Customer Tier
| Tier | Lifetime revenue |
|---|---|
| Platinum | 5,000 or more |
| Gold | 2,000 to under 5,000 |
| Silver | 500 to under 2,000 |
| Bronze | Under 500 |

SQL equivalent: Query 7 uses the same thresholds.

---

## 3. Trend and growth KPIs

### Monthly Revenue and Monthly Profit
| | |
|---|---|
| **Meaning** | Sales and profit for each calendar month |
| **Tableau** | `SUM([SalesAmount])` and `SUM([ProfitAmount])` by Year Month |
| **SQL** | Query 9 |

### Quarterly Revenue
| | |
|---|---|
| **Meaning** | Sales per quarter, split by year |
| **Tableau** | `SUM([SalesAmount])` by Quarter Name |
| **SQL** | Query 10 |

### Running Revenue
| | |
|---|---|
| **Meaning** | Cumulative revenue from the first month to each month |
| **Tableau** | Running sum of `SUM([SalesAmount])` across Year Month |
| **SQL** | `SUM(MonthlyRevenue) OVER (ORDER BY YearMonth ROWS UNBOUNDED PRECEDING)` (Query 13) |

### Revenue Growth % (vs prior period)
| | |
|---|---|
| **Meaning** | Percentage change in revenue against the previous period |
| **Tableau** | `(ZN(SUM(Sales)) - LOOKUP(ZN(SUM(Sales)), -1)) / ABS(LOOKUP(ZN(SUM(Sales)), -1))` |
| **SQL** | `(Revenue - LAG(Revenue)) * 100.0 / NULLIF(LAG(Revenue), 0)` (Query 11, Report 3) |
| **Note** | The first period has no prior value, so it is empty |

### Avg Monthly Revenue (seasonality)
| | |
|---|---|
| **Meaning** | Typical revenue for a calendar month, averaged across the years |
| **Tableau** | `SUM([SalesAmount]) / COUNTD(IF NOT ISNULL([SalesAmount]) THEN [YearNumber] END)` |
| **SQL** | Query 12 |
| **Note** | Divides by the number of years that have sales, not by the number of months |

### Profit Swing (Next Month)
| | |
|---|---|
| **Meaning** | Next month's profit minus this month's. Positive means profit rises next month |
| **Tableau** | `LOOKUP(SUM([ProfitAmount]), 1) - SUM([ProfitAmount])` |
| **SQL** | `LEAD(MonthlyProfit) - MonthlyProfit` (Query 20) |
| **Note** | Needs **Compute Using > Year Month**. The last month is always empty |

---

## 4. Ranking and classification fields

| Field | Rule | Used for |
|---|---|---|
| Profit Rank (Top) | `RANK_UNIQUE(SUM([ProfitAmount]), 'desc')` | Top 10 Profitable Products |
| Profit Rank (Bottom) | `RANK_UNIQUE(SUM([ProfitAmount]), 'asc')` | Bottom 10 Products by Profit |
| Largest Line Rank | `RANK(MAX([SalesAmount]))` | Largest Order Line per category |
| Profit Direction | Negative if profit is below 0, otherwise Positive | Colouring and labels |
| Profit / Loss | Loss if profit is below 0, otherwise Profit | Colouring and labels |

**Parameters**

| Parameter | Default | Purpose |
|---|---|---|
| Top Customers | 5 | Number of customers shown in the top-customers chart |
| Profit Bin Size | 200 | Bucket width for profit distributions |

---

## 5. Reading the KPIs correctly

- **Filters apply to every KPI.** The same field filtered on any dashboard gives the same result everywhere, because all dashboards share one data source.
- **Distinct counts.** Orders and customers are counted once each, no matter how many order lines they have, so they will not add up if you sum them across categories.
- **Margin is a ratio, not an average.** It is total profit divided by total sales for the selection, not the average of line margins.
- **Empty periods.** `dim_Date` runs from 2012-12-25 to 2017-01-07, a buffer around the 2013–2016 sales. Trend charts may show "null" indicators for those empty periods. Totals are not affected.
- **Validation status.** The formulas above match the SQL logic. The numeric results have not yet been compared against SQL output.
