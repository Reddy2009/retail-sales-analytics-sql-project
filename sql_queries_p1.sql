
-- This is to make sure the Database does not exist. If exists, we drop the database before creating Database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'SQL_Project_1')
BEGIN
	ALTER DATABASE SQL_Project_1 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE SQL_Project_1
END;
GO

-- Create Database for SQL Retail Sales Analysis
CREATE DATABASE SQL_Project_1
GO

-- Create Table
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales (
	transactions_id INT PRIMARY KEY,
	sale_date DATE,
	sale_time TIME,
	customer_id INT,
	gender VARCHAR(20),
	age INT,
	category VARCHAR(20),
	quantity INT,
	price_per_unit FLOAT,
	cogs FLOAT,
	total_sale FLOAT
);
-- Inserting Data from .csv file through Bulk Insert
--  Truncate table data if already exists
TRUNCATE TABLE retail_sales
GO
-- Insert data from .csv file
BULK INSERT retail_sales
FROM 'D:\Users\bharg\SQL\SQL_Practice_projects\Sales_Retail_p1\Retail_Sales_Analysis.csv'
WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
);

SELECT	
	* 
FROM retail_sales;


SELECT 
	DISTINCT category
FROM retail_sales


-- Data Cleaning

SELECT *
FROM retail_sales
WHERE
    transactions_id IS NULL 
	OR
    sale_date IS NULL 
	OR
    sale_time IS NULL 
	OR
    gender IS NULL 
	OR
    category IS NULL 
	OR
    quantity IS NULL 
	OR
    price_per_unit IS NULL 
	OR
    cogs IS NULL 
	OR
    total_sale IS NULL;


-- Deleting Null values

DELETE FROM retail_sales
WHERE
    transactions_id IS NULL 
	OR
    sale_date IS NULL 
	OR
    sale_time IS NULL 
	OR
    gender IS NULL 
	OR
    category IS NULL 
	OR
    quantity IS NULL 
	OR
    price_per_unit IS NULL 
	OR
    cogs IS NULL 
	OR
    total_sale IS NULL;



-- Data Exploration

-- Total Sales

SELECT COUNT(*) AS total_sales FROM retail_sales;


-- Total No of unique Customers

SELECT COUNT(DISTINCT customer_id) AS customers FROM retail_sales;

-- Total No of unique Categories

SELECT COUNT(DISTINCT category) AS no_of_categories FROM retail_sales;



-- Data Analysis & Business Key Problems & Answers

-- Q.1 Write a SQL Query to retrieve all columns for the sales made on '2022-11-05'

SELECT
	*
FROM retail_sales
WHERE sale_date = '2022-11-05';


-- Q.2 Write a SQL Query to retrieve all transactions where the category is 'Clothing' and quantity sold is alteast 4 in the month of Nov-2022


SELECT
	*
FROM retail_sales
WHERE 
	category = 'Clothing'
	AND sale_date >= '2022-11-01' 
	AND sale_date < '2022-12-01'
	AND quantity >= 4;

-- Q.3 Write a SQL Query to calculate the total sales for each category

SELECT
	category,
	SUM(total_sale) AS net_sales,
	COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category
ORDER BY SUM(total_sale) DESC;


-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

SELECT
	AVG(age) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';


-- Q.5 Write a SQL query to find the all transactions where total sale is greater than 1000

SELECT 
	*
FROM retail_sales
WHERE total_sale > 1000;


-- Q.6 Write a SQL query to find the total no of transactions made by each gender in each category

SELECT 
	category,
	gender,
	COUNT(transactions_id) AS total_transactions
FROM retail_sales
GROUP BY 
		category,
		gender
ORDER BY category


-- Q.7 Write a SQL query to calculate average sale for each month. Find our the best selling month in each year

-- Using CTE
WITH monthly_sales AS (
	SELECT 
		YEAR(sale_date) AS sale_year,
		MONTH(sale_date) AS sale_month,
		ROUND(AVG(total_sale), 2) AS avg_sale,
		RANK() OVER(PARTITION BY YEAR(sale_date) ORDER BY ROUND(AVG(total_sale), 2) DESC) AS sale_rank
	FROM retail_sales
	GROUP BY YEAR(sale_date), MONTH(sale_date)
)

SELECT
	sale_year,
	sale_month,
	avg_sale
FROM monthly_sales
WHERE sale_rank = 1


-- Using SubQuery
SELECT
	sale_year,
	sale_month,
	avg_sale
FROM
(
	SELECT 
		YEAR(sale_date) AS sale_year,
		MONTH(sale_date) AS sale_month,
		ROUND(AVG(total_sale), 2) AS avg_sale,
		RANK() OVER(PARTITION BY YEAR(sale_date) ORDER BY ROUND(AVG(total_sale), 2) DESC) AS sale_rank
	FROM retail_sales
	GROUP BY YEAR(sale_date), MONTH(sale_date)
)t
WHERE sale_rank = 1


-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales

SELECT TOP 5
	customer_id,
	SUM(total_sale) as total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY SUM(total_sale) DESC


-- Q.9 Write a SQL query to find the number of unique customers who purchased item from each category

SELECT
	category,
	COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY category;

-- Q.10 Write a SQL query to create each shift and number of orders
-- (Example Morning <= 12, Afternoon Between 12 & 17, Evening >= 17)

WITH shift_segmentation AS (
	SELECT
		*,
		CASE
			WHEN sale_time < '12:00:00' THEN 'Morning'
			WHEN sale_time >= '12:00:00' AND sale_time < '18:00:00' THEN 'Afternoon'
			ELSE 'Evening'
		END AS shift
	FROM retail_sales
)

SELECT
	shift,
	COUNT(*) AS total_orders
FROM shift_segmentation
GROUP BY shift
