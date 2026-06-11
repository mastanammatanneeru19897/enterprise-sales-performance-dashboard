-- =========================================================================
-- Project Name: Amazon Sales Performance & Fulfillment Analytics
-- Description: Database schema and business intelligence queries for e-commerce tracking.
-- Tools Used: SQL, Power BI, Excel
-- File: amazon_sales_queries.sql
-- =========================================================================

-- 1. DATABASE & TABLE STRUCTURE SETUP
-- Creating the core table based on the Amazon Sales dataset schema

CREATE TABLE amazon_sales (
    index INT PRIMARY KEY,
    order_id VARCHAR(50),
    date DATE,
    status VARCHAR(50),
    fulfillment VARCHAR(50),
    sales_channel VARCHAR(50),
    ship_service_level VARCHAR(50),
    sku VARCHAR(100),
    category VARCHAR(50),
    size VARCHAR(20),
    asin VARCHAR(50),
    courier_status VARCHAR(50),
    qty INT,
    currency VARCHAR(10),
    amount DECIMAL(10, 2),
    ship_city VARCHAR(100),
    ship_state VARCHAR(100),
    ship_postal_code VARCHAR(20),
    promotion_ids VARCHAR(255),
    fulfilled_by VARCHAR(50)
);


-- =========================================================================
-- 2. CORE BUSINESS QUESTIONS & ANALYTICAL QUERIES
-- =========================================================================

-- BQ 1: What is our total revenue velocity across specific regions?
-- Tracks total revenue generated from a specific state (e.g., 'ANDHRA PRADESH' as filtered in image_47b5bb.png)
SELECT 
    ship_state AS State,
    SUM(amount) AS Total_Revenue,
    COUNT(order_id) AS Total_Orders
FROM 
    amazon_sales
WHERE 
    ship_state = 'ANDHRA PRADESH' AND status != 'Cancelled'
GROUP BY 
    ship_state;


-- BQ 2: How do different product categories compare in volume and overall market share?
-- Calculates total spending and the mathematical percentage share for product categories (Set, Kurta, Saree, etc.)
SELECT 
    category AS Category,
    SUM(amount) AS Category_Revenue,
    SUM(qty) AS Total_Units_Sold,
    ROUND((SUM(amount) * 100.0 / (SELECT SUM(amount) FROM amazon_sales WHERE status != 'Cancelled')), 2) AS Sales_Share_Percentage
FROM 
    amazon_sales
WHERE 
    status != 'Cancelled'
GROUP BY 
    category
ORDER BY 
    Category_Revenue DESC;


-- BQ 3: High-Level Operational KPIs for Executive Tracking
-- Replicates the core summary cards (Total Revenue, Total Orders, Units Sold) visible on the dashboard canvas
SELECT 
    SUM(amount) AS Executive_Total_Revenue,
    COUNT(DISTINCT order_id) AS Executive_Total_Orders,
    SUM(qty) AS Executive_Units_Sold
FROM 
    amazon_sales
WHERE 
    status != 'Cancelled';


-- BQ 4: What is the performance breakdown between logistics fulfillment models?
-- Compares revenue dynamics between 'Amazon' fulfillment and 'Merchant-fulfilled (MFN)' channels
SELECT 
    fulfillment AS Fulfillment_Method,
    COUNT(order_id) AS Order_Volume,
    SUM(amount) AS Revenue_Generated,
    ROUND(AVG(amount), 2) AS Average_Order_Value
FROM 
    amazon_sales
GROUP BY 
    fulfillment;


-- BQ 5: Geographical Sales Distribution - Top 10 High-Performing Cities
-- Helps inventory managers pinpoint areas with high product movement density
SELECT 
    ship_city AS City,
    ship_state AS State,
    COUNT(order_id) AS Orders_Placed,
    SUM(amount) AS Total_Sales
FROM 
    amazon_sales
WHERE 
    status != 'Cancelled'
GROUP BY 
    ship_city, ship_state
ORDER BY 
    Total_Sales DESC
LIMIT 10;
