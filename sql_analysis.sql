CREATE DATABASE IF NOT EXISTS alcohol_db;
USE alcohol_db;

CREATE TABLE IF NOT EXISTS alcohol_sales(
id INT PRIMARY KEY AUTO_INCREMENT,
year INT NOT NULL,
region VARCHAR(50) NOT NULL,
wine DECIMAL(10,2) NOT NULL,
beer DECIMAL(10,2) NOT NULL,
vodka DECIMAL(10,2) NOT NULL,
champagne DECIMAL(10,2) NOT NULL,
brandy DECIMAL(10,2) NOT NULL
);

SELECT * FROM alcohol_sales;

ALTER TABLE alcohol_sales
ADD COLUMN total_consumption DECIMAL(10,2);

UPDATE alcohol_sales 
SET total_consumption = wine+beer+vodka+brandy+champagne;


-- SELECTING THE TOTAL CONSUMPTION PER REGION(TOP 10).
SELECT region, SUM(total_consumption)`total consumption`
FROM alcohol_sales
GROUP BY region
ORDER BY `total consumption` DESC
LIMIT 10;

-- SELECT THE TOTAL CONSUMPTION PER REGION BASED ON THE CURRENT YEAR
SELECT region, SUM(total_consumption)`total consumption`
FROM alcohol_sales
WHERE year = (SELECT MAX(year) FROM alcohol_sales)
GROUP BY region
ORDER BY `total consumption` DESC
LIMIT 10;

-- Top Regions by Total Consumption (Averaged Across Years)
SELECT region, 
ROUND(AVG(total_consumption),2) `average consumption`,
MAX(total_consumption) `peak consumption`,
MIN(total_consumption) `lowest consumption`
FROM alcohol_sales
GROUP BY region
ORDER BY `average consumption` DESC
LIMIT 10;

-- Regions with Highest Consumption Growth
WITH yearly_avg AS (
SELECT year, region,
ROUND(AVG(total_consumption),2) AS avg_consumption
FROM alcohol_sales
GROUP BY year, region
),
 growth_calc AS(
 SELECT region,
 MAX(avg_consumption)-MIN(avg_consumption) AS consumption_growth,
 (MAX(avg_consumption) - MIN(avg_consumption)) / MIN(avg_consumption)*100 AS growth_percentage
 FROM yearly_avg
 GROUP BY region
 )
 SELECT region,
 ROUND(consumption_growth,2) AS absolute_growth,
 ROUND(growth_percentage,2) AS percentage_growth
 FROM growth_calc
 ORDER BY absolute_growth DESC;
 
 --  Most Popular Alcohol Types by Region
 SELECT region,
 CASE 
 WHEN MAX(wine)>=MAX(beer) AND MAX(wine)>=MAX(champagne) AND MAX(wine)>=MAX(vodka) AND MAX(wine)>=MAX(brandy) THEN 'wine' 
 WHEN MAX(beer)>=MAX(wine) AND MAX(beer)>=MAX(champagne) AND MAX(beer)>=MAX(vodka) AND MAX(beer)>=MAX(brandy) THEN 'beer' 
 WHEN MAX(vodka)>=MAX(wine) AND MAX(vodka)>=MAX(champagne) AND MAX(vodka)>=MAX(beer) AND MAX(vodka)>=MAX(brandy) THEN 'wine' 
 WHEN MAX(brandy)>=MAX(wine) AND MAX(brandy)>=MAX(champagne) AND MAX(brandy)>=MAX(vodka) AND MAX(brandy)>=MAX(beer) THEN 'wine' 
 ELSE 'champagne' 
 END AS popular_alcohol_type,
 ROUND(AVG(total_consumption),2) AS average_consumption
 FROM alcohol_sales
 GROUP BY region
 ORDER BY average_consumption DESC;


-- Detailed Analysis for Top 10 Recommended Regions
WITH top_regions AS(
SELECT region
FROM alcohol_sales
GROUP BY region
ORDER BY AVG(total_consumption) DESC
LIMIT 10
)
SELECT a.year,
a.region,
a.wine,
a.beer,
a.vodka,
a.champagne,
a.brandy,
a.total_consumption
FROM alcohol_sales a INNER JOIN top_regions t
ON a.region = t.region
ORDER BY a.region, a.year;

 