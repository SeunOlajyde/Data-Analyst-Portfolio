/* EXPLORATORY DATA ANALYSIS IN SQL - CLIMATE CHANGE IN AFRICA

The data to be used is from a paper on Climate change adaptation innovation in the water sector in Africa. Dataset can be found here: https://data.mendeley.com/datasets/4f234mww6s/2. Journal can be found here: https://doi.org/10.1016/j.dib.2022.108782. The study in this paper analyzes the response of technology to water vulnerability created by climate change in Africa.

The data is focused on susceptibility to water stress caused by climate change and the public response in the form of technology development. In this analysis, the data specifies the relationship between a measure of water stress induced by climate change and adaptation innovation, along with a series of socio-economic and socio-political indicators as controls.

The data used for adaptation technology was water-related patent data. The water stress index accounts for things like projected change of annual runoff, projected change of annual groundwater recharge, fresh water withdrawal rate, water dependency ratio, 
dam capacity, and access to reliable drinking water. A higher index indicates higher vulnerability. While other variables are used to define the country's size (GDP), institutional effectiveness, 
research and development activity, and knowledge base.

In the dataset, the fields included are:
. year (data has been pooled for the following years: 1990, 2000, 2005, and 2010 to 2016)
· adaptation technologies (water_related_adapatation_tech)
. openness to trade (trade as percentage of gross domestic product)
. time required to register property (calendar days)
· gross domestic product per capita
· employers (total)
. gross enrolment ratio
. water stress index

*/

-- EDA in SQL

-- EXPLORING THE TABLE

-- 1. Query the full table
SELECT *
FROM climate;

-- 2. Query the country and water_stress_index fields and order by descending order of the water_stress_index field
SELECT country, water_stress_index
FROM climate
ORDER BY water_stress_index DESC;

-- 3. Query the country, year, and gdp_per_capita field to get a list of the distinct country names and their respective GDP; order by the GDP in ascending order but only view the top 10 values

SELECT country, year, gdp_per_capita
FROM climate
ORDER BY gdp_per_capita ASC
LIMIT 10;


-- DATA FILTERING

-- 4. Filtering the data to see the country and year where the water_stress_index was between 0.5 and 0.6

SELECT country, water_stress_index
FROM climate
WHERE water_stress_index BETWEEN 0.5 AND 0.6;


-- 5. Filtering the data to see the countries that start with the letter E or S and have a water_stress_index above 0.5

SELECT country, year, water_stress_index
FROM climate
WHERE water_stress_index > 0.5 AND (country LIKE 'E%' or country LIKE 'S%'); -- sometimes it will not return the right result, put the parathesis to correct

-- DATA AGGREGATION, GROUPING AND SORTING

-- 6. The average water_related_adaptation_tech value is for each country across all of the years and ordered by descending order of this average (higher means higher patent on water technology and vis versa)

SELECT country, AVG(water_related_adaptation_tech) AS avg_water_tech
FROM climate
GROUP BY country
ORDER BY avg_water_tech DESC;

-- 7. The countries that have an average water_related_adaptation_tech value greater than 1.

SELECT country
FROM climate
GROUP BY country
HAVING AVG(water_related_adaptation_tech)> 1;

-- Historical Trends

-- 8. Trend in Water Stress Index Over Time
-- This provides information on whether the water stress is generally increasing, decreasing, or remaining stable over the years.
	
SELECT year, AVG(water_stress_index) AS avg_water_stress
FROM climate
GROUP BY year
ORDER BY year;


-- 9: Trend in GDP per Capita Over Time
-- This provides information on whether the economic growth or decline trends over time.

SELECT year, AVG(gdp_per_capita) AS avg_gdp_per_capita
FROM climate
GROUP BY year
ORDER BY year;

-- 10. Trend in Water-Related Adaptation Tech Over Time
-- This provides information on whether there's a growing or diminishing focus on water-related adaptation technologies. As you can see, tech around this space has been increasing year-on-year to 2016.

SELECT year, AVG(water_related_adaptation_tech) AS avg_water_tech
FROM climate
GROUP BY year
ORDER BY year;

-- Distribution Analysis

-- 11. Distribution of Water Stress Index
-- This provides an idea of whether most countries have low, medium, or high water stress

SELECT
	CASE
		WHEN water_stress_index BETWEEN 0 AND 0.2 THEN 'Low'
		WHEN water_stress_index BETWEEN 0.2 AND 0.4 THEN 'Medium-Low'
		WHEN water_stress_index BETWEEN 0.4 AND 0.6 THEN 'Medium'
		WHEN water_stress_index BETWEEN 0.6 AND 0.8 THEN 'Medium-High'
		ELSE 'High'
	END AS stress_level,
	COUNT(*) AS count
FROM climate
GROUP BY stress_level
ORDER BY count DESC;

-- 12. Distribution of GDP per Capita
-- These reveal whether the majority of countries have low, medium, or high GDP per capita

SELECT 
    CASE 
        WHEN gdp_per_capita < 5000 THEN 'Low'
        WHEN gdp_per_capita BETWEEN 5000 AND 20000 THEN 'Medium-Low'
        WHEN gdp_per_capita BETWEEN 20000 AND 50000 THEN 'Medium'
        WHEN gdp_per_capita BETWEEN 50000 AND 100000 THEN 'Medium-High'
        ELSE 'High'
    END AS gdp_level,
    COUNT(*) AS count
FROM climate
GROUP BY gdp_level
ORDER BY count DESC;

-- Correlations & Relationships

-- The coefficient ranges from -1 to 1. A value close to 1 indicates a strong positive correlation (e.g high water stress tends to occur with high GDP), a value close to -1 suggests a strong negative correlation and a value near 0 implies little to no correlation

-- 13. Correlation between Water Stress and GDP per Capita
-- Weak Negative Correlation of -0.155: The negative sign signifies that as water stress tends to increase, GDP per capita tends to decrease

SELECT CORR(water_stress_index, gdp_per_capita) AS correlation
FROM climate;

-- 14. Correlation between Water Stress and Water-Related Adaptation Tech
-- Very Weak Negative Correlation of -0.0418: it implies that there's no relationship between water stress and the adoption of water-related adaptation technologies because the relationship is very weak and is not statistically significant.

SELECT CORR(water_stress_index, water_related_adaptation_tech) AS correlation
FROM climate;

-- 15. Countries with High Water Stress and Low GDP
-- This pinpoints countries that are facing both high water stress and economic challenges

SELECT country, water_stress_index, gdp_per_capita
FROM climate
WHERE water_stress_index > 0.6 AND gdp_per_capita < 5000 -- This threshold can be adjusted as needed (Research threshold using external document. Please refer to the journal link above)
ORDER BY water_stress_index DESC;


-- DATA JOINING AND SORTING

-- Year-over-Year Changes
-- 16. Year-over-Year Change in Water Stress for each Country over 
-- This calculates the year-on-year change to track how water stress is changing over time for each country.

SELECT 
    c1.country, 
    c1.year, 
    c1.water_stress_index,
    (c1.water_stress_index - c2.water_stress_index) AS yoy_change
FROM climate c1
LEFT JOIN climate c2 
    ON c1.country = c2.country AND c1.year = c2.year + 1
ORDER BY c1.country, c1.year;

-- 17. This identifies Countries with the Largest Increase/Decrease in Water Stress in a Specific Year

WITH yoy_changes AS (
    SELECT 
	    c1.country, 
	    c1.year, 
	    c1.water_stress_index,
	    (c1.water_stress_index - c2.water_stress_index) AS yoy_change
	FROM climate c1
	LEFT JOIN climate c2 
	    ON c1.country = c2.country AND c1.year = c2.year + 1
)
SELECT country, year, yoy_change
FROM yoy_changes
WHERE year = 2015 -- The year was updated concurrently for further analysis (applicable years are 1990, 2000, 2005, 2010 - 2016)
ORDER BY yoy_change DESC -- Used DESC for largest increases, ASC for largest decreases
LIMIT 20; -- a sample of 20 out of 50 countries

-- DATA AGGREGATION AND FILTERING

-- Outlier Detection
	
-- 18. Identify potential outliers in the Water Stress Index 
-- These outliers could represent unusual situations or potential data entry errors worth investigating further. Both of them revealed the same result. This was as a result of the dataset.
	
	-- Z-scores 

WITH stats AS (
    SELECT AVG(water_stress_index) AS mean, STDDEV(water_stress_index) AS stddev
    FROM climate
)
SELECT country, year, water_stress_index
FROM climate, stats
WHERE ABS(water_stress_index - mean) / stddev > 2; -- This Z-score was adjusted accordingly.
	
    -- or IQR

WITH quartiles AS (
    SELECT 
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY water_stress_index) AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY water_stress_index) AS q3
    FROM climate
)
SELECT country, year, water_stress_index
FROM climate, quartiles
WHERE water_stress_index < q1 - 1.5 * (q3 - q1) 
    OR water_stress_index > q3 + 1.5 * (q3 - q1);
