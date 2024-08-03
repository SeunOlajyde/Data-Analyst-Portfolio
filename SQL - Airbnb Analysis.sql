-- AIRBNB
-- This SQL project seeks to analysis a self created database centered on AirBnB shortlet

-- I created a database (SQL-AirBnB) and this was followed by 3-tables creation.
-- The table created were: 
    -- 1. airbnb_listings 
    -- 2. airbnb_rates 
    -- 3. airbnb_staff

-- See SQL queries for the creation og airbnb_rates and airbnb_staff table below. Same process were followed for airbnb_listings table.

-- Tool Used: SQL Server

-- Creating airbnb_rate table

CREATE TABLE airbnb_rates
(
    id INT,
    rates INT,
    occupancy INT,
    city VARCHAR(15),
    country VARCHAR(15)
)

INSERT INTO airbnb_rates VALUES
(1, 200, 500, 'lagos', 'Nigeria'),
(2, 100, 350, 'Accra', 'Ghana'),
(3, 500, 1000, 'Johannesburg', 'South Africa'),
(4, 50, 100, 'Gisenyi', 'Rwanda'),
(5, 150, 250, 'Gauteng', 'South Africa'),
(6, 150, 300, 'Ibadan', 'Nigeria'),
(7, 200, 200, 'Tema', 'Ghana'),
(8, 250, 450, 'Kigali', 'Rwanda')

INSERT INTO airbnb_rates (city, country)
VALUES
('lagos', 'Nigeria'),
('Accra', 'Ghana'),
('Johannesburg', 'South Africa'),
('Gisenyi', 'Rwanda'),
('Gauteng', 'South Africa'),
('Ibadan', 'Nigeria'),
('Tema', 'Ghana'),
('Kigali', 'Rwanda')


-- Creating airbnb_staff table


CREATE TABLE airbnb_staff
(
    id INT,
    staff_id INT,
    first_name VARCHAR(15),
    last_name VARCHAR(15),
    base_pay INT,
    city VARCHAR(15),
    country VARCHAR(15)
)

INSERT INTO airbnb_staff VALUES
(1, 3, 'Dipo', 'Olaoye', 50, 'Lagos', 'Nigeria'),
(2, 2, 'Sigeu', 'Bilama', 40, 'Accra', 'Ghana'),
(3, 5, 'Bako', 'Gafaar', 80, 'Johannesburg', 'South Africa'),
(4, 7, 'Njidar', 'Iskilu', 30, 'Gisenyi', 'Rwanda'),
(5, 6, 'Jide', 'Malane', 40, 'Gauteng', 'South Africa'),
(6, 4, 'Jyka', 'Dumdu', 35, 'Ibadan', 'Nigeria'),
(7, 10, 'Iskafar', 'Mulumba', 45, 'Tema', 'Ghana'),
(8, 12, 'Kilinku', 'Ubuntur', 50, 'Kigali', 'Rwanda')




-- Data Queries 
-- To gain insight into the activities (sales etc.) of the shortlets to advise management of Airbnb on performance.


-- Total Sales by Country --

SELECT al.country, SUM(al.no_of_rooms * ar.rates * ar.occupancy) AS total_sales
FROM airbnb_listings al
JOIN airbnb_rates ar
ON al.id = ar.id
GROUP BY al.country
ORDER BY total_sales DESC

--Total Sales by City (Top 5) --

SELECT TOP 5 al.city, SUM(al.no_of_rooms * ar.rates * ar.occupancy) AS total_sales
FROM airbnb_listings al
JOIN airbnb_rates ar
ON al.id = ar.id
GROUP BY al.city
ORDER BY total_sales DESC

-- Average Sales by country --

SELECT al.country, AVG(al.no_of_rooms * ar.rates * ar.occupancy) AS avg_sales
FROM airbnb_listings al
JOIN airbnb_rates ar
ON al.id = ar.id
GROUP BY al.country
ORDER BY avg_sales DESC

-- Total Sales made by Airbnb for 2011 to 2023 --

SELECT al.year_listed, SUM(al.no_of_rooms * ar.rates * ar.occupancy) AS total_sales
FROM airbnb_listings al
JOIN airbnb_rates ar
ON al.id = ar.id
GROUP BY al.year_listed
ORDER BY al.year_listed ASC

-- Global Sales made by Airbnb -- 

SELECT SUM(al.no_of_rooms * ar.rates * ar.occupancy) AS total_sales
FROM airbnb_listings AS al
JOIN airbnb_rates AS ar
ON al.id = ar.id

-- Country with the highest level of occupancy --

SELECT TOP 1 country, MAX(occupancy) AS highest_occupancy_country
FROM airbnb_rates
GROUP BY country
ORDER BY country DESC

-- Staff with highest Salary --

SELECT TOP 1 first_name, MAX(base_pay) AS highest_Staff_salary
FROM airbnb_staff
GROUP BY first_name

-- Rates exceeding the average rate for the rooms -- 

SELECT *
FROM airbnb_rates
WHERE rates > (
    SELECT AVG(rates) FROM airbnb_rates
)

-- Staff with Salary exceeding the avarage Salary -- 

SELECT *
FROM airbnb_staff
WHERE base_pay > (
    SELECT AVG(base_pay) FROM airbnb_staff
)

-- Staff base_pay categories -- 

SELECT staff_id, first_name, last_name, base_pay,
    CASE
        WHEN base_pay < 30 THEN 'Low'
        WHEN base_pay >= 30 AND base_pay < 50 THEN 'Medium'
        WHEN base_pay >= 50 THEN 'High'
    END AS base_pay_range
FROM airbnb_staff

-- Sales Commision --

SELECT al.id, ast.staff_id, ast.first_name, ast.last_name, ast.base_pay, (al.no_of_rooms * ar.rates * ar.occupancy) AS total_sales,
    CASE
        WHEN (al.no_of_rooms * ar.rates * ar.occupancy) >= 1000000 THEN base_pay + (base_pay * 0.20)
        WHEN (al.no_of_rooms * ar.rates * ar.occupancy) >= 200000 THEN base_pay + (base_pay * 0.05)
        ELSE base_pay -- 0% commission. Not qualified
    END AS revised_base_pay
FROM airbnb_listings al
JOIN airbnb_rates ar ON al.id = ar.id
JOIN airbnb_staff ast ON ar.id = ast.id

-- Sales Commision (details) --

SELECT al.id, ast.staff_id, ast.first_name, ast.last_name, ast.base_pay, (al.no_of_rooms * ar.rates * ar.occupancy) AS total_sales,
    CASE
        WHEN (al.no_of_rooms * ar.rates * ar.occupancy) >= 1000000 THEN base_pay * 0.20
        WHEN (al.no_of_rooms * ar.rates * ar.occupancy) >= 200000 THEN base_pay * 0.05
        ELSE 0 
    END AS sales_commission,
    base_pay + CASE
                 WHEN (al.no_of_rooms * ar.rates * ar.occupancy) >= 1000000 THEN base_pay * 0.20
                 WHEN (al.no_of_rooms * ar.rates * ar.occupancy) >= 200000 THEN base_pay * 0.05
                 ELSE base_pay 
               END AS revised_base_pay
FROM airbnb_listings al
JOIN airbnb_rates ar ON al.id = ar.id
JOIN airbnb_staff ast ON ar.id = ast.id
ORDER BY total_sales DESC


