/* 
Elevate Customer Satisfaction: Revolutionize Supply Chain with SQL-Driven Inventory Optimization (AMDARI.IO SQL practice project)

Business Overview/Problem
Inventory Management Challenges:
TechElectro Inc. faces a series of intricate inventory management challenges that impede its operational efficiency and customer satisfaction:
A. Overstocking: The company frequently finds itself burdened with excessive inventory of certain products, resulting in substantial capital tied up in unsold goods and limited storage capacity.
B. Understocking: Conversely, high-demand products regularly suffer from stockouts, leading to missed sales opportunities and irate customers unable to access their desired items.
C. Customer Satisfaction: These inventory-related issues have a direct and detrimental effect on customer satisfaction and loyalty. Customers endure delays, frequent stockouts, and frustration when they cannot find the products they seek.

Importance of MySQL-Powered Inventory Optimization:
A. Implementing a comprehensive inventory optimization system powered by MySQL is imperative for TechElectro Inc. due to several compelling reasons
B. Cost Reduction: Efficient inventory management through MySQL can significantly reduce carrying costs associated with overstocked items, freeing up capital for strategic investments.
C. Enhanced Customer Satisfaction: By maintaining optimal inventory levels, TechElectro Inc. ensures that its products are readily available, elevating the overall customer experience and fostering loyalty.
D. Competitive Advantage: Streamlined inventory management empowers TechElectro Inc. to respond swiftly to market fluctuations and shifting customer demands, providing a competitive edge.
E. Profitability: Improved inventory control through MySQL optimization leads to reduced waste and improved cash flow, directly impacting profitability.

Aim of the Project:
The primary objectives of this project are to implement a sophisticated inventory optimization system utilizing MySQL and address the identified business challenges effectively. The project aims to achieve the following goals:
A. Optimal Inventory Levels: Utilize MySQL optimization techniques to determine the optimal stock levels for each product SKU, thereby minimizing overstock and understock situations.
B. Data-Driven Decisions: Enable data-driven decision-making in inventory management by leveraging MySQL analytics to reduce costs and enhance customer satisfaction. */

/* Create Schema/Database */
CREATE SCHEMA tech_electro;
USE tech_electro;

/* Data Exploration */
SELECT * FROM external_factors LIMIT 5;
SELECT * FROM sales_data LIMIT 5;
SELECT * FROM product_information LIMIT 5;

-- Understanding the structure of the datasets
SHOW COLUMNS FROM external_factors;
DESCRIBE product_information;
DESC sales_data; 

/* Data Cleaning - Data Types */
-- Changing to the right data type for all columns
-- external factors table
-- SalesDate DATE, GDP DECIMAL(15, 2), InlationRate DECIMAL(5, 2), SeasonalFactor DECIMAL(5, 2)
-- SalesDate
ALTER TABLE external_factors
ADD COLUMN NewSalesDate DATE;
SET SQL_SAFE_UPDATES = 0; -- turning off safe updates temporarily. Safe update mode is designed to prevent accidental updates or deletes where a WHERE clause isn't specified.
UPDATE external_factors
SET NewSalesDate = STR_TO_DATE(SalesDate, '%d/%m/%Y'); -- Converts a string of a date and/or time into an actual date/time data type understandable by database. 
ALTER TABLE external_factors
DROP COLUMN SalesDate;
ALTER TABLE external_factors
CHANGE COLUMN NewSalesDate SalesDate DATE;

-- GDP
ALTER TABLE external_factors
MODIFY COLUMN GDP DECIMAL(15,2);

-- InflationRate
ALTER TABLE external_factors
MODIFY COLUMN InflationRate DECIMAL(5, 2);

-- SeasonalFactor
ALTER TABLE external_factors
MODIFY COLUMN SeasonalFactor DECIMAL(5, 2);

SHOW COLUMNS FROM external_factors;

-- Product_Information
-- ProductID INT NOT NULL, ProductCategory TEXT, Promotions ENUM('yes', 'no')
-- Promotions
ALTER TABLE product_information
ADD COLUMN NewPromotions ENUM('yes', 'no');
UPDATE product_information
SET NewPromotions = CASE
	WHEN Promotions = 'yes' THEN 'yes'
    WHEN Promotions = 'no' THEN 'no'
    ELSE NULL
END;
ALTER TABLE product_information
DROP COLUMN promotions;
ALTER TABLE product_information
CHANGE COLUMN NewPromotions Promotions ENUM('yes', 'no');

-- Sales_Data
-- ProductID INT NOT NULL, SalesDate DATE, InventoryQuantity INT, ProductCost DECIMAL(10, 2)
ALTER TABLE sales_data
ADD COLUMN NewSalesDate DATE;
UPDATE sales_data
SET NewSalesDate = STR_TO_DATE(SalesDate, '%d/%m/%Y'); -- This transfers all the data under SalesDate to NewSalesDate
ALTER TABLE sales_data
DROP COLUMN SalesDate;
ALTER TABLE sales_data
CHANGE COLUMN NewSalesDate SalesDate DATE;
DESC sales_data;

/* Data Cleaning - Missing Values */
-- Identify missing values using the 'IS NULL' function
-- External Factors
SELECT
 SUM(CASE WHEN SalesDate IS NULL THEN 1 ELSE 0 END) AS MissingSalesDate,
 SUM(CASE WHEN GDP IS NULL THEN 1 ELSE 0 END) AS MissingGdp,
 SUM(CASE WHEN InflationRate IS NULL THEN 1 ELSE 0 END) AS MissingInflationRate,
 SUM(CASE WHEN SeasonalFactor IS NULL THEN 1 ELSE 0 END) AS MissingSeasonalFactor
FROM external_factors;

SELECT * FROM product_information;

-- Product_Information
SELECT
 SUM(CASE WHEN ProductID IS NULL THEN 1 ELSE 0 END) AS MissingProductID,
 SUM(CASE WHEN ProductCategory IS NULL THEN 1 ELSE 0 END) AS MissingProductCategory,
 SUM(CASE WHEN Promotions IS NULL THEN 1 ELSE 0 END) AS MissingPromotions
FROM product_information;

-- Sales_Data
SELECT
 SUM(CASE WHEN ProductID IS NULL THEN 1 ELSE 0 END) AS MissingProductID,
 SUM(CASE WHEN InventoryQuantity IS NULL THEN 1 ELSE 0 END) AS MissingInventoryQuantity,
 SUM(CASE WHEN ProductCost IS NULL THEN 1 ELSE 0 END) AS MissingProductCost,
 SUM(CASE WHEN SalesDate IS NULL THEN 1 ELSE 0 END) AS MissingSalesDate
FROM sales_data;

/* Data Cleaning - Checking Duplicates */
-- Check for duplicates using the 'GROUP BY' and 'HAVING' clauses and remove them if necessary
-- External Factors
SELECT SalesDate, COUNT(*) AS Count
FROM external_factors
GROUP BY SalesDate
HAVING count > 1;
  
SELECT COUNT(*) FROM (
	SELECT SalesDate, COUNT(*) AS Count
	FROM external_factors
	GROUP BY SalesDate
	HAVING count > 1) AS dup; -- To get total duplicates

-- Product Information
SELECT ProductID, COUNT(*) AS Count
FROM product_information
GROUP BY ProductID
HAVING count > 1;
  
SELECT COUNT(*) FROM (
	SELECT ProductID, COUNT(*) AS Count
	FROM product_information
	GROUP BY ProductID
	HAVING count > 1) AS dup; -- To get total duplicates

-- Sales Data
SELECT ProductID, SalesDate, COUNT(*) AS Count
FROM sales_data
GROUP BY ProductID, SalesDate
HAVING count > 1;

/* Data Cleaning - Handling Duplicates */
-- Handling duplicates using the 'DELETE FROM', 'WHERE' and 'IN' clauses and remove the duplicates
-- External Factors

SET SQL_SAFE_UPDATES = 0;

DELETE e1 
FROM external_factors e1
INNER JOIN (
  SELECT SalesDate,
  ROW_NUMBER() OVER (PARTITION BY SalesDate ORDER BY SalesDate) AS rn
  FROM external_factors
 ) e2 ON e1.SalesDate = e2.SalesDate
 WHERE e2.rn > 1;
 
-- -----------------------------------------------------------------------------------------------
-- Another ways of deleting duplicate
DELETE e1
FROM external_factors e1
INNER JOIN (
  SELECT SaleDate, MIN(id) AS min_id
  FROM external_factors
  GROUP BY SaleDate
  HAVING COUNT(*) > 1
) e2 ON e1.SaleDate = e2.SaleDate AND e1.id > e2.min_id;

-- OR 

DELETE FROM external_factors
WHERE SaleDate IN (
  SELECT SaleDate
  FROM external_factors
  GROUP BY SaleDate
  HAVING COUNT(*) > 1
)
LIMIT 1;
-- ----------------------------------------------------------------------------------------------
-- Product Information
DESC sales_data;
DESC product_information;

DELETE e1 
FROM product_information e1
INNER JOIN (
  SELECT ProductID,
  ROW_NUMBER() OVER (PARTITION BY ProductID ORDER BY ProductID) AS rn
  FROM product_information
 ) e2 ON e1.ProductID = e2.ProductID
 WHERE e2.rn > 1;

/* Data Integration */
-- Combine sales_data and product_information

CREATE VIEW sales_product_data AS
SELECT
s.ProductID,
s.SalesDate,
s.InventoryQuantity,
s.ProductCost,
p.ProductCategory,
p.Promotions
FROM sales_data s
JOIN product_information p
ON s.ProductID = p.ProductID;

-- sales_product_data and external_factor
CREATE VIEW inventory_data AS
SELECT
sp.ProductID,
sp.SalesDate,
sp.InventoryQuantity,
sp.ProductCost,
sp.ProductCategory,
sp.Promotions,
e.GDP,
e.InflationRate,
e.SeasonalFactor
FROM sales_product_data sp
LEFT JOIN external_factors e
ON sp.SalesDate = e.SalesDate;

/* Descriptive Statistics */
-- Basic Statistics:
-- Average Sales (calc as "Inventory Quantity" and "Product Cost"
SELECT 
    ProductID, AVG(InventoryQuantity * ProductCost) AS avg_sales
FROM
    inventory_data
GROUP BY ProductID
ORDER BY avg_sales DESC;

-- Median Stock Levels (i.e., "Inventory Quantity"
SELECT ProductID, AVG(InventoryQuantity) AS median_stock
FROM (
 SELECT ProductID,
		InventoryQuantity,
ROW_NUMBER() OVER(PARTITION BY ProductID ORDER BY InventoryQuantity) AS row_num_asc,
ROW_NUMBER() OVER(PARTITION BY ProductID ORDER BY InventoryQuantity DESC) AS row_num_desc
 FROM inventory_data
) AS subquery
WHERE row_num_asc IN (row_num_desc, row_num_desc - 1, row_num_desc + 1)
GROUP BY ProductID;

-- Product Performance Metrics (Total Sales Per Product)
SELECT ProductID,
ROUND(SUM(InventoryQuantity * ProductCost)) AS total_sales -- "ROUND" to take the decimal points
FROM inventory_data
GROUP BY ProductID
ORDER BY total_sales DESC;

-- Identify high-in-demand products based on average sales - CTE ("WITH" is a common-table-expression CTE)
WITH HighDemandProducts AS ( 
SELECT ProductID, AVG(InventoryQuantity) AS avg_sales
 FROM inventory_data
 GROUP BY ProductID
HAVING avg_sales > (
	SELECT AVG(InventoryQuantity) * 0.95  FROM sales_data
    )
)
    
-- Calculate stockout frequency for high-demand products - Main Query
SELECT i.ProductID,
COUNT(*) AS stockout_frequency
FROM inventory_data i
WHERE i.ProductID IN (SELECT ProductID FROM HighDemandProducts)
AND i.InventoryQuantity = 0
GROUP BY i.ProductID;

/* Inluence of External Factors */
-- GDP
SELECT ProductID,
AVG(CASE WHEN GDP > 0 THEN InventoryQuantity ELSE NULL END) AS avg_sales_positive_gdp,
AVG(CASE WHEN GDP <= 0 THEN InventoryQuantity ELSE NULL END) AS avg_sales_non_positive_gdp
FROM inventory_data
GROUP BY ProductID
HAVING avg_sales_positive_gdp IS NOT NULL;

-- Inflation rate
SELECT ProductID,
AVG(CASE WHEN InflationRate > 0 THEN InventoryQuantity ELSE NULL END) AS avg_sales_positive_inflation,
AVG(CASE WHEN InflationRate <= 0 THEN InventoryQuantity ELSE NULL END) AS avg_sales_non_positive_inflation
FROM inventory_data
GROUP BY ProductID
HAVING avg_sales_positive_inflation IS NOT NULL;

SELECT *
FROM inventory_data;

/* Inventory Optimization */
-- Determine the optimal reorder point for each product based on historical sales data and external factors
-- Reorder Point = Lead Time Deman + Safety Stock
-- Lead Time Demand = Rolling Average Sales x Lead Time
-- Reorder Point = Rolling Average Sales x Lead Time + Z x Lead Time^-2 xStandard Deviation of Demand 
-- Safety Stock = Z x Lead Time^-2 xStandard Deviation of Demand
-- Z=1.645
-- A constant lead time of 7 days for all products
-- We aim for 95% service level
WITH InventoryCalculations AS (
SELECT ProductID,
 AVG(rolling_avg_sales) AS avg_rolling_sales,
 AVG(rolling_variance) AS avg_rolling_variance
FROM (
SELECT ProductID,
AVG(daily_sales) OVER (PARTITION BY ProductID ORDER BY SalesDate ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_avg_sales,
AVG(squared_diff) OVER (PARTITION BY ProductID ORDER BY SalesDate ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_variance
FROM (
SELECT ProductID,
 SalesDate, InventoryQuantity * ProductCost AS daily_sales,
  (InventoryQuantity * ProductCost - AVG(InventoryQuantity * ProductCost) OVER (PARTITION BY ProductID ORDER BY SalesDate ROWS BETWEEN 6 PRECEDING AND CURRENT ROW))
* (InventoryQuantity * ProductCost - AVG(InventoryQuantity * ProductCost) OVER (PARTITION BY ProductID ORDER BY SalesDate ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) AS squared_diff
 FROM inventory_data
 ) subquery
  ) subquery2
    GROUP BY ProductID

)
SELECT ProductID,
avg_rolling_sales * 7 AS lead_time_demand,
	1.645 * (avg_rolling_variance * 7) AS safety_stock,
(avg_rolling_sales * 7) + (1.645 * (avg_rolling_variance * 7)) AS reorder_point
FROM InventoryCalculations;

-- Create the Inventory optimization table
-- Step 1
CREATE TABLE inventory_optimization (
	ProductID INT,
    Reorder_Point DOUBLE
);

-- Step 2: Create the Stored Procedure to Recalculate Reorder Point
 DELIMITER //
 CREATE PROCEDURE RecalculateReorderPoint(ProductID INT)
 BEGIN
	DECLARE avgRollingSales DOUBLE;
    DECLARE avgRollingVariance DOUBLE;
    DECLARE leadTimeDemand DOUBLE;
    DECLARE safetyStock DOUBLE;
    DECLARE reorderPoint DOUBLE;
   SELECT AVG(rolling_avg_sales), AVG(rolling_variance) 
	INTO avgRollingSales, avgRollingVariance
FROM (
SELECT ProductID,
AVG(daily_sales) OVER (PARTITION BY ProductID ORDER BY SalesDate ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_avg_sales,
AVG(squared_diff) OVER (PARTITION BY ProductID ORDER BY SalesDate ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_variance
FROM (
SELECT ProductID,
 SalesDate, InventoryQuantity * ProductCost AS daily_sales,
  (InventoryQuantity * ProductCost - AVG(InventoryQuantity * ProductCost) OVER (PARTITION BY ProductID ORDER BY SalesDate ROWS BETWEEN 6 PRECEDING AND CURRENT ROW))
* (InventoryQuantity * ProductCost - AVG(InventoryQuantity * ProductCost) OVER (PARTITION BY ProductID ORDER BY SalesDate ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) AS squared_diff
 FROM inventory_data
 ) InnerDerived
  ) OuterDerived;
 SET leadTimeDemand = avgRollingSales * 7;
 SET safetyStock = 1.645 * SQRT(avgRollingVariance * 7);
 SET reorderPoint = leadTimeDemand + safetyStock;
    
INSERT INTO inventory_optimization (ProductID, Reorder_Point)
VALUES (ProductID, reorderPoint)
ON DUPLICATE KEY UPDATE Reorder_Point = reorderPoint;
END //
DELIMITER ;

-- Step 3: make Inventory_data a permanent table
CREATE TABLE Inventory_table AS SELECT * FROM inventory_data;

-- Step 4: Create the Trigger
DELIMITER //
CREATE TRIGGER AfterInsertUnifiedTable
AFTER INSERT ON Inventory_table
FOR EACH ROW
BEGIN
 CALL RecalculateReorderPoint(NEW.ProductID);
 END //
 DELIMITER ;

/* Overstocking and Understocking */
WITH RollingSales AS (  -- CTE
 SELECT ProductID,
 SalesDate,
AVG(InventoryQuantity * ProductCost) OVER (PARTITION BY ProductID ORDER BY SalesDate ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_avg_sales
 FROM inventory_table
),

-- Calculate the number of days a product was out of stock - CTE
StockoutDays AS (
SELECT ProductID,
 COUNT(*) AS stockout_days
FROM inventory_table
WHERE InventoryQuantity = 0
GROUP BY ProductID
)

-- Join the above CTEs with the main table to get the results - MAIN QUERIES
SELECT f.ProductID,
AVG(f.InventoryQuantity * f.ProductCost) AS avg_inventory_value,
AVG(rs.rolling_avg_sales) AS avg_rolling_sales,
 COALESCE(sd.stockout_days, 0) AS stockout_days
FROM inventory_table f
JOIN RollingSales rs ON f.ProductID = rs.ProductID AND f.SalesDate = rs.SalesDate
LEFT JOIN StockoutDays sd ON f.ProductID = sd.ProductID
GROUP BY f.ProductID, sd.stockout_days;


/* Monitor and Adjust */
-- Monitor Inventory Levels
DELIMITER //
CREATE PROCEDURE MonitorInventoryLevels()
BEGIN
SELECT ProductID, AVG(InventoryQuantity) AS AvgInventory
FROM Inventory_Table
GROUP BY ProductID
ORDER BY AvgInventory DESC;
END //
DELIMITER ;

-- Monitor Sales Trend
DELIMITER //
CREATE PROCEDURE MonitorSalesTrends()
BEGIN
SELECT ProductID, SalesDate,
AVG(InventoryQuantity * ProductCost) OVER (PARTITION BY ProductID ORDER BY SalesDate ROWS BETWEEN 6 PRECEDING and CURRENT ROW) AS RollingAvgSales
FROM Inventory_Table
ORDER BY ProductID, SalesDate;
END //
DELIMITER ;

-- Monitor Stock Frequencies
DELIMITER //
CREATE PROCEDURE MonitorStockouts()
BEGIN
SELECT ProductID, COUNT(*) AS StockoutDays
FROM inventory_table
WHERE InventoryQuantity = 0
GROUP BY ProductID
ORDER BY StockoutDays DESC;
END //
DELIMITER ;

/* FEEDBACK LOOP */

-- Feedback Loop Establishment:
-- Feedback Portal: Develop an online platform for stakeholders to easily submit feedback on inventory performance and challenges.
-- Review Meetings: Organize periodic sessions to discuss inventory system performance and gather direct insights.
-- System Monitoring: Use established SQL procedures to track system metrics, with deviations from expectations flagged for review.

-- Refinement Based on Feedback:
-- Feedback Analysis: Regularly compile and scrutinize feedback to identify recurring themes or pressing issues.
-- Action Implementation: Prioritize and act on the feedback to adjust reorder points, safety stock levels, or overall processes.
-- Change Communication: Inform stakeholders about changes, underscoring the value of their feedback and ensuring transparency.


/* Insights and Recommendations */
-- General Insights:

-- Inventory Discrepancies: The initial stages of the analysis revealed significant discrepancies in inventory levels, with instances of both overstocking and understocking.
-- These inconsistencies were contributing to capital inefficiencies and customer dissatisfaction.

-- Sales Trends and External Influences: The analysis indicated that sales trends were notably influenced by various external factors.
-- Recognizing these patterns provides an opportunity to forecast demand more accurately.

-- Suboptimal Inventory Levels: Through the inventory optimization analysis, it was evident that the existing inventory levels were not optimized for current sales trends.
-- Products was identified that had either close excess inventory.

-- Recommendations:

-- 1. Implement Dynamic Inventory Management: The company should transition from a static to a dynamic inventory management system,
-- adjusting inventory levels based on real-time sales trends, seasonality, and external factors.

-- 2. Optimize Reorder Points and Safety Stocks: Utilize the reorder points and safety stocks calculated during the analysis to minimize stockouts and reduce excess inventory.
-- Regularly review these metrics to ensure they align with current market conditions.

-- 3. Enhance Pricing Strategies: Conduct a thorough review of product pricing strategies, especially for products identified as unprofitable.
-- Consider factors such as competitor pricing, market demand, and product acquisition costs.

-- 4. Reduce Overstock: Identify products that are consistently overstocked and take steps to reduce their inventory levels.
-- This could include promotional sales, discounts, or even discontinuing products with low sales performance.

-- 5. Establish a Feedback Loop: Develop a systematic approach to collect and analyze feedback from various stakeholders.
-- Use this feedback for continuous improvement and alignment with business objectives.

-- 6. Regular Monitoring and Adjustments: Adopt a proactive approach to inventory management by regularly monitoring key metrics
-- and making necessary adjustments to inventory levels, order quantities, and safety stocks.
