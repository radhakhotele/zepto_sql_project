DROP TABLE IF EXISTS zepto;

create table zepto (
sku_id SERIAL PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(150) NOT NULL,
mrp NUMERIC(8,2),
discountPercent NUMERIC(5,2),
availableQuantity INTEGER,
discountedSellingPrice NUMERIC(8,2),
weightInGms INTEGER,
outOfStock BOOLEAN,	
quantity INTEGER
);

--Data exploration--

--Count of rows
SELECT COUNT(*)
FROM zepto;

--sample data
SELECT * FROM zepto
LIMIT 10;

--null values
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

--different product categories
SELECT DISTINCT category 
FROM zepto
ORDER BY category;

--products in stock and out of stock
SELECT outOfstock, COUNT(sku_id)
FROM zepto
GROUP BY outOfstock

--product names present many times
SELECT name, COUNT(sku_id) AS "Number of SKUs"
FROM zepto
GROUP BY name
HAVING COUNT(sku_id)>1
ORDER BY COUNT(sku_id) DESC;


--Data cleansing--

--products with price = 0
SELECT * FROM zepto 
WHERE mrp = 0 OR discountedSellingPrice = 0;

DELETE FROM zepto
WHERE mrp=0;

--convert price from paise to rupees
UPDATE zepto
SET mrp = mrp/100.0,
discountedSellingPrice = discountedSellingPrice/100.0;

SELECT mrp,discountedSellingPrice FROM zepto;

--data analysis : uncovering business insights

-- Q1. Find the top 10 best-value products based on the discount percentage.
SELECT DISTINCT name,mrp,discountpercent,discountedsellingprice
FROM zepto
ORDER BY discountpercent DESC
LIMIT 10;

--Q2.What are the Products with High MRP but Out of Stock
SELECT DISTINCT name,mrp
FROM zepto 
WHERE mrp>300 AND outOfstock = TRUE
ORDER BY mrp DESC;

--Q3.Calculate Estimated Revenue for each category
SELECT category, 
SUM(discountedsellingprice*availablequantity) AS total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue;

-- Q4. Find all products where MRP is greater than ₹500 and discount is less than 10%.
SELECT name,mrp,discountpercent
FROM zepto 
WHERE mrp>500 AND discountpercent <10
ORDER BY mrp DESC, discountPercent DESC;

-- Q5. Identify the top 5 categories offering the highest average discount percentage.
SELECT category,
ROUND(AVG(discountpercent),2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC 
LIMIT 5;

-- Q6. Find the price per gram for products above 100g and sort by best value.
SELECT DISTINCT name,weightInGms,discountedSellingPrice,
ROUND((discountedSellingPrice/weightInGms),2) AS price_per_gm
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gm;

--Q7.Group the products into categories like Low, Medium, Bulk.
SELECT DISTINCT name,weightInGms, 
CASE WHEN weightInGms < 1000 THEN 'Low'
	 WHEN weightInGms < 5000 THEN 'Medium'
	 ELSE 'Bulk'
END AS weight_category
FROM zepto;

--Q8.What is the Total Inventory Weight Per Category 
SELECT category,
ROUND(SUM(weightInGms*availablequantity)/1000,2) AS total_weight_in_kg
FROM zepto
GROUP BY category
ORDER BY total_weight_in_kg;

--Q9. Fast-Moving vs. Slow-Moving Products: (Fast = low stock, Slow = large stock still available)

-- For fast moving
SELECT 
    name,
    Category,
    availableQuantity,
    discountedSellingPrice
FROM zepto
ORDER BY availableQuantity ASC
LIMIT 10;  -- Fast moving

-- For slow moving
SELECT 
    name,
    Category,
    availableQuantity,
    discountedSellingPrice
FROM zepto
ORDER BY availableQuantity DESC
LIMIT 10;

--Q10. What is the Revenue Lost due to Out-of-Stock
SELECT 
    Category,
    SUM(discountedSellingPrice * quantity) AS lost_revenue
FROM zepto
WHERE outOfStock = TRUE
GROUP BY Category
ORDER BY lost_revenue DESC;

--Q11. What is the Margin Contribution by Category
SELECT 
    Category,
    SUM((mrp - discountedSellingPrice) * quantity) AS total_margin
FROM zepto
GROUP BY Category
ORDER BY total_margin DESC;

--Q12. What is the Category Revenue Share 
SELECT 
    Category,
    SUM(discountedSellingPrice * quantity) AS revenue,
    ROUND(100.0 * SUM(discountedSellingPrice * quantity) / 
    (SELECT SUM(discountedSellingPrice * quantity) FROM zepto),2) AS revenue_share_percent
FROM zepto
GROUP BY Category
ORDER BY revenue DESC;

