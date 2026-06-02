
-- 1. Create the single table for 1NF
CREATE TABLE Employee_1NF (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100) NOT NULL,
    department VARCHAR(50) NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    department_location VARCHAR(100) NOT NULL,
    manager_id INT NOT NULL
);

-- 2. Insert the atomic, unique records
INSERT INTO Employee_1NF (emp_id, emp_name, department, salary, department_location, manager_id) VALUES
(101, 'Umar Adamu', 'HR', 50000.00, 'Lokoja', 201),
(102, 'Jane Abu', 'IT', 60000.00, 'Cross River', 202),
(103, 'Caroline Agu', 'Finance', 55000.00, 'Sokoto', 203),
(104, 'Shehu Umar', 'Logistics', 48000.00, 'Zamfara', 204),
(105, 'Mohammed Bello', 'Procurement', 53000.00, 'Jigawa', 205),
(106, 'Frank Ewu', 'IT', 62000.00, 'Delta', 202);


-- Creating the 2NF Table

CREATE TABLE Employee_2NF (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100) NOT NULL,
    department VARCHAR(50) NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    department_location VARCHAR(100) NOT NULL,
    manager_id INT NOT NULL
);

-- Create the Departments table for 3NF
CREATE TABLE Departments_3NF (
    department VARCHAR(50) PRIMARY KEY,
    department_location VARCHAR(100) NOT NULL,
    manager_id INT NOT NULL
);

-- Create the Employees table referencing the Departments table
CREATE TABLE Employees_3NF (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100) NOT NULL,
    department VARCHAR(50),
    salary DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (department) REFERENCES Departments_3NF(department)
);

-- Update salaries for the IT department by multiplying by 1.10
UPDATE Employees_3NF
SET salary = salary * 1.10
WHERE department = 'IT';
