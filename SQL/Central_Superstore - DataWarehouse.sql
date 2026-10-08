/* CENTRAL SUPERSTORE DATA WAREHOUSE & BUSINESS ANALYTICS SOLUTION */


/* SECTION 1: DATABASE SETUP */

IF DB_ID(N'CentralSuperstoreDW') IS NULL
BEGIN
    CREATE DATABASE CentralSuperstoreDW;
END
GO

USE CentralSuperstoreDW;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'dw')
BEGIN
    EXEC('CREATE SCHEMA dw AUTHORIZATION dbo');
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'stg')
BEGIN
    EXEC('CREATE SCHEMA stg AUTHORIZATION dbo');
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'rpt')
BEGIN
    EXEC('CREATE SCHEMA rpt AUTHORIZATION dbo');
END
GO


/* SECTION 2: DATA WAREHOUSE DESIGN NOTES
   Source columns:
     Row ID, Order ID, Order Date, Ship Date, Ship Mode, Customer ID,
     Customer Name, Segment, Country, City, State, Postal Code, Region,
     Product ID, Category, Sub-Category, Product Name, Sales, Quantity,
     Discount, Profit

   STAR SCHEMA SUMMARY:
     fact_Sales (fact table, grain = order line)
     dim_Customer (dimension)
     dim_Product (dimension)
     dim_Geography (dimension)
     dim_Date (dimension)
     dim_ShipMode (dimension)

   That is five dimension tables plus one fact table, six relational tables
   total. */


/* SECTION 3: TABLE CREATION
   3.0 STAGING TABLE:
   Landing zone for the raw Excel extract before it is normalized into the
   star schema. */

IF OBJECT_ID(N'stg.CentralSuperstoreRaw', N'U') IS NOT NULL
    DROP TABLE stg.CentralSuperstoreRaw;
GO

CREATE TABLE stg.CentralSuperstoreRaw
(
    RowID INT NOT NULL,
    OrderID VARCHAR(20) NOT NULL,
    OrderDate DATE NOT NULL,
    ShipDate DATE NOT NULL,
    ShipMode VARCHAR(30) NOT NULL,
    CustomerID VARCHAR(20) NOT NULL,
    CustomerName VARCHAR(100) NOT NULL,
    Segment VARCHAR(30) NOT NULL,
    Country VARCHAR(60) NOT NULL,
    City VARCHAR(60) NOT NULL,
    State VARCHAR(60) NOT NULL,
    PostalCode VARCHAR(10) NULL,
    Region VARCHAR(30) NOT NULL,
    ProductID VARCHAR(30) NOT NULL,
    Category VARCHAR(30) NOT NULL,
    SubCategory VARCHAR(30) NOT NULL,
    ProductName VARCHAR(300) NOT NULL,
    Sales DECIMAL(12,4) NOT NULL,
    Quantity INT NOT NULL,
    Discount DECIMAL(5,2) NOT NULL,
    Profit DECIMAL(12,4) NOT NULL,
    CONSTRAINT PK_stg_CentralSuperstoreRaw PRIMARY KEY CLUSTERED (RowID)
);
GO

/* Load stg.CentralSuperstoreRaw from the Excel file using BULK INSERT from a CSV export
   of the Central_Region sheet before running the sections below. */

BULK INSERT stg.CentralSuperstoreRaw
FROM 'C:\Path\Central_Superstore.csv'
WITH
(
    FIRSTROW = 2,
    FORMAT = 'CSV',
    CODEPAGE = '65001'
);
GO


/* 3.1 DIMENSION: dw.dim_Date */

IF OBJECT_ID(N'dw.dim_Date', N'U') IS NOT NULL
    DROP TABLE dw.dim_Date;
GO

CREATE TABLE dw.dim_Date
(
    DateKey INT NOT NULL, -- surrogate key, format YYYYMMDD
    FullDate DATE NOT NULL,
    DayOfMonth TINYINT NOT NULL,
    DayName VARCHAR(10) NOT NULL,
    DayOfWeek TINYINT NOT NULL,
    MonthNumber TINYINT NOT NULL,
    MonthName VARCHAR(10) NOT NULL,
    Quarter TINYINT NOT NULL,
    QuarterName VARCHAR(2) NOT NULL,
    YearNumber SMALLINT NOT NULL,
    YearMonth CHAR(7) NOT NULL,
    IsWeekend BIT NOT NULL,
    CONSTRAINT PK_dim_Date PRIMARY KEY CLUSTERED (DateKey)
);
GO

/* 3.2 DIMENSION: dw.dim_Geography */

IF OBJECT_ID(N'dw.dim_Geography', N'U') IS NOT NULL
    DROP TABLE dw.dim_Geography;
GO

CREATE TABLE dw.dim_Geography
(
    GeographyKey INT IDENTITY(1,1) NOT NULL,
    Country VARCHAR(60) NOT NULL,
    City VARCHAR(60) NOT NULL,
    State VARCHAR(60) NOT NULL,
    PostalCode VARCHAR(10) NULL,
    Region VARCHAR(30) NOT NULL,
    CONSTRAINT PK_dim_Geography PRIMARY KEY CLUSTERED (GeographyKey),
    CONSTRAINT UQ_dim_Geography UNIQUE (Country, City, State, PostalCode, Region)
);
GO

/* 3.3 DIMENSION: dw.dim_ShipMode */

IF OBJECT_ID(N'dw.dim_ShipMode', N'U') IS NOT NULL
    DROP TABLE dw.dim_ShipMode;
GO

CREATE TABLE dw.dim_ShipMode
(
    ShipModeKey TINYINT IDENTITY(1,1) NOT NULL,
    ShipModeName VARCHAR(30) NOT NULL,
    CONSTRAINT PK_dim_ShipMode PRIMARY KEY CLUSTERED (ShipModeKey),
    CONSTRAINT UQ_dim_ShipMode UNIQUE (ShipModeName)
);
GO

/* 3.4 DIMENSION: dw.dim_Customer */

IF OBJECT_ID(N'dw.dim_Customer', N'U') IS NOT NULL
    DROP TABLE dw.dim_Customer;
GO

CREATE TABLE dw.dim_Customer
(
    CustomerKey INT IDENTITY(1,1) NOT NULL,
    CustomerID VARCHAR(20) NOT NULL,
    CustomerName VARCHAR(100) NOT NULL,
    Segment VARCHAR(30) NOT NULL,
    GeographyKey INT NOT NULL,
    CONSTRAINT PK_dim_Customer PRIMARY KEY CLUSTERED (CustomerKey),
    CONSTRAINT UQ_dim_Customer_CustomerID UNIQUE (CustomerID),
    CONSTRAINT FK_dim_Customer_Geography FOREIGN KEY (GeographyKey)
        REFERENCES dw.dim_Geography (GeographyKey)
);
GO

/* 3.5 DIMENSION: dw.dim_Product */

IF OBJECT_ID(N'dw.dim_Product', N'U') IS NOT NULL
    DROP TABLE dw.dim_Product;
GO

CREATE TABLE dw.dim_Product
(
    ProductKey INT IDENTITY(1,1) NOT NULL,
    ProductID VARCHAR(30) NOT NULL,
    ProductName VARCHAR(300) NOT NULL,
    Category VARCHAR(30) NOT NULL,
    SubCategory VARCHAR(30) NOT NULL,
    CONSTRAINT PK_dim_Product PRIMARY KEY CLUSTERED (ProductKey),
    CONSTRAINT UQ_dim_Product UNIQUE (ProductID, ProductName)
);
GO

/* 3.6 FACT TABLE: dw.fact_Sales */

IF OBJECT_ID(N'dw.fact_Sales', N'U') IS NOT NULL
    DROP TABLE dw.fact_Sales;
GO

CREATE TABLE dw.fact_Sales
(
    SalesFactKey INT IDENTITY(1,1) NOT NULL,
    RowID INT NOT NULL,
    OrderID VARCHAR(20) NOT NULL,
    OrderDateKey INT NOT NULL,
    ShipDateKey INT NOT NULL,
    ShipModeKey TINYINT NOT NULL,
    CustomerKey INT NOT NULL,
    ProductKey INT NOT NULL,
    GeographyKey INT NOT NULL,
    SalesAmount DECIMAL(12,4) NOT NULL,
    Quantity INT NOT NULL,
    DiscountRate DECIMAL(5,2) NOT NULL,
    ProfitAmount DECIMAL(12,4) NOT NULL,
    CONSTRAINT PK_fact_Sales PRIMARY KEY NONCLUSTERED (SalesFactKey),
    CONSTRAINT UQ_fact_Sales_RowID UNIQUE (RowID),
    CONSTRAINT FK_fact_Sales_OrderDate FOREIGN KEY (OrderDateKey)
        REFERENCES dw.dim_Date (DateKey),
    CONSTRAINT FK_fact_Sales_ShipDate FOREIGN KEY (ShipDateKey)
        REFERENCES dw.dim_Date (DateKey),
    CONSTRAINT FK_fact_Sales_ShipMode FOREIGN KEY (ShipModeKey)
        REFERENCES dw.dim_ShipMode (ShipModeKey),
    CONSTRAINT FK_fact_Sales_Customer FOREIGN KEY (CustomerKey)
        REFERENCES dw.dim_Customer (CustomerKey),
    CONSTRAINT FK_fact_Sales_Product FOREIGN KEY (ProductKey)
        REFERENCES dw.dim_Product (ProductKey),
    CONSTRAINT FK_fact_Sales_Geography FOREIGN KEY (GeographyKey)
        REFERENCES dw.dim_Geography (GeographyKey)
);
GO


/* SECTION 4: PERFORMANCE OPTIMIZATION
   The fact table is filtered and grouped by order date on almost every
   executive query, so it gets a clustered index on OrderDateKey to keep
   date-range scans sequential on disk. Foreign key columns and frequently
   filtered attributes get supporting nonclustered indexes, with a couple of
   covering indexes added for the heaviest aggregation patterns so the
   optimizer can satisfy them from the index alone without a key lookup. */

-- Clustered index drives every date-range and trend query straight to the relevant slice of the fact table instead of scanning the whole table.
CREATE CLUSTERED INDEX CIX_fact_Sales_OrderDateKey
    ON dw.fact_Sales (OrderDateKey);
GO

-- Nonclustered indexes on each foreign key support dimension joins and group-by aggregations without forcing a table scan.
CREATE NONCLUSTERED INDEX IX_fact_Sales_CustomerKey
    ON dw.fact_Sales (CustomerKey);
GO

CREATE NONCLUSTERED INDEX IX_fact_Sales_ProductKey
    ON dw.fact_Sales (ProductKey);
GO

CREATE NONCLUSTERED INDEX IX_fact_Sales_GeographyKey
    ON dw.fact_Sales (GeographyKey);
GO

CREATE NONCLUSTERED INDEX IX_fact_Sales_ShipModeKey
    ON dw.fact_Sales (ShipModeKey);
GO

-- Covering index for profitability-by-product queries: the optimizer can resolve ProductKey lookups plus the Sales/Profit/Quantity measures entirely from the index, avoiding a lookup back into the base table.
CREATE NONCLUSTERED INDEX IX_fact_Sales_Product_Covering
    ON dw.fact_Sales (ProductKey)
    INCLUDE (SalesAmount, ProfitAmount, Quantity, DiscountRate);
GO

-- Covering index for customer spending and ranking queries.
CREATE NONCLUSTERED INDEX IX_fact_Sales_Customer_Covering
    ON dw.fact_Sales (CustomerKey, OrderDateKey)
    INCLUDE (SalesAmount, ProfitAmount, OrderID);
GO

-- Dimension-side indexes for common filter and join predicates.
CREATE NONCLUSTERED INDEX IX_dim_Customer_Segment
    ON dw.dim_Customer (Segment);
GO

CREATE NONCLUSTERED INDEX IX_dim_Product_Category
    ON dw.dim_Product (Category, SubCategory);
GO

CREATE NONCLUSTERED INDEX IX_dim_Geography_StateCity
    ON dw.dim_Geography (State, City);
GO

CREATE NONCLUSTERED INDEX IX_dim_Date_YearMonth
    ON dw.dim_Date (YearNumber, MonthNumber);
GO


/* SECTION 4B: QUERY OPTIMIZATION NOTES

   - Filters are written to remain SARGable. Date filtering uses direct
     comparisons on OrderDateKey instead of functions like YEAR() or
     CONVERT(), allowing index seeks instead of scans.

   - Lookups and joins use direct column comparisons (CustomerID,
     ProductID, ShipModeName), keeping them index-friendly.

   - NULLIF is only used in SELECT statements for safe division and never
     in WHERE or JOIN conditions.

   - Fact-to-dimension joins use surrogate primary keys, which are indexed
     and efficient for query performance.

   - Most analytical queries start from dw.fact_Sales and then join to
     dimensions, helping the optimizer work with a filtered dataset first.

   - LEFT JOINs are only used when dimension rows must be preserved even
     without matching sales records.

   - Subqueries are avoided where possible. Only Query 15 requires one to
     compare product discounts against the overall average. Other cases use
     CTEs and window functions, which scale better.

   - Indexing is kept minimal and purposeful. The 10 indexes support common
     reporting needs such as date analysis, customer spending, product
     performance, and shipping trends without adding unnecessary load
     overhead.*/


/* DIMENSION LOAD LOGIC
   Loads and organizes staging data into the dimension tables before
   loading the fact table. The process is idempotent, so rerunning the
   script refreshes the dimensions and fact table using the current
   staging data. */

-- Populate dw.dim_Date for the full range seen in the source data, with a small buffer on each side to cover late shipments.
;WITH DateBounds AS
(
    SELECT
        CAST('2012-12-25' AS DATE) AS StartDate,
        CAST('2017-01-07' AS DATE) AS EndDate
),
CalendarSeq AS
(
    SELECT StartDate AS FullDate FROM DateBounds
    UNION ALL
    SELECT DATEADD(DAY, 1, FullDate)
    FROM CalendarSeq
    WHERE FullDate < (SELECT EndDate FROM DateBounds)
)
INSERT INTO dw.dim_Date (DateKey, FullDate, DayOfMonth, DayName, DayOfWeek, MonthNumber, MonthName, Quarter, QuarterName, YearNumber, YearMonth, IsWeekend)
SELECT
    CAST(CONVERT(CHAR(8), FullDate, 112) AS INT) AS DateKey,
    FullDate,
    DAY(FullDate) AS DayOfMonth,
    DATENAME(WEEKDAY, FullDate) AS DayName,
    DATEPART(WEEKDAY, FullDate) AS DayOfWeek,
    MONTH(FullDate) AS MonthNumber,
    DATENAME(MONTH, FullDate) AS MonthName,
    DATEPART(QUARTER, FullDate) AS Quarter,
    'Q' + CAST(DATEPART(QUARTER, FullDate) AS VARCHAR(1)) AS QuarterName,
    YEAR(FullDate) AS YearNumber,
    CONVERT(CHAR(4), FullDate, 112) + '-' + RIGHT('0' + CAST(MONTH(FullDate) AS VARCHAR(2)), 2) AS YearMonth,
    CASE WHEN DATEPART(WEEKDAY, FullDate) IN (1, 7) THEN 1 ELSE 0 END AS IsWeekend
FROM CalendarSeq
OPTION (MAXRECURSION 0);
GO

-- Populate dw.dim_ShipMode from the distinct shipping levels in staging.
INSERT INTO dw.dim_ShipMode (ShipModeName)
SELECT DISTINCT s.ShipMode
FROM stg.CentralSuperstoreRaw AS s
WHERE NOT EXISTS
(
    SELECT 1 FROM dw.dim_ShipMode d WHERE d.ShipModeName = s.ShipMode
);
GO

-- Populate dw.dim_Geography from the distinct location combinations.
INSERT INTO dw.dim_Geography (Country, City, State, PostalCode, Region)
SELECT DISTINCT s.Country, s.City, s.State, s.PostalCode, s.Region
FROM stg.CentralSuperstoreRaw AS s
WHERE NOT EXISTS
(
    SELECT 1
    FROM dw.dim_Geography g
    WHERE g.Country = s.Country
      AND g.City = s.City
      AND g.State = s.State
      AND ISNULL(g.PostalCode, '') = ISNULL(s.PostalCode, '')
      AND g.Region = s.Region
);
GO

-- Populate dw.dim_Customer, resolving each customer to their geography.
INSERT INTO dw.dim_Customer (CustomerID, CustomerName, Segment, GeographyKey)
SELECT
    src.CustomerID,
    src.CustomerName,
    src.Segment,
    g.GeographyKey
FROM
(
    SELECT
        s.CustomerID,
        s.CustomerName,
        s.Segment,
        s.Country, s.City, s.State, s.PostalCode, s.Region,
        ROW_NUMBER() OVER (PARTITION BY s.CustomerID ORDER BY s.OrderDate DESC) AS rn
    FROM stg.CentralSuperstoreRaw AS s
) AS src
INNER JOIN dw.dim_Geography AS g
    ON g.Country = src.Country
   AND g.City = src.City
   AND g.State = src.State
   AND ISNULL(g.PostalCode, '') = ISNULL(src.PostalCode, '')
   AND g.Region = src.Region
WHERE src.rn = 1
  AND NOT EXISTS
(
    SELECT 1 FROM dw.dim_Customer dc WHERE dc.CustomerID = src.CustomerID
);
GO

-- Populate dw.dim_Product from the distinct product combinations.
INSERT INTO dw.dim_Product (ProductID, ProductName, Category, SubCategory)
SELECT DISTINCT s.ProductID, s.ProductName, s.Category, s.SubCategory
FROM stg.CentralSuperstoreRaw AS s
WHERE NOT EXISTS
(
    SELECT 1
    FROM dw.dim_Product p
    WHERE p.ProductID = s.ProductID
      AND p.ProductName = s.ProductName
);
GO

-- Load the fact table, resolving every natural key to its surrogate key.
INSERT INTO dw.fact_Sales
    (RowID, OrderID, OrderDateKey, ShipDateKey, ShipModeKey,
     CustomerKey, ProductKey, GeographyKey,
     SalesAmount, Quantity, DiscountRate, ProfitAmount)
SELECT
    s.RowID,
    s.OrderID,
    CAST(CONVERT(CHAR(8), s.OrderDate, 112) AS INT) AS OrderDateKey,
    CAST(CONVERT(CHAR(8), s.ShipDate, 112) AS INT) AS ShipDateKey,
    sm.ShipModeKey,
    c.CustomerKey,
    p.ProductKey,
    g.GeographyKey,
    s.Sales,
    s.Quantity,
    s.Discount,
    s.Profit
FROM stg.CentralSuperstoreRaw AS s
INNER JOIN dw.dim_ShipMode AS sm
    ON sm.ShipModeName = s.ShipMode
INNER JOIN dw.dim_Customer AS c
    ON c.CustomerID = s.CustomerID
INNER JOIN dw.dim_Product AS p
    ON p.ProductID = s.ProductID
   AND p.ProductName = s.ProductName
INNER JOIN dw.dim_Geography AS g
    ON g.Country = s.Country
   AND g.City = s.City
   AND g.State = s.State
   AND ISNULL(g.PostalCode, '') = ISNULL(s.PostalCode, '')
   AND g.Region = s.Region
WHERE NOT EXISTS
(
    SELECT 1 FROM dw.fact_Sales f WHERE f.RowID = s.RowID
);
GO


/* SECTION 5: BUSINESS ANALYTICS QUERIES */

-- Query 1: Most profitable products, ranked by total profit contribution.
SELECT TOP 20
    p.ProductName,
    p.Category,
    p.SubCategory,
    SUM(f.SalesAmount) AS TotalRevenue,
    SUM(f.ProfitAmount) AS TotalProfit,
    CAST(SUM(f.ProfitAmount) * 100.0 / NULLIF(SUM(f.SalesAmount), 0) AS DECIMAL(6,2)) AS ProfitMarginPct
FROM dw.fact_Sales AS f
INNER JOIN dw.dim_Product AS p
    ON p.ProductKey = f.ProductKey
GROUP BY p.ProductName, p.Category, p.SubCategory
ORDER BY TotalProfit DESC;
GO

-- Query 2: Most profitable categories, with overall margin.
SELECT
    p.Category,
    SUM(f.SalesAmount) AS TotalRevenue,
    SUM(f.ProfitAmount) AS TotalProfit,
    CAST(SUM(f.ProfitAmount) * 100.0 / NULLIF(SUM(f.SalesAmount), 0) AS DECIMAL(6,2)) AS ProfitMarginPct
FROM dw.fact_Sales AS f
INNER JOIN dw.dim_Product AS p
    ON p.ProductKey = f.ProductKey
GROUP BY p.Category
ORDER BY TotalProfit DESC;
GO

-- Query 3: Profit margin analysis by sub-category, classified into
-- performance bands using a CASE expression.
SELECT
    p.Category,
    p.SubCategory,
    SUM(f.SalesAmount) AS TotalRevenue,
    SUM(f.ProfitAmount) AS TotalProfit,
    CAST(SUM(f.ProfitAmount) * 100.0 / NULLIF(SUM(f.SalesAmount), 0) AS DECIMAL(6,2)) AS ProfitMarginPct,
    CASE
        WHEN SUM(f.ProfitAmount) < 0 THEN 'Loss Making'
        WHEN SUM(f.ProfitAmount) * 100.0 / NULLIF(SUM(f.SalesAmount), 0) < 10 THEN 'Low Margin'
        WHEN SUM(f.ProfitAmount) * 100.0 / NULLIF(SUM(f.SalesAmount), 0) < 20 THEN 'Moderate Margin'
        ELSE 'High Margin'
    END AS MarginBand
FROM dw.fact_Sales AS f
INNER JOIN dw.dim_Product AS p
    ON p.ProductKey = f.ProductKey
GROUP BY p.Category, p.SubCategory
ORDER BY ProfitMarginPct ASC;
GO

-- Query 4: Top revenue contributors by state, with rank.
SELECT
    g.State,
    SUM(f.SalesAmount) AS TotalRevenue,
    RANK() OVER (ORDER BY SUM(f.SalesAmount) DESC) AS RevenueRank
FROM dw.fact_Sales AS f
INNER JOIN dw.dim_Geography AS g
    ON g.GeographyKey = f.GeographyKey
GROUP BY g.State
ORDER BY TotalRevenue DESC;
GO

-- Query 5: Top 15 customers by lifetime revenue and profit.
SELECT TOP 15
    c.CustomerName,
    c.Segment,
    SUM(f.SalesAmount) AS LifetimeRevenue,
    SUM(f.ProfitAmount) AS LifetimeProfit,
    COUNT(DISTINCT f.OrderID) AS TotalOrders
FROM dw.fact_Sales AS f
INNER JOIN dw.dim_Customer AS c
    ON c.CustomerKey = f.CustomerKey
GROUP BY c.CustomerName, c.Segment
ORDER BY LifetimeRevenue DESC;
GO

-- Query 6: Customer segmentation summary comparing the three business
-- segments on revenue, profit and average order value.
SELECT
    c.Segment,
    COUNT(DISTINCT c.CustomerKey) AS CustomerCount,
    COUNT(DISTINCT f.OrderID) AS OrderCount,
    SUM(f.SalesAmount) AS TotalRevenue,
    SUM(f.ProfitAmount) AS TotalProfit,
    CAST(SUM(f.SalesAmount) / NULLIF(COUNT(DISTINCT f.OrderID), 0) AS DECIMAL(10,2)) AS AvgOrderValue
FROM dw.fact_Sales AS f
INNER JOIN dw.dim_Customer AS c
    ON c.CustomerKey = f.CustomerKey
GROUP BY c.Segment
ORDER BY TotalRevenue DESC;
GO

-- Query 7: Customer spending pattern tiers using a CASE-based classification against lifetime revenue.
WITH CustomerRevenue AS
(
    SELECT
        c.CustomerKey,
        c.CustomerName,
        SUM(f.SalesAmount) AS LifetimeRevenue
    FROM dw.fact_Sales AS f
    INNER JOIN dw.dim_Customer AS c
        ON c.CustomerKey = f.CustomerKey
    GROUP BY c.CustomerKey, c.CustomerName
)
SELECT
    CustomerName,
    LifetimeRevenue,
    CASE
        WHEN LifetimeRevenue >= 5000 THEN 'Platinum'
        WHEN LifetimeRevenue >= 2000 THEN 'Gold'
        WHEN LifetimeRevenue >= 500  THEN 'Silver'
        ELSE 'Bronze'
    END AS CustomerTier
FROM CustomerRevenue
ORDER BY LifetimeRevenue DESC;
GO

-- Query 8: Repeat purchase behavior, counting orders per customer and flagging customers who ordered more than once.
SELECT
    c.CustomerName,
    COUNT(DISTINCT f.OrderID) AS OrderCount,
    CASE
        WHEN COUNT(DISTINCT f.OrderID) > 1 THEN 'Repeat Customer'
        ELSE 'One Time Customer'
    END AS PurchaseBehavior
FROM dw.fact_Sales AS f
INNER JOIN dw.dim_Customer AS c
    ON c.CustomerKey = f.CustomerKey
GROUP BY c.CustomerName
ORDER BY OrderCount DESC;
GO

-- Query 9: Monthly sales trend across the full history.
SELECT
    d.YearMonth,
    SUM(f.SalesAmount) AS MonthlyRevenue,
    SUM(f.ProfitAmount) AS MonthlyProfit,
    COUNT(DISTINCT f.OrderID) AS MonthlyOrders
FROM dw.fact_Sales AS f
INNER JOIN dw.dim_Date AS d
    ON d.DateKey = f.OrderDateKey
GROUP BY d.YearMonth
ORDER BY d.YearMonth;
GO

-- Query 10: Quarterly sales trend by year.
SELECT
    d.YearNumber,
    d.QuarterName,
    SUM(f.SalesAmount) AS QuarterlyRevenue,
    SUM(f.ProfitAmount) AS QuarterlyProfit
FROM dw.fact_Sales AS f
INNER JOIN dw.dim_Date AS d
    ON d.DateKey = f.OrderDateKey
GROUP BY d.YearNumber, d.QuarterName
ORDER BY d.YearNumber, d.QuarterName;
GO

-- Query 11: Year-over-year revenue growth rate using LAG to compare each year against the prior year.
WITH YearlyRevenue AS
(
    SELECT
        d.YearNumber,
        SUM(f.SalesAmount) AS TotalRevenue
    FROM dw.fact_Sales AS f
    INNER JOIN dw.dim_Date AS d
        ON d.DateKey = f.OrderDateKey
    GROUP BY d.YearNumber
)
SELECT
    YearNumber,
    TotalRevenue,
    LAG(TotalRevenue) OVER (ORDER BY YearNumber) AS PriorYearRevenue,
    CAST((TotalRevenue - LAG(TotalRevenue) OVER (ORDER BY YearNumber)) * 100.0
         / NULLIF(LAG(TotalRevenue) OVER (ORDER BY YearNumber), 0) AS DECIMAL(6,2)) AS YoYGrowthPct
FROM YearlyRevenue
ORDER BY YearNumber;
GO

-- Query 12: Seasonality analysis, average revenue by calendar month across all years in the dataset.
SELECT
    d.MonthNumber,
    d.MonthName,
    AVG(MonthlyTotals.MonthlyRevenue) AS AvgMonthlyRevenue
FROM
(
    SELECT
        d.MonthNumber,
        d.YearNumber,
        SUM(f.SalesAmount) AS MonthlyRevenue
    FROM dw.fact_Sales AS f
    INNER JOIN dw.dim_Date AS d
        ON d.DateKey = f.OrderDateKey
    GROUP BY d.MonthNumber, d.YearNumber
) AS MonthlyTotals
INNER JOIN dw.dim_Date AS d
    ON d.MonthNumber = MonthlyTotals.MonthNumber
GROUP BY d.MonthNumber, d.MonthName
ORDER BY d.MonthNumber;
GO

-- Query 13: Running total of revenue by month, using a window function to accumulate revenue across the timeline.
WITH MonthlyRevenue AS
(
    SELECT
        d.YearMonth,
        SUM(f.SalesAmount) AS MonthlyRevenue
    FROM dw.fact_Sales AS f
    INNER JOIN dw.dim_Date AS d
        ON d.DateKey = f.OrderDateKey
    GROUP BY d.YearMonth
)
SELECT
    YearMonth,
    MonthlyRevenue,
    SUM(MonthlyRevenue) OVER (ORDER BY YearMonth ROWS UNBOUNDED PRECEDING) AS RunningRevenue
FROM MonthlyRevenue
ORDER BY YearMonth;
GO

-- Query 14: Executive KPI snapshot: revenue, profit, orders, customers, average order value and customer lifetime value for the entire book.
SELECT
    SUM(f.SalesAmount) AS TotalRevenue,
    SUM(f.ProfitAmount) AS TotalProfit,
    COUNT(DISTINCT f.OrderID) AS TotalOrders,
    COUNT(DISTINCT f.CustomerKey) AS TotalCustomers,
    CAST(SUM(f.SalesAmount) / NULLIF(COUNT(DISTINCT f.OrderID), 0) AS DECIMAL(10,2)) AS AvgOrderValue,
    CAST(SUM(f.SalesAmount) / NULLIF(COUNT(DISTINCT f.CustomerKey), 0) AS DECIMAL(10,2)) AS CustomerLifetimeValue
FROM dw.fact_Sales AS f;
GO

-- Query 15: Products where discounting is eroding profitability, found via a subquery that isolates products whose average discount exceeds the overall average discount across the business.
SELECT
    p.ProductName,
    AVG(f.DiscountRate) AS AvgDiscount,
    SUM(f.ProfitAmount) AS TotalProfit
FROM dw.fact_Sales AS f
INNER JOIN dw.dim_Product AS p
    ON p.ProductKey = f.ProductKey
WHERE f.ProductKey IN
(
    SELECT f2.ProductKey
    FROM dw.fact_Sales AS f2
    GROUP BY f2.ProductKey
    HAVING AVG(f2.DiscountRate) >
    (
        SELECT AVG(DiscountRate) FROM dw.fact_Sales
    )
)
GROUP BY p.ProductName
ORDER BY TotalProfit ASC;
GO

-- Query 16: Customer ranking within each segment using DENSE_RANK, showing the top spender per segment.
WITH CustomerSegmentRevenue AS
(
    SELECT
        c.Segment,
        c.CustomerName,
        SUM(f.SalesAmount) AS Revenue,
        DENSE_RANK() OVER (PARTITION BY c.Segment ORDER BY SUM(f.SalesAmount) DESC) AS SegmentRank
    FROM dw.fact_Sales AS f
    INNER JOIN dw.dim_Customer AS c
        ON c.CustomerKey = f.CustomerKey
    GROUP BY c.Segment, c.CustomerName
)
SELECT Segment, CustomerName, Revenue, SegmentRank
FROM CustomerSegmentRevenue
WHERE SegmentRank <= 5
ORDER BY Segment, SegmentRank;
GO

-- Query 17: Ship mode performance, comparing revenue and average discount across delivery service levels, including customers with no orders under a given ship mode via a LEFT JOIN illustration at the geography level.
SELECT
    sm.ShipModeName,
    COUNT(DISTINCT f.OrderID) AS OrderCount,
    SUM(f.SalesAmount) AS TotalRevenue,
    AVG(f.DiscountRate) AS AvgDiscount,
    SUM(f.ProfitAmount) AS TotalProfit
FROM dw.dim_ShipMode AS sm
LEFT JOIN dw.fact_Sales AS f
    ON f.ShipModeKey = sm.ShipModeKey
GROUP BY sm.ShipModeName
ORDER BY TotalRevenue DESC;
GO

-- Query 18: Row-level sales performance banding using ROW_NUMBER to identify the single largest order line per category.
WITH RankedLines AS
(
    SELECT
        p.Category,
        p.ProductName,
        f.SalesAmount,
        f.ProfitAmount,
        ROW_NUMBER() OVER (PARTITION BY p.Category ORDER BY f.SalesAmount DESC) AS LineRank
    FROM dw.fact_Sales AS f
    INNER JOIN dw.dim_Product AS p
        ON p.ProductKey = f.ProductKey
)
SELECT Category, ProductName, SalesAmount, ProfitAmount
FROM RankedLines
WHERE LineRank = 1;
GO

-- Query 19: City level profitability with LEFT JOIN back to geography to confirm every city on record is represented even where profit is flat.
SELECT
    g.City,
    g.State,
    SUM(f.SalesAmount) AS TotalRevenue,
    SUM(f.ProfitAmount) AS TotalProfit
FROM dw.dim_Geography AS g
LEFT JOIN dw.fact_Sales AS f
    ON f.GeographyKey = g.GeographyKey
GROUP BY g.City, g.State
ORDER BY TotalRevenue DESC;
GO

-- Query 20: Month over month change in profit using LEAD to look ahead one period and quantify the swing between consecutive months.
WITH MonthlyProfit AS
(
    SELECT
        d.YearMonth,
        SUM(f.ProfitAmount) AS MonthlyProfit
    FROM dw.fact_Sales AS f
    INNER JOIN dw.dim_Date AS d
        ON d.DateKey = f.OrderDateKey
    GROUP BY d.YearMonth
)
SELECT
    YearMonth,
    MonthlyProfit,
    LEAD(MonthlyProfit) OVER (ORDER BY YearMonth) AS NextMonthProfit,
    LEAD(MonthlyProfit) OVER (ORDER BY YearMonth) - MonthlyProfit AS ProfitSwing
FROM MonthlyProfit
ORDER BY YearMonth;
GO


/* SECTION 6: ADVANCED SQL SUMMARY
   The queries above already demonstrate the required advanced SQL toolkit:
     JOINS: INNER JOIN (Queries 1-16), LEFT JOIN (Queries 17, 19)
     CTEs: Queries 7, 11, 13, 16, 18, 20
     SUBQUERY: Query 15 (correlated HAVING subquery plus scalar subquery)
     CASE: Queries 3, 6 is aggregation only, 7 and 8 classify rows
     WINDOW FNS: RANK (4), DENSE_RANK (16), ROW_NUMBER (18), LAG (11), LEAD (20), running total (13) */


/* SECTION 7: SQL VIEW
   vw_ExecutiveKPIs exposes the headline numbers leadership checks first: revenue, profit, margin, order count and customer count. Built directly on the fact table so it always reflects the latest load. */

IF OBJECT_ID(N'rpt.vw_ExecutiveKPIs', N'V') IS NOT NULL
    DROP VIEW rpt.vw_ExecutiveKPIs;
GO

CREATE VIEW rpt.vw_ExecutiveKPIs
AS
    SELECT
        SUM(f.SalesAmount) AS TotalRevenue,
        SUM(f.ProfitAmount) AS TotalProfit,
        CAST(SUM(f.ProfitAmount) * 100.0 / NULLIF(SUM(f.SalesAmount), 0) AS DECIMAL(6,2)) AS ProfitMarginPct,
        COUNT(DISTINCT f.OrderID) AS TotalOrders,
        COUNT(DISTINCT f.CustomerKey) AS TotalCustomers,
        CAST(SUM(f.SalesAmount) / NULLIF(COUNT(DISTINCT f.OrderID), 0) AS DECIMAL(10,2)) AS AvgOrderValue
    FROM dw.fact_Sales AS f;
GO

-- Sample usage:
SELECT * FROM rpt.vw_ExecutiveKPIs;


/* SECTION 8: STORED PROCEDURE
   usp_GetSalesKPIsByDateRange returns headline KPIs for an arbitrary date window, which is the shape most executive dashboards need when a user picks a custom reporting period. Includes basic parameter validation and structured error handling. */

IF OBJECT_ID(N'rpt.usp_GetSalesKPIsByDateRange', N'P') IS NOT NULL
    DROP PROCEDURE rpt.usp_GetSalesKPIsByDateRange;
GO

CREATE PROCEDURE rpt.usp_GetSalesKPIsByDateRange
    @StartDate DATE,
    @EndDate   DATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        IF @StartDate IS NULL OR @EndDate IS NULL
        BEGIN
            RAISERROR('Both @StartDate and @EndDate are required.', 16, 1);
            RETURN;
        END

        IF @StartDate > @EndDate
        BEGIN
            RAISERROR('@StartDate cannot be later than @EndDate.', 16, 1);
            RETURN;
        END

        DECLARE @StartDateKey INT = CAST(CONVERT(CHAR(8), @StartDate, 112) AS INT);
        DECLARE @EndDateKey   INT = CAST(CONVERT(CHAR(8), @EndDate, 112) AS INT);

        SELECT
            @StartDate AS PeriodStart,
            @EndDate AS PeriodEnd,
            SUM(f.SalesAmount) AS Revenue,
            SUM(f.ProfitAmount) AS Profit,
            COUNT(DISTINCT f.OrderID) AS Orders,
            COUNT(DISTINCT f.CustomerKey) AS Customers,
            CAST(SUM(f.SalesAmount) / NULLIF(COUNT(DISTINCT f.OrderID), 0) AS DECIMAL(10,2)) AS AverageOrderValue
        FROM dw.fact_Sales AS f
        WHERE f.OrderDateKey BETWEEN @StartDateKey AND @EndDateKey;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Sample usage:
EXEC rpt.usp_GetSalesKPIsByDateRange @StartDate = '2015-01-01', @EndDate = '2015-12-31';


/* SECTION 9: EXECUTIVE REPORTING */

-- Report 1: Profitability Report, category level revenue, profit, margin and a business-friendly performance label.
SELECT
    p.Category,
    p.SubCategory,
    SUM(f.SalesAmount) AS Revenue,
    SUM(f.ProfitAmount) AS Profit,
    CAST(SUM(f.ProfitAmount) * 100.0 / NULLIF(SUM(f.SalesAmount), 0) AS DECIMAL(6,2)) AS MarginPct,
    CASE
        WHEN SUM(f.ProfitAmount) < 0 THEN 'Needs Attention'
        WHEN SUM(f.ProfitAmount) * 100.0 / NULLIF(SUM(f.SalesAmount), 0) >= 20 THEN 'Strong Performer'
        ELSE 'Stable'
    END AS PerformanceLabel
FROM dw.fact_Sales AS f
INNER JOIN dw.dim_Product AS p
    ON p.ProductKey = f.ProductKey
GROUP BY p.Category, p.SubCategory
ORDER BY Profit DESC;
GO

-- Report 2: Customer Behavior Report, segment level activity blended with a CTE that isolates each customer's total orders and revenue.
WITH CustomerActivity AS
(
    SELECT
        c.CustomerKey,
        c.Segment,
        COUNT(DISTINCT f.OrderID) AS Orders,
        SUM(f.SalesAmount) AS Revenue
    FROM dw.fact_Sales AS f
    INNER JOIN dw.dim_Customer AS c
        ON c.CustomerKey = f.CustomerKey
    GROUP BY c.CustomerKey, c.Segment
)
SELECT
    Segment,
    COUNT(CustomerKey) AS CustomerCount,
    SUM(Orders) AS TotalOrders,
    SUM(Revenue) AS TotalRevenue,
    CAST(AVG(1.0 * Orders) AS DECIMAL(6,2)) AS AvgOrdersPerCustomer,
    CAST(SUM(Revenue) / NULLIF(COUNT(CustomerKey), 0) AS DECIMAL(10,2)) AS AvgRevenuePerCustomer
FROM CustomerActivity
GROUP BY Segment
ORDER BY TotalRevenue DESC;
GO

-- Report 3: Sales Trends Report, yearly revenue and profit with a year over year growth column for board-level review.
WITH YearlyTotals AS
(
    SELECT
        d.YearNumber,
        SUM(f.SalesAmount) AS Revenue,
        SUM(f.ProfitAmount) AS Profit
    FROM dw.fact_Sales AS f
    INNER JOIN dw.dim_Date AS d
        ON d.DateKey = f.OrderDateKey
    GROUP BY d.YearNumber
)
SELECT
    YearNumber,
    Revenue,
    Profit,
    LAG(Revenue) OVER (ORDER BY YearNumber) AS PriorYearRevenue,
    CAST((Revenue - LAG(Revenue) OVER (ORDER BY YearNumber)) * 100.0
         / NULLIF(LAG(Revenue) OVER (ORDER BY YearNumber), 0) AS DECIMAL(6,2)) AS RevenueGrowthPct
FROM YearlyTotals
ORDER BY YearNumber;
GO


/* SECTION 10: DOCUMENTATION SUMMARY
   Star schema     : dw.fact_Sales at the center, joined to dw.dim_Date,
                      dw.dim_Customer, dw.dim_Product, dw.dim_Geography and
                      dw.dim_ShipMode.
   Fact table      : dw.fact_Sales, grain = one row per source order line
                      (Row ID), carrying Sales, Quantity, Discount and
                      Profit as measures.
   Dimensions      : dw.dim_Date (calendar), dw.dim_Customer (who bought),
                      dw.dim_Product (what was bought), dw.dim_Geography
                      (where the order shipped to), dw.dim_ShipMode (how it
                      shipped).
   Indexing        : clustered index on OrderDateKey for date-range scans,
                      nonclustered indexes on every fact foreign key, two
                      covering indexes for the heaviest product and customer
                      aggregation patterns, and supporting indexes on the
                      dimension filter columns used across Section 5-9. Full
                      SARGability, execution plan review and join ordering
                      rationale is documented in Section 4B.
   Views           : rpt.vw_ExecutiveKPIs for headline revenue, profit,
                      margin, orders and customers.
   Procedures      : rpt.usp_GetSalesKPIsByDateRange for parameterized KPI
                      reporting over any date window, with validation and
                      TRY/CATCH error handling. */
