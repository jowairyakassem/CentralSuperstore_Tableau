# Shaza – Central Superstore Profitability Dashboard

## Objective
Analyze business profitability and identify categories, products, and factors that contribute to profit or loss.

## Data source and preparation
- Source: `Central_Superstore.csv` supplied for this project.
- Records: **2,323** rows and **21** columns.
- Order dates range from **2013-01-03** to **2016-12-30**.
- `Order Date` and `Ship Date` are parsed from `MM/dd/yy` and saved as ISO dates in the packaged data copy.
- `Order ID` and `Postal Code` are treated as text dimensions; the source CSV is otherwise retained without dropping rows.
- `Region` contains 1 distinct value(s): **Central**. State is therefore the useful geographic comparison for this extract.

## Calculated fields
| Tableau field | Formula |
|---|---|
| Total Sales | `SUM([Sales])` |
| Total Profit | `SUM([Profit])` |
| Profit Margin % | `SUM([Profit]) / SUM([Sales])` |
| Order Year | `YEAR([Order Date])` |
| Profit Flag | `IF SUM([Profit]) < 0 THEN "Loss" ELSE "Profit" END` |
| Avg Discount Product (Q15) | `{ FIXED [Product ID], [Product Name] : AVG([Discount]) }` |
| Overall Avg Discount (Q15) | `{ FIXED : AVG([Discount]) }` |
| High Discount Product (Q15) | `[Avg Discount Product] > [Overall Avg Discount]` |

## Dashboard contents
1. KPI cards: Total Sales, Total Profit, Profit Margin %.
2. Profit by Category.
3. Profit by Sub-Category, sorted by profit.
4. Top 10 Profitable Products, grouped by Product Name.
5. Bottom 10 Products by Profit, grouped by Product Name.
6. Discount vs Profit.
7. Profit by State.
8. Profit by Region (one Central bar for this dataset).
9. Filters: Order Year, Category, Sub-Category, Region, State.

## Validation results (filters cleared)
| Check | CSV result | Expected | Status |
|---|---:|---:|---|
| Total Sales | $501,239.89 | $501,239.89 | PASS |
| Total Profit | $39,706.36 | $39,706.36 | PASS |
| Profit Margin | 7.92% | 7.92% | PASS |
| Furniture profit | $-2,871.05 | $-2,871.05 | PASS |
| Office Supplies profit | $8,879.98 | $8,879.98 | PASS |
| Technology profit | $33,697.43 | $33,697.43 | PASS |
| Top product | Canon imageCLASS 2200 Advanced Copier, $8,399.98 | Canon imageCLASS 2200 Advanced Copier, $8,399.98 | PASS |
| Bottom product | GBC DocuBind P400 Electric Binding System, $-3,048.62 | GBC DocuBind P400 Electric Binding System, -$3,048.62 | PASS |
| Texas profit | $-25,729.36 | $-25,729.36 | PASS |
| Illinois profit | $-12,607.89 | $-12,607.89 | PASS |
| Region values | Central | Central only | PASS |

### SQL alignment
- Q1: product profitability ranking, using `Product Name` and summed profit.
- Q2: category revenue, profit, and profit margin.
- Q3: sub-category profitability and margin bands.
- Q15: products whose average discount is above the overall average discount.

### Q15 optional check
- Overall average row-level discount: 24.0353%.
- Products above the overall average discount: **375** (CSV-derived result; differs from the optional expected check of 373, because it counts by Product ID + Name rather than by Product Name alone).
- Combined profit of those products: **-$27,473.25**.
- Loss-making products among that set: **314** (CSV-derived result; differs from the optional expected check of 313, same reason).

### Findings from the CSV
- Overall margin is **7.92%**, so profitability is thin relative to sales.
- Technology contributes 84.9% of total profit; Furniture is loss-making.
- The discount bands below are calculated from row-level discounts in the supplied CSV; interpret them as association, not proof that discounts alone caused the losses.
- **0% discount:** profit $76,125.44 across 828 order lines.
- **1–20% discount:** profit $15,973.20 across 852 order lines.
- **21–40% discount:** profit $-11,598.84 across 187 order lines.
- **Above 40% discount:** profit $-40,793.44 across 456 order lines.
- Texas and Illinois are the two largest state-level losses in this extract. Their mean discounts are 37.0% and 39.0%, respectively.
- Profit in 2016 was $7,550.84 compared with $19,899.16 in 2015, a year-over-year change of -62.1% (using 2015 profit as the denominator).

## Formatting conventions
- Profit-positive marks: green (`#2E8B57`).
- Loss marks: red (`#C0392B`).
- Background: white; text: dark navy; muted gridlines.
- Currency values: USD, two decimals. Profit margin: percentage, two decimals.
- Product ranking sheets use aggregated profit by Product Name.

## Files
- `Tableau/Profitability.twb`: editable Tableau workbook XML.
- `Tableau/Profitability.twbx`: packaged workbook archive with the CSV data included.
- `Screenshots/Profitability_Dashboard_PREVIEW.png`: dashboard design preview generated outside Tableau; **not a screenshot from Tableau Desktop**.
- `Screenshots/Profitability_Furniture_Filter_PREVIEW.png`: filtered design preview; **not a screenshot from Tableau Desktop**.
- `SQL/Profitability_Validation.sql`: SQL queries to validate totals and Q1/Q2/Q3/Q15 outputs.

## Important limitation
This environment does not have Tableau Desktop or Tableau command-line tools available, so the generated `.twb`/`.twbx` XML has not been opened and validated inside Tableau. The PNGs are design previews, not genuine Tableau application screenshots. Open the workbook in Tableau Desktop/Public and verify/adjust any version-specific workbook XML behavior before treating the workbook as final. The workbook XML includes the 10 requested worksheet definitions, dashboard layout zones, calculated fields, and filter definitions on worksheets. Dashboard filter-card visibility and top/bottom-10 filter behavior still require confirmation in Tableau Desktop. The GitHub branch has not been pushed from this environment.

## Screenshots
The images in the `Screenshots/` folder are preview renders generated from the CSV analysis, not captures from Tableau Desktop, because Tableau could not be installed on my machine. The dashboard itself is in `Tableau/Profitability.twbx`.

## Notes
- `Tableau/Profitability.twbx` was generated programmatically and has not been opened in Tableau Desktop; please verify it opens and the totals match the validation table above.
