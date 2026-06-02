
USE [SQL_DataAnalysis&Automation];
GO

-- 2. Create base tables
CREATE TABLE CustomerTable (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(100) NOT NULL,
    age INT,
    gender VARCHAR(10)
);

CREATE TABLE ProductsTable (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE SalesTable (
    sale_id INT PRIMARY KEY,
    customer_id INT FOREIGN KEY REFERENCES Customer_Table(customer_id),
    product_id INT FOREIGN KEY REFERENCES Products_Table(product_id),
    sale_date DATE NOT NULL,
    quantity INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL
);


-- 3. Populate original dataset values
INSERT INTO Customer_Table VALUES 
(1, 'John Doe', 'Lagos', 30, 'Male'),
(2, 'Jane Smith', 'Abuja', 28, 'Female'),
(3, 'Peter Adams', 'Port Harcourt', 40, 'Male'),
(4, 'Sarah Johnson', 'Kano', 35, 'Female');

INSERT INTO Products_Table VALUES 
(101, 'Laptop', 'Electronics', 350000.00),
(102, 'Phone', 'Electronics', 150000.00),
(103, 'Printer', 'Office', 85000.00);

INSERT INTO Sales_Table VALUES 
(5001, 1, 101, '2024-01-10', 1, 350000.00),
(5002, 2, 102, '2024-02-15', 2, 300000.00),
(5003, 3, 103, '2024-03-20', 1, 85000.00),
(5004, 4, 101, '2024-03-25', 1, 350000.00);
GO

-- 4. Verify base table creation
SELECT * FROM Customer_Table;
SELECT * FROM Products_Table;
SELECT * FROM Sales_Table;




-- Test and display the view data
SELECT * FROM HighSpendingCustomers;

-- 1. Drop the view if it already exists to prevent duplication errors
DROP VIEW IF EXISTS HighSpendingCustomers;
GO

CREATE VIEW HighSpendingCustomers AS
SELECT 
    c.customer_id,
    c.name,
    c.location,
    SUM(s.total_amount) AS total_spent
FROM Customer_Table c
JOIN Sales_Table s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.name, c.location
HAVING SUM(s.total_amount) > 300000;
GO

SELECT * FROM HighSpendingCustomers;

-- MATERIALIZED VIEW (MONTHLY SALES SUMMARY)
DROP VIEW IF EXISTS MonthlySalesSummary;
GO

CREATE VIEW MonthlySalesSummary 
WITH SCHEMABINDING AS
SELECT 
    CONVERT(VARCHAR(7), s.sale_date, 120) AS sales_month,
    SUM(s.quantity) AS total_units_sold,
    SUM(s.total_amount) AS total_revenue,
    COUNT_BIG(*) AS count_placeholder 
FROM dbo.Sales_Table s
GROUP BY CONVERT(VARCHAR(7), s.sale_date, 120);
GO

CREATE UNIQUE CLUSTERED INDEX IX_MonthlySalesSummary 
ON MonthlySalesSummary (sales_month);
GO

-- Display Monthly Summary Results
SELECT * FROM MonthlySalesSummary;
GO


-- STORED PROCEDURE (PHONE PRICE INCREASE)

DROP PROCEDURE IF EXISTS update_product_price;
GO

CREATE PROCEDURE update_product_price
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Products_Table
    SET price = price * 1.10
    WHERE product_name = 'Phone';
END;
GO

-- Execute the procedure to apply the 10% phone price change
EXEC update_product_price;
GO

-- Display Final Updated Products Table
SELECT * FROM Products_Table;
GO
