USE [OnlineRetailPractice]
GO
--541,909 ROWS
SELECT * FROM OnlineRetail2023
--A. CLEANING THE DATASET
--1. DELETE MISSING VALUES
--NONE
SELECT * FROM OnlineRetail2023 WHERE InvoiceNo IS NULL
--NONE
SELECT * FROM OnlineRetail2023 WHERE InvoiceDate IS NULL
--NONE
SELECT * FROM OnlineRetail2023 WHERE StockCode IS NULL
--1,454 ROWS
SELECT * FROM OnlineRetail2023 WHERE Description IS NULL
--NONE
SELECT * FROM OnlineRetail2023 WHERE Quantity IS NULL
--NONE
SELECT * FROM OnlineRetail2023 WHERE UnitPrice IS NULL
--135,080 ROWS
SELECT * FROM OnlineRetail2023 WHERE CustomerID IS NULL
--NONE
SELECT * FROM OnlineRetail2023 WHERE Country IS NULL
--DELETING ROWS WITH NULLS
--SINCE CUSTOMER ID IS AN ID WE CANNOT REPLACE IT WITH A MEAN, MODE, OR MEDIAN
--135,080 ROWS DELETED
DELETE FROM OnlineRetail2023 WHERE CustomerID IS NULL
--CHECKING IF THERE ARE ANY NULLS
--NONE
SELECT * FROM OnlineRetail2023 WHERE CustomerID IS NULL
--NONE
SELECT * FROM OnlineRetail2023 WHERE Description IS NULL
--ROWS REMAINING. 406,829 ROWS
SELECT * FROM OnlineRetail2023

--2. THE DATASET IS WITHIN THE RANGE OF 01/12/2010 AND 09/12/2011.
--DELETE ROWS OUTSIDE THIS RANGE. NONE
SELECT * FROM OnlineRetail2023 WHERE InvoiceDate NOT BETWEEN '2010-12-01' AND '2011-12-10'

--3.FIND MINIMUM PRICE
SELECT MAX(UnitPrice) AS MaximumPrice, MIN(UnitPrice) AS MinimumPrice,  AVG(UnitPrice) AS AveragePrice
FROM OnlineRetail2023
--DELETE PRICES WITH 0.00. 40 ROWS
SELECT * FROM OnlineRetail2023 WHERE UnitPrice <= 0.00
DELETE FROM OnlineRetail2023 WHERE UnitPrice <= 0.00
--CHECK AGAIN MINIMUM PRICE
SELECT MAX(UnitPrice) AS MaximumPrice, MIN(UnitPrice) AS MinimumPrice,  AVG(UnitPrice) AS AveragePrice
FROM OnlineRetail2023
--DELETE PRICES WITH O.OO1. 4 ROWS
SELECT * FROM OnlineRetail2023 WHERE UnitPrice <= 0.001
DELETE FROM OnlineRetail2023 WHERE UnitPrice <= 0.001
--CHECK AGAIN MINIMUM PRICE
SELECT MAX(UnitPrice) AS MaximumPrice, MIN(UnitPrice) AS MinimumPrice,  AVG(UnitPrice) AS AveragePrice
FROM OnlineRetail2023
--1 ROW
SELECT * FROM OnlineRetail2023 WHERE UnitPrice <= 0.01
DELETE FROM OnlineRetail2023 WHERE UnitPrice <= 0.01
--CHECK AGAIN MINIMUM PRICE
SELECT MAX(UnitPrice) AS MaximumPrice, MIN(UnitPrice) AS MinimumPrice,  AVG(UnitPrice) AS AveragePrice
FROM OnlineRetail2023
--3 ROWS
SELECT * FROM OnlineRetail2023 WHERE UnitPrice <= 0.03
DELETE FROM OnlineRetail2023 WHERE UnitPrice <= 0.03
--CHECK AGAIN MINIMUM PRICE
SELECT MAX(UnitPrice) AS MaximumPrice, MIN(UnitPrice) AS MinimumPrice,  AVG(UnitPrice) AS AveragePrice
FROM OnlineRetail2023
--66 ROWS. I WILL NOT DELETE SINCE IT IS AN WHOLESALE ONLINE STORE SELLING IN STERLING POUND
SELECT * FROM OnlineRetail2023 WHERE UnitPrice <= 0.04
--ROWS LEFT. 406,781 ROWS
SELECT COUNT(*) FROM OnlineRetail2023
SELECT * FROM OnlineRetail2023

--4. DELETE DUPLICATES
--FINDING THE HIGHEST NUMBER OF ROWS FOR ID
--22,182 
SELECT DISTINCT InvoiceNo FROM OnlineRetail2023
--20,453 
SELECT DISTINCT InvoiceDate FROM OnlineRetail2023
--3,683 
SELECT DISTINCT StockCode FROM OnlineRetail2023
--3,884
SELECT DISTINCT Description FROM OnlineRetail2023
--434 
SELECT DISTINCT Quantity FROM OnlineRetail2023
--4,371
SELECT DISTINCT CustomerID FROM OnlineRetail2023
--37 
SELECT DISTINCT Country FROM OnlineRetail2023
--FINDING A COMBINATION OF COLUMNS THAT REACHES TOTAL NUMBER OF ROWS
--401,504 ROWS
SELECT DISTINCT InvoiceNo, InvoiceDate, StockCode, Quantity
FROM OnlineRetail2023
SELECT COUNT(*) FROM 
	(SELECT DISTINCT InvoiceNo, InvoiceDate, StockCode, Quantity
	 FROM OnlineRetail2023) x
--NEED TO FIND THE DIFFERENCE OF ROWS. 5,277
SELECT 406781 - 401504
--FINDING THE DUPLICATES
SELECT *,
ROW_NUMBER() OVER(PARTITION BY InvoiceNo, InvoiceDate, StockCode, Quantity ORDER BY (SELECT NULL)) AS Rows
FROM OnlineRetail2023
GO
WITH Duplicates AS
	(SELECT *,
	 ROW_NUMBER() OVER(PARTITION BY InvoiceNo, InvoiceDate, StockCode, Quantity ORDER BY (SELECT NULL)) AS Rows
	 FROM OnlineRetail2023)
--SELECT * FROM Duplicates WHERE Rows > 1
DELETE FROM Duplicates WHERE Rows > 1
--401,504 ROWS LEFT
SELECT * FROM OnlineRetail2023
SELECT COUNT(*) FROM OnlineRetail2023

--5. QUANTITY COLUMN HAS NEGATIVE VALUES. CHANGE TO POSITIVE
UPDATE OnlineRetail2023
SET Quantity = ABS(Quantity)
--NONE
SELECT * FROM OnlineRetail2023 WHERE Quantity = (Quantity * -1)

--6. ADD A COLUMN FOR SALES
ALTER TABLE OnlineRetail2023
ADD Sales money
--INSERT VALUES INTO THE COLUMN
UPDATE OnlineRetail2023
SET Sales = UnitPrice * Quantity
--CHECK
SELECT * FROM OnlineRetail2023

--7. IF THE INVOICE NO STARTS WITH A C, IT IS A CANCELLATION.
--CREATE A TABLE FOR CANCELLED ORDERS AND DELETE FROM ORIGINAL TABLE
--8,837 ROWS
SELECT * FROM OnlineRetail2023
WHERE LEFT(InvoiceNo, 1) = 'C' AND SUBSTRING(InvoiceNo, 1, 1) = 'C'
--8,837 ROWS
SELECT * INTO CancelledOrders2023
FROM OnlineRetail2023
WHERE LEFT(InvoiceNo, 1) = 'C' AND SUBSTRING(InvoiceNo, 1, 1) = 'C'
--DELETE FROM ORIGINAL TABLE. 8,837 ROWS
DELETE FROM OnlineRetail2023 WHERE LEFT(InvoiceNo, 1) = 'C' AND SUBSTRING(InvoiceNo, 1, 1) = 'C'
--ROWS LEFT. 392,667 ROWS
SELECT COUNT(*) FROM OnlineRetail2023
SELECT * FROM OnlineRetail2023
--8,837 ROWS IN CANCELLED ORDERS
SELECT * FROM CancelledOrders2023

--8. CREATE A PRIMARY KEY
ALTER TABLE OnlineRetail2023
ALTER COLUMN InvoiceNo nvarchar(50) NOT NULL
ALTER TABLE OnlineRetail2023
ALTER COLUMN InvoiceDate datetime2 NOT NULL
ALTER TABLE OnlineRetail2023
ALTER COLUMN StockCode nvarchar(50) NOT NULL
ALTER TABLE OnlineRetail2023
ALTER COLUMN Quantity int NOT NULL
--ADDING THE PRIMARY KEY
ALTER TABLE OnlineRetail2023
ADD ID int
CONSTRAINT PK_onlineRetail2023 PRIMARY KEY(InvoiceNo, InvoiceDate, StockCode, Quantity) IDENTITY(1,1)
--CHECK THE TABLE. 392,667 ROWS
SELECT * FROM OnlineRetail2023
ORDER BY ID;

--B. ANALYSIS
--1. WHOLE DATASET TOTAL SALES FOR THE WHOLE DATASET
SELECT SUM(Sales) FROM OnlineRetail2023
--THE MINIMUM, MAXIMUM, AVERAGE SALES OF WHOLE DATASET
SELECT
MAX(Sales) AS MaximumSales,
MIN(Sales) AS MinimumSales,
AVG(Sales) AS AverageSales
FROM OnlineRetail2023
--2. MOST FREQUENTLY BOUGHT PRODUCT
SELECT StockCode, Description, COUNT(*) AS Count
FROM OnlineRetail2023
GROUP BY StockCode, Description
ORDER BY Count DESC
--3. COUNTRY WITH THE HIGHEST SALES
--USING GROUP BY
SELECT Country, SUM(Sales) AS TotalSales
FROM OnlineRetail2023
GROUP BY Country
ORDER BY TotalSales DESC
--USING WINDOW FUNCTION
SELECT *,
SUM(Sales) OVER(PARTITION BY Country) AS CountrySales
FROM OnlineRetail2023
ORDER BY CountrySales DESC
--4. RANK SALES FOR OVERALL DATA
SELECT *,
DENSE_RANK() OVER(ORDER BY Sales DESC) AS SalesRank
FROM OnlineRetail2023
ORDER BY SalesRank
--5.RANKING SALES IN THE COUNTRY
--BY RANK
SELECT *,
DENSE_RANK() OVER(PARTITION BY Country ORDER BY Sales DESC) AS SalesRank
FROM OnlineRetail2023
ORDER BY SalesRank, Country
--BY RANK IN COUNTRY
SELECT *,
DENSE_RANK() OVER(PARTITION BY Country ORDER BY Sales DESC) AS SalesRank
FROM OnlineRetail2023
ORDER BY Country
--TOP 5 SALES FROM EVERY COUNTRY
SELECT * FROM
	(
	SELECT *,
	DENSE_RANK() OVER(PARTITION BY Country ORDER BY Sales DESC) AS SalesRank
	FROM OnlineRetail2023
	) AS X
WHERE SalesRank <= 5
ORDER BY Country
--TOP 5 SALES FROM EVERY COUNTRY SHOWING COUNTRY SALES COLUMN
SELECT * FROM
	(
	SELECT *,
	SUM(Sales) OVER(PARTITION BY Country) AS CountrySales,
	DENSE_RANK() OVER(PARTITION BY Country ORDER BY Sales DESC) AS SalesRank
	FROM OnlineRetail2023
	) AS X
WHERE SalesRank <= 5
ORDER BY Country
--COUNTRY WITH THE MOST CUSTOMERS
--4,338 DISTINCT CUSTOMERS
SELECT COUNT(DISTINCT CustomerID) FROM OnlineRetail2023
--90% OF THE CUSTOMERS ARE FROM THE UNITED KINGDOM
SELECT Country, COUNT(DISTINCT CustomerID) AS CustomerNo
FROM OnlineRetail2023
GROUP BY Country
ORDER BY CustomerNo DESC
--6. CUSTOMER ID SALES
--USING GROUP BY
SELECT CustomerID, Country, SUM(Sales) AS CustomerSales
FROM OnlineRetail2023
GROUP BY CustomerID, Country
ORDER BY CustomerSales DESC
--USING WINDOW FUNCTION
SELECT *,
SUM(Sales) OVER(PARTITION BY CustomerId) AS CustomerSales
FROM OnlineRetail2023
ORDER BY CustomerSales DESC
--7. PRODUCT SALES
--USING GROUP BY
SELECT StockCode, Description, SUM(Sales) AS ProductSales
FROM OnlineRetail2023
GROUP BY StockCode, Description
ORDER BY ProductSales DESC
--USING WINDOW FUNCTION
SELECT *,
SUM(Sales) OVER(PARTITION BY StockCode, Description) AS ProductSales
FROM OnlineRetail2023
ORDER BY ProductSales DESC
--8. ID SALES
--USING GROUP BY
SELECT ID, SUM(Sales) AS IDsales
FROM OnlineRetail2023
GROUP BY ID
ORDER BY IDsales DESC
--USING WINDOW FUNCTION
SELECT *,
SUM(Sales) OVER(PARTITION BY ID) AS IDsales
FROM OnlineRetail2023
ORDER BY IDsales DESC
--9. DATE, MONTH, AND YEAR WITH THE MAXIMUM AND MINIMUM SALES FOR THE WHOLE DATASET
WITH TotalDataSales AS
	(SELECT CONVERT(date, InvoiceDate) AS Date, SUM(Sales) AS TotalSales
	 FROM OnlineRetail2023
	 GROUP BY CONVERT(date, InvoiceDate)) 
SELECT Date, TotalSales
FROM TotalDataSales
WHERE TotalSales =  (SELECT ROUND(MAX(TotalSales),2) AS MaxSales FROM TotalDataSales)
OR TotalSales = (SELECT ROUND(MIN(TotalSales),2) AS MinSales FROM TotalDataSales);
--10. DATE AND COUNTRY WITH THE HIGHEST AND LOWEST SALES
WITH CountrySales AS
	(SELECT Country, CAST(InvoiceDate AS date) AS Date, SUM(Sales) AS TotalSales
	 FROM OnlineRetail2023
	 GROUP BY Country, CAST(InvoiceDate AS date))
SELECT Country, Date, TotalSales FROM CountrySales
WHERE TotalSales = (SELECT ROUND(MAX(TotalSales), 2) AS MaxSales FROM CountrySales)
OR TotalSales = (SELECT ROUND(MIN(TotalSales), 2) AS MinSales FROM CountrySales);
--COUNTRIES WITH ABOVE AVERAGE SALES
WITH CountrySales AS
	(SELECT Country, SUM(Sales) AS TotalSales 
	 FROM OnlineRetail2023
	 GROUP BY Country) 
SELECT Country, TotalSales
FROM CountrySales 
WHERE TotalSales > (SELECT ROUND(AVG(TotalSales), 2) FROM CountrySales)
ORDER BY TotalSales DESC;
--COUNTRIES WITH LESS THAN AVERAGE SALES
WITH CountrySales AS
	(SELECT Country, SUM(Sales) AS TotalSales 
	 FROM OnlineRetail2023
	 GROUP BY Country) 
SELECT Country, TotalSales
FROM CountrySales 
WHERE TotalSales < (SELECT ROUND(AVG(TotalSales), 2) FROM CountrySales)
ORDER BY TotalSales DESC;
--11. CUSTOMER ID AND DATE WITH THE HIGHEST AND LOWEST SALES
WITH CustomerIdSales AS
	(SELECT CustomerID, CONVERT(date, InvoiceDate) AS Date, SUM(Sales) AS CustomerSales
	 FROM OnlineRetail2023
	 GROUP BY CustomerID, CONVERT(date, InvoiceDate))
SELECT CustomerID, Date, CustomerSales FROM CustomerIdSales
WHERE CustomerSales = (SELECT ROUND(MAX(CustomerSales),2) FROM CustomerIdSales)
OR CustomerSales = (SELECT ROUND(MIN(CustomerSales),2) FROM CustomerIdSales);
--CUSTOMERS WITH HIGHER THAN AVERAGE SALES
WITH CustomerSales AS 
	(SELECT CustomerID, SUM(Sales) AS TotalSales
	 FROM OnlineRetail2023
	 GROUP BY CustomerID)
SELECT CustomerID, TotalSales FROM CustomerSales
WHERE TotalSales > (SELECT ROUND(AVG(TotalSales),2) FROM CustomerSales)
ORDER BY TotalSales DESC;
--CUSTOMERS WITH LOWER THAN AVERAGE SALES
WITH CustomerSales AS 
	(SELECT CustomerID, SUM(Sales) AS TotalSales
	 FROM OnlineRetail2023
	 GROUP BY CustomerID)
SELECT CustomerID, TotalSales FROM CustomerSales
WHERE TotalSales < (SELECT ROUND(AVG(TotalSales),2) FROM CustomerSales)
ORDER BY TotalSales DESC;
--12. PRODUCTS WITH THE HIGHEST AND LOWEST SALES
WITH ProductSales AS
	(SELECT StockCode, Description, CONVERT(date, InvoiceDate) AS Date, SUM(Sales) AS TotalSales
	 FROM OnlineRetail2023
	 GROUP BY StockCode, Description, CONVERT(date, InvoiceDate))
SELECT StockCode, Description, Date, TotalSales
FROM ProductSales
WHERE TotalSales = (SELECT ROUND(MAX(TotalSales), 2) FROM ProductSales)
OR TotalSales = (SELECT ROUND(MIN(TotalSales), 2) FROM ProductSales)
--PRODUCTS WITH HIGHER THAN AVERAGE SALES
WITH ProductSales AS 
	(SELECT StockCode, Description, SUM(Sales) AS TotalSales
	 FROM OnlineRetail2023
	 GROUP BY StockCode, Description)
SELECT StockCode, Description, TotalSales FROM ProductSales
WHERE TotalSales > (SELECT ROUND(AVG(TotalSales),2) FROM ProductSales)
ORDER BY TotalSales DESC;
--PRODUCTS WITH LOWER THAN AVERAGE SALES
WITH ProductSales AS 
	(SELECT StockCode, Description, SUM(Sales) AS TotalSales
	 FROM OnlineRetail2023
	 GROUP BY StockCode, Description)
SELECT StockCode, Description, TotalSales FROM ProductSales
WHERE TotalSales < (SELECT ROUND(AVG(TotalSales),2) FROM ProductSales)
ORDER BY TotalSales DESC;
--13. RUNNING TOTAL/ACCUMULATING TOTAL
--FOR COUNTRY
SELECT Country, InvoiceDate, Sales, SUM(Sales)
OVER(PARTITION BY Country ORDER BY InvoiceDate DESC
ROWS BETWEEN 0 PRECEDING AND UNBOUNDED FOLLOWING) AS RunningTotal
FROM OnlineRetail2023
--FOR CUSTOMER ID
SELECT CustomerID, InvoiceDate, Sales, SUM(Sales)
OVER(PARTITION BY CustomerID ORDER BY InvoiceDate DESC
ROWS BETWEEN 0 PRECEDING AND UNBOUNDED FOLLOWING) AS RunningTotal
FROM OnlineRetail2023
--FOR PRODUCTS
SELECT StockCode, Description, InvoiceDate, Sales, SUM(Sales)
OVER(PARTITION BY StockCode, Description ORDER BY InvoiceDate DESC
ROWS BETWEEN 0 PRECEDING AND UNBOUNDED FOLLOWING) AS RunningTotal
FROM OnlineRetail2023
--FOR WHOLE DATASET
SELECT InvoiceDate, Sales, 
SUM(Sales)
OVER(ORDER BY InvoiceDate 
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningTotal2
FROM OnlineRetail2023 
ORDER BY InvoiceDate
--14. CANCELLED ORDERS
SELECT * FROM CancelledOrders2023
--COUNTRY WITH THE HIGHEST CANCELLED ORDERS
SELECT Country, COUNT(Sales) AS Number
FROM CancelledOrders2023
GROUP BY Country
ORDER BY Number DESC
--CUSTOMER ID WITH THE HIGHEST CANCELLED ORDERS
SELECT CustomerID, COUNT(Sales) AS Number
FROM CancelledOrders2023
GROUP BY CustomerID
ORDER BY Number DESC
--PRODUCT WITH THE HIGHES CANCELLED ORDERS
SELECT StockCode, Description, COUNT(Sales) AS Number
FROM CancelledOrders2023
GROUP BY StockCode, Description
ORDER BY Number DESC
--DATE WITH THE HIGHEST CANCELLATIONS
SELECT CAST(InvoiceDate AS date) AS Date, COUNT(Sales) AS Number
FROM CancelledOrders2023
GROUP BY CAST(InvoiceDate AS date)
ORDER BY Number DESC
GO
--15. CREATE A PROCEDURE
--A PROCEDURE WILL GIVE QUICK RESULTS OF WHAT WE WANT TO KNOW
--PROCEDURE FOR RUNNING/ACCUMULATING TOTAL FOR THE WHOLE DATASET
CREATE PROCEDURE WholeOnlineRetail2023 AS
BEGIN
	SELECT InvoiceDate, Sales, SUM(Sales)
	OVER(ORDER BY InvoiceDate 
	ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningTotal2
	FROM OnlineRetail2023 
	ORDER BY InvoiceDate	
END

EXECUTE WholeOnlineRetail2023

--END--