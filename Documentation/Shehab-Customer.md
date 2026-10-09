# Customer Behavior & Segmentation Analysis

## 📌 Project Overview

This project provides an end-to-end customer analytics module built in Tableau for the Central Superstore dataset. The primary objective is to analyze customer purchasing behavior, loyalty trends, lifetime value tiers, and revenue contribution across key customer segments.

## 🎯 Key Performance Indicators (KPIs)

- **Total Customers:** 629
- **Total Orders:** 1,175
- **Revenue per Customer:** $796.88
- **Average Orders per Customer:** 1.87

## ⚙️ Calculated Fields & Business Logic

### 1. Customer Loyalty & Retention

**Orders Per Customer**
```text
{ FIXED [CustomerKey (dim Customer)] : COUNTD([OrderID]) }
```

**Customer Type**
```text
IF [Orders Per Customer] > 1 THEN "Repeat Customer"
ELSE "One-Time Customer"
END
```

### 2. Customer Lifetime Value & Tiering

**Customer Lifetime Revenue**
```text
{ FIXED [CustomerKey (dim Customer)] : SUM([Sales Amount]) }
```

**Customer Tier**
```text
IF [Customer Lifetime Revenue] >= 5000 THEN "Platinum"
ELSEIF [Customer Lifetime Revenue] >= 2500 THEN "Gold"
ELSEIF [Customer Lifetime Revenue] >= 1000 THEN "Silver"
ELSE "Bronze"
END
```

### 3. Aggregate Measures

- **Total Customers:** `COUNTD([CustomerKey (dim Customer)])`
- **Total Orders:** `COUNTD([OrderID])`
- **Revenue per Customer:** `SUM([Sales Amount]) / [Total Customers]`
- **Average Orders per Customer:** `[Total Orders] / [Total Customers]`

## 📊 Worksheets & Visual Analysis

| Worksheet | Chart Type | Key Takeaways |
|---|---|---|
| KPI Cards | Executive Summary Banner | High-level summary of total volume, customer base, and average value. |
| Revenue by Segment | Horizontal Bar Chart | Evaluates revenue contribution across Consumer, Corporate, and Home Office segments. |
| Customers by Segment | Horizontal Bar Chart | Compares customer distribution across market segments. |
| Repeat Customers | Horizontal Bar Chart | Evaluates customer retention by comparing repeat and one-time purchasers. |
| Customer Tiers | Categorical Bar Chart | Highlights customer distribution across tiers: Bronze (472), Silver (119), Gold (28), and Platinum (10). |
| Top Customers by Segment | Filtered Ranked Bar Chart | Ranks top customers by total spend, with dynamic context filtering by segment. |

## 🖥️ Dashboard Architecture

**Executive Multi-Row Layout**

- **Top Row:** Compact KPI summary banner for immediate executive visibility.
- **Middle Row:** Side-by-side segment analysis (revenue vs. customer count), alongside customer retention and tier distribution.
- **Bottom Row:** Detailed ranking of high-value customers with dedicated segment controls.

**Interactivity:** Integrated cross-filtering using *Use as Filter*, enabling seamless data exploration across dimensions.

## 📁 Repository Deliverables

- **Workbook Path:** `Tableau/Shehab-Customer/Customer_Behavior_Analysis.twbx`
- **Format:** Tableau Packaged Workbook (`.twbx`) with embedded data.
