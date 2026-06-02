
-- STEP 1: CREATE A FRESH DATABASE AND BUILD TABLES

USE [SQL_DataAnalysis&Automation];
GO

-- Create Customers Table
CREATE TABLE CustomersTable (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(15) CHECK (Phone NOT LIKE '%[^0-9]%' AND LEN(Phone) BETWEEN 10 AND 15)
);

-- Create Products Table
CREATE TABLE ProductsTable (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Price DECIMAL(10, 2) CHECK (Price > 0),
    StockQuantity INT CHECK (StockQuantity >= 0)
);

-- Create Orders Table
CREATE TABLE OrdersTable (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES CustomersTable(CustomerID),
    OrderDate DATE NOT NULL,
    TotalAmount DECIMAL(10, 2) CHECK (TotalAmount > 0)
);

-- Create OrderDetails Table
CREATE TABLE OrderDetailsTable (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT FOREIGN KEY REFERENCES OrdersTable(OrderID) ON DELETE CASCADE,
    ProductID INT FOREIGN KEY REFERENCES ProductsTable(ProductID),
    Quantity INT CHECK (Quantity > 0),
    Subtotal DECIMAL(10, 2) CHECK (Subtotal >= 0)
);
GO

-- Populate Initial Sample Data
INSERT INTO CustomersTable (FirstName, LastName, Email, Phone) 
VALUES ('John', 'Doe', 'john.doe@email.com', '08012345678');

INSERT INTO ProductsTable (ProductName, Price, StockQuantity) 
VALUES ('Phone', 150000.00, 5),   -- ProductID 1 (In Stock)
       ('Laptop', 350000.00, 0);  -- ProductID 2 (Out of Stock)
GO


-- STEP 2: TRANSACTION HANDLING (PURCHASE PROCESS)

-- Test case: Trying to buy 2 Phones (Product ID 1, which has 5 in stock)
DECLARE @TargetCustomerID INT = 1;
DECLARE @TargetProductID INT = 1; 
DECLARE @OrderQty INT = 2;
DECLARE @UnitPrice DECIMAL(10,2) = 150000.00;
DECLARE @AvailableStock INT;

BEGIN TRANSACTION;
BEGIN TRY
    -- 1. Fetch stock level
    SELECT @AvailableStock = StockQuantity FROM ProductsTable WHERE ProductID = @TargetProductID;

    -- 2. Check if product is out of stock / insufficient
    IF @AvailableStock IS NULL OR @AvailableStock < @OrderQty
    BEGIN
        THROW 50001, 'Transaction Aborted: Product is out of stock or insufficient quantities remain.', 1;
    END

    -- 3. Deduct stock quantity
    UPDATE ProductsTable
    SET StockQuantity = StockQuantity - @OrderQty
    WHERE ProductID = @TargetProductID;

    -- 4. Create record in OrdersTable
    DECLARE @GeneratedOrderID INT;
    INSERT INTO OrdersTable (CustomerID, OrderDate, TotalAmount)
    VALUES (@TargetCustomerID, GETDATE(), (@UnitPrice * @OrderQty));
    SET @GeneratedOrderID = SCOPE_IDENTITY();

    -- 5. Create record in OrderDetailsTable
    INSERT INTO OrderDetailsTable (OrderID, ProductID, Quantity, Subtotal)
    VALUES (@GeneratedOrderID, @TargetProductID, @OrderQty, (@UnitPrice * @OrderQty));

    COMMIT TRANSACTION;
    PRINT 'SUCCESS: Order placed and stock deducted cleanly!';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT ERROR_MESSAGE();
END CATCH;
GO



-- STEP 3: RANGE PARTITIONING BASED ON ORDER DATE
-- Create partition function (Splits orders before and after 2023)
CREATE PARTITION FUNCTION OrderDatePF (DATE)
AS RANGE RIGHT FOR VALUES ('2023-01-01');
GO

-- Create partition scheme mapping to standard PRIMARY storage group
CREATE PARTITION SCHEME OrderDatePS
AS PARTITION OrderDatePF TO ([PRIMARY], [PRIMARY]);
GO

-- Create the partitioned layout version of the Orders table
CREATE TABLE PartitionedOrdersTable (
    OrderID INT IDENTITY(1,1),
    CustomerID INT,
    OrderDate DATE NOT NULL,
    TotalAmount DECIMAL(10,2),
    CONSTRAINT PK_PartitionedOrders PRIMARY KEY CLUSTERED (OrderID, OrderDate)
) ON OrderDatePS(OrderDate);
GO

-- STEP 4: VERIFY RECOVERED RESULTS

SELECT * FROM CustomersTable;
SELECT * FROM ProductsTable; -- Notice StockQuantity dropped from 5 to 3
SELECT * FROM OrdersTable;
SELECT * FROM OrderDetailsTable;
GO
