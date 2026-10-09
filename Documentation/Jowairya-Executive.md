# Jowairya Kassem | Executive Overview Dashboard

## 1. Overview

The Executive Overview dashboard is the Tableau visualization component of the Central Superstore Analytics project. It provides a consolidated view of sales performance, profitability, customer activity, product performance, and regional sales.

The dashboard connects to the `CentralSuperstoreDW` SQL Server data warehouse and uses its fact and dimension tables to support interactive business analysis.

## 2. Objectives

- Monitor the main sales and profitability KPIs.
- Compare sales and profit performance over time.
- Identify the best-performing product categories and products by sales.
- Compare sales across geographical regions.
- Allow users to explore performance using interactive filters.
- Present the results in a clear and accessible executive dashboard.

## 3. Tools and Technologies

- **Tableau Desktop:** Dashboard development and data visualization.
- **Microsoft SQL Server:** Data storage and warehouse.
- **SQL Server Management Studio (SSMS):** Database management and validation.
- **Git and GitHub:** Version control and project collaboration.

## 4. Data Sources

The dashboard uses the following tables from the `CentralSuperstoreDW` database:

| Table | Purpose |
|---|---|
| `dw.fact_Sales` | Sales transactions and numerical measures |
| `dw.dim_Date` | Date attributes for time-based analysis |
| `dw.dim_Customer` | Customer and segment information |
| `dw.dim_Geography` | Geographical attributes and regions |
| `dw.dim_Product` | Product names, categories, and sub-categories |

The fact table is related to the dimension tables through their corresponding key fields.

## 5. Dashboard KPIs

The dashboard contains six KPI cards:

| KPI | Calculation |
|---|---|
| Total Sales | `SUM(Sales Amount)` |
| Total Profit | `SUM(Profit Amount)` |
| Profit Margin | `SUM(Profit Amount) / SUM(Sales Amount)` |
| Total Orders | `COUNTD(Order ID)` |
| Total Customers | `COUNTD(Customer Key)` |
| Average Order Value | `SUM(Sales Amount) / COUNTD(Order ID)` |

Profit Margin is displayed as a percentage. Average Order Value represents total sales divided by the number of distinct orders.

## 6. Visualizations

### 6.1 Sales Trend Over Time
A line chart showing how sales change over time. It helps identify sales patterns and compare performance across periods.

### 6.2 Profit Trend Over Time
A line chart showing profit changes over time. It supports monitoring profitability and identifying periods with changes in profit performance.

### 6.3 Sales by Product Category
A horizontal bar chart comparing total sales across product categories.

### 6.4 Profit by Product Category
A horizontal bar chart comparing total profit across product categories. It helps distinguish sales contribution from profitability.

### 6.5 Top 10 Products by Sales
A horizontal bar chart highlighting the products with the highest sales. The Top 10 filter keeps the comparison focused on leading products.

### 6.6 Sales by Region
A horizontal bar chart comparing total sales across geographical regions.

## 7. Interactive Filters

The dashboard includes the following filters:

- **Year:** Explore performance across different years.
- **Category:** Focus on selected product categories.
- **Region:** Compare performance across geographical regions.
- **Segment:** Analyze sales and profitability for different customer segments.

These filters allow users to investigate specific parts of the dataset without changing the underlying data model.

## 8. Baseline KPI Results

The following values were validated against the SQL Server data warehouse using the unfiltered dataset.

| KPI | Expected Value |
|---|---:|
| Total Sales | 501,239.89 |
| Total Profit | 39,706.36 |
| Profit Margin | 7.92% |
| Total Orders | 1,175 |
| Total Customers | 629 |
| Average Order Value | 426.59 |

Values may differ when dashboard filters are applied.

## 9. Design Approach

The dashboard follows business-focused data visualization principles:

- Use KPI cards to make the main performance indicators easy to scan.
- Use line charts for time-based trends.
- Use horizontal bar charts for comparisons across categories, products, and regions.
- Sort comparison charts to make high-performing items easier to identify.
- Use consistent formatting and restrained colors.
- Avoid unnecessary visual clutter and excessive labels.
- Use descriptive chart titles to communicate what each visualization measures.

These choices are informed by the principles in *Storytelling with Data: A Data Visualization Guide for Business Professionals* by Cole Nussbaumer Knaflic.

## 10. Validation and Testing

The dashboard should be checked to ensure that:

- KPI values match the equivalent SQL calculations.
- Order and customer counts use distinct identifiers.
- Time-based charts use the correct date field.
- Category, region, year, and segment filters affect the intended visualizations.
- The Top Products chart displays the highest-selling products.
- Profit calculations correctly include negative profit values.
- The dashboard remains readable when displayed at its intended size.

## 11. Deliverable

**Workbook:** `Executive_Overview.twbx`

**Repository location:** `Tableau/Jowairya_Executive/Executive_Overview.twbx`

The packaged Tableau workbook is maintained in the `jowairya-executive` GitHub branch.

**Note:** The workbook connects to a SQL Server instance configured on the development machine. Other users may need to configure their own connection to the database before refreshing the data.

## 12. Summary

The Executive Overview dashboard combines six KPI cards, six visualizations, and four interactive filters to provide a consolidated view of Central Superstore's sales and profitability. It supports comparisons across time, products, categories, regions, and customer segments using data from the SQL Server warehouse.
