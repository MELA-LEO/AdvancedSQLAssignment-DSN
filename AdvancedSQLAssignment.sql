USE AdvancedSQLAssignment;

 -- Create the CTE
WITH CustomerSpending AS (
    SELECT 
        CustomerName,
        SUM(Quantity * Price) AS TotalSpent
    FROM 
        Order_table 
    GROUP BY 
        CustomerName
)
-- Select from the CTE
SELECT 
    CustomerName, 
    TotalSpent
FROM 
    CustomerSpending
ORDER BY 
    TotalSpent DESC;

--Analyzing the total revenue

SELECT 
    State,
    Product,
    SUM(Quantity * Price) AS TotalRevenue
FROM 
    Order_table
GROUP BY 
    ROLLUP (State, Product);

--Extract the year and month

SELECT 
    YEAR(OrderDate) AS OrderYear,
    MONTH(OrderDate) AS OrderMonth    
FROM 
    Order_table;
