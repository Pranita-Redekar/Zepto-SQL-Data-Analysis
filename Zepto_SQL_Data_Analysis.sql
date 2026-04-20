DROP TABLE IF EXISTS zepto;

CREATE TABLE IF NOT EXISTS zepto(
	    sku_id SERIAL PRIMARY KEY,
		Category VARCHAR(100),
		name VARCHAR(100) NOT NULL,
		mrp NUMERIC(8,2),
		discountPercent NUMERIC(5,2),  
		availableQuantity INT,
		discountedSellingPrice NUMERIC(8,2),  
		weightInGms INT,
		outOfStock BOOLEAN,
		quantity INT 
);

SELECT * FROM zepto;

--IMPORT CSV FILE
COPY zepto(Category,name,mrp,discountPercent,availableQuantity,discountedSellingPrice,weightInGms,outOfStock,quantity)
FROM 'D:\Data Analyst\SQL\Projects\Zepto\zepto_v2.csv'
DELIMITER ','
CSV HEADER;


-- Find total Count of Product 
SELECT COUNT(*) FROM zepto;

--Null values
SELECT * FROM zepto
WHERE name IS NULL
OR
category IS NULL
OR
mrp IS NULL
OR
discountPercent IS NULL
OR
discountedSellingPrice IS NULL
OR
weightInGms IS NULL
OR
availableQuantity IS NULL
OR
outOfStock IS NULL
OR
quantity IS NULL;

--Different product categories
SELECT DISTINCT category
FROM zepto
ORDER BY category;

--Products in stock vs out of stock
SELECT outOfStock, COUNT(sku_id)
FROM zepto
GROUP BY outOfStock;

--Product names present multiple times
SELECT name, COUNT(sku_id) AS "Number of SKUs"
FROM zepto
GROUP BY name
HAVING count(sku_id) > 1
ORDER BY count(sku_id) DESC;

--Data Cleaning
--Products with price = 0
SELECT * FROM zepto
WHERE mrp = 0 OR discountedSellingPrice = 0;

DELETE FROM zepto
WHERE mrp = 0;

--Convert paise to rupees
UPDATE zepto
SET mrp = mrp / 100.0,
discountedSellingPrice = discountedSellingPrice / 100.0;

SELECT mrp, discountedSellingPrice FROM zepto;

-- Data Analysis
-- Find all products with discount more than 15%
SELECT name, discountPercent
From Zepto
Where discountPercent>15;

-- Show products sorted by hight MRP in descending order
SELECT DISTINCT name,mrp
FROM zepto
ORDER BY mrp DESC;

-- Show count products in each category
SELECT DISTINCT category, COUNT(name) AS Count_Of_Products
FROM zepto
GROUP BY name,category;

-- Find average of discount price per category
SELECT category, ROUND(AVG(discountedSellingPrice),2) AS Avg_Discount_Price
FROM zepto 
GROUP BY category,discountedSellingPrice;


--Find top 5 products with highest discount amount.
SELECT DISTINCT name, (mrp - discountedSellingPrice) AS discount_price
FROM zepto 
ORDER BY discount_price DESC
LIMIT 5;

--Find products where discount is above average.
SELECT name, discountPercent
FROM zepto
WHERE discountPercent > (SELECT AVG(discountPercent) FROM zepto);

-- Find out of stock products.
SELECT name,outOfStock
FROM zepto
WHERE outOfStock='true';

--Categorize product based on discount.
SELECT name,discountPercent,
	CASE 
		WHEN discountPercent>=17 THEN 'High'
		WHEN discountPercent BETWEEN 14 AND 16 THEN 'Medium'
		ELSE 'Low'
	END AS discount_category
FROM zepto;

-- Find category with highest average MRP
SELECT category, ROUND(AVG(mrp),2) AS avg_mrp
FROM zepto
GROUP BY category
ORDER BY avg_mrp DESC
LIMIT 1;

--Rank product by price within each category
SELECT category, name, mrp,
	RANK() OVER(PARTITION BY category ORDER BY MRP DESC ) AS Products_rank
FROM zepto;

-- Find second highest priced product.
SELECT name, mrp 
FROM zepto
ORDER BY mrp DESC
LIMIT 1 OFFSET 1;

-- Find product with low stock but high price
SELECT name, availableQuantity,mrp
FROM zepto 
WHERE availableQuantity < 5 AND mrp>5000;

-- Show total inventory value
SELECT SUM(discountedSellingPrice * availableQuantity) AS total_value
FROM zepto;

-- Find duplicate product names
SELECT name, COUNT(*)
FROM zepto
GROUP BY name
HAVING COUNT(*)>1 ;

-- Find total number of products available in stock
SELECT SUM(availableQuantity) AS total_stock
FROM zepto 

-- Find the least discounted product
SELECT name, discountedSellingPrice
FROM zepto 
ORDER BY discountedSellingPrice ASC
LIMIT 1;

-- Find products where selling price is less than 1200
SELECT name
FROM zepto
WHERE discountedSellingPrice< 1200;

-- Find products where mrp is more than average mrp
SELECT name, mrp
FROM zepto 
WHERE mrp > (SELECT AVG(mrp) FROM zepto);

-- Find product with highest available quantity
SELECT name, availableQuantity
FROM zepto 
ORDER BY availableQuantity DESC;

--Find top 3 categories with highest average discount
SELECT category,ROUND(AVG(discountPercent),2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 3;

-- What are the Products with High MRP but Out of Stock
SELECT DISTINCT name,mrp
FROM zepto
WHERE outOfStock = TRUE and mrp > 300
ORDER BY mrp DESC;

--Find the price per gram for products above 100g and sort by best value.
SELECT DISTINCT name, weightInGms, discountedSellingPrice,
ROUND(discountedSellingPrice/weightInGms,2) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram;

--Group the products into categories like Low, Medium, Bulk.
SELECT DISTINCT name, weightInGms,
CASE WHEN weightInGms < 1000 THEN 'Low'
	WHEN weightInGms < 5000 THEN 'Medium'
	ELSE 'Bulk'
	END AS weight_category
FROM zepto;

--What is the Total Inventory Weight Per Category 
SELECT category,
SUM(weightInGms * availableQuantity) AS total_weight
FROM zepto
GROUP BY category
ORDER BY total_weight;

