CREATE DATABASE EmployeeDB;
USE EmployeeDB;
CREATE TABLE DEPARTMENTS (
    DEPARTMENT_ID INT PRIMARY KEY,
    DEPARTMENT_NAME VARCHAR(50) NOT NULL
);

CREATE TABLE EMPLOYEES (
    EMPLOYEE_ID INT PRIMARY KEY,
    FIRST_NAME VARCHAR(50) NOT NULL,
    LAST_NAME VARCHAR(50) NOT NULL,
    EMAIL VARCHAR(100) NOT NULL,
    PHONE_NO VARCHAR(20) NOT NULL,
    DEPARTMENT_ID INT,
    FOREIGN KEY (DEPARTMENT_ID) REFERENCES DEPARTMENTS(DEPARTMENT_ID)
);

INSERT INTO DEPARTMENTS (DEPARTMENT_ID, DEPARTMENT_NAME) VALUES
(1, 'Human Resources'),
(2, 'Engineering'),
(3, 'Marketing'),
(4, 'Finance');

INSERT INTO EMPLOYEES (EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE_NO, DEPARTMENT_ID) VALUES
(1, 'John', 'Wick', 'john.wick@gmail.com', '12345667', 2),
(2, 'Marcus', 'Yee', 'marcus.yee@gmail.com', '26876458', 3),
(3, 'Superb', 'Lex', 'superb.lex@gmail.com', '86876850', 2),
(4, 'Any', 'One', 'anyone.me@gmail.com', '6876558', 1),
(5, 'Khan', 'Mohmmad', 'mohammadkhan@gmail.com', '979697669', 4);

--selecting the data from the employees table & Department Table 
SELECT * FROM EMPLOYEES;
SELECT * FROM DEPARTMENTS;

--selecting the specific colums name
SELECT first_name, last_name from Employees;

--conunt the no of employees
select count (*) as number_of_employees from Employees;

--find the maximum Employee ID
select max(EMPLOYEE_ID) as max_employees_ID from Employees;

-- find the minimimun employee id
select min(EMPLOYEE_ID) as min_employee from Employees;

--calculating the average lenghth of the phone number
select avg(LEN(PHONE_NO)) as AVG_phone_no_length from Employees;

-- selecting the employyes with email address of gmail
select * from Employees where EMAIL like '%@gmail.com';

-- Employees with the first name starts with J
select * from employees where first_name like 'j%';

-- Employes with the last name starts with e
select * from employees where last_name like '%e';

--order employees by first name in ascending order
select * from Employees order by FIRST_NAME asc;

--order employees by last name in descending order
select * from Employees order by LAST_NAME desc; 

--update the email of an employee
update Employees set EMAIL = 'john.newWick@gmail.com' where EMPLOYEE_ID = 1;

--Join EMPLOYEES and DEPARTMENTS:
SELECT E.EMPLOYEE_ID, E.FIRST_NAME, E.LAST_NAME, D.DEPARTMENT_NAME
FROM EMPLOYEES E
JOIN DEPARTMENTS D ON E.DEPARTMENT_ID = D.DEPARTMENT_ID;

--SELECT FIRST_NAME, LAST_NAME, EMAIL
SELECT FIRST_NAME, LAST_NAME, EMAIL
FROM EMPLOYEES
WHERE DEPARTMENT_ID = 2;

-- Add a new department
INSERT INTO DEPARTMENTS (DEPARTMENT_ID, DEPARTMENT_NAME) VALUES (5, 'IT Support');

-- Add a new employee to the new department
INSERT INTO EMPLOYEES (EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE_NO, DEPARTMENT_ID)
VALUES (6, 'Alice', 'Wonder', 'alice.wonder@gmail.com', '12309876', 5);

--Find Employees in a Specific Department:
SELECT FIRST_NAME, LAST_NAME, EMAIL
FROM EMPLOYEES
WHERE DEPARTMENT_ID = 2;

--Count the Number of Employees in Each Department:
SELECT D.DEPARTMENT_NAME, COUNT(E.EMPLOYEE_ID) AS NUMBER_OF_EMPLOYEES
FROM DEPARTMENTS D
LEFT JOIN EMPLOYEES E ON D.DEPARTMENT_ID = E.DEPARTMENT_ID
GROUP BY D.DEPARTMENT_NAME;

--List Departments Without Employees:
SELECT D.DEPARTMENT_NAME
FROM DEPARTMENTS D
LEFT JOIN EMPLOYEES E ON D.DEPARTMENT_ID = E.DEPARTMENT_ID
WHERE E.EMPLOYEE_ID IS NULL;

--Departments with More Than One Employee:
SELECT D.DEPARTMENT_NAME
FROM DEPARTMENTS D
JOIN EMPLOYEES E ON D.DEPARTMENT_ID = E.DEPARTMENT_ID
GROUP BY D.DEPARTMENT_NAME
HAVING COUNT(E.EMPLOYEE_ID) > 1;

-- Trigger to Automatically Update a Timestamp on Employee Update

ALTER TABLE EMPLOYEES
ADD LAST_MODIFIED DATETIME DEFAULT GETDATE();

CREATE TRIGGER trg_employee_update
ON EMPLOYEES
AFTER UPDATE
AS
BEGIN
    UPDATE EMPLOYEES
    SET LAST_MODIFIED = GETDATE()
    WHERE EMPLOYEE_ID IN (SELECT DISTINCT EMPLOYEE_ID FROM INSERTED);
END;

--Trigger to Prevent Inserting Duplicate Email Addresses

CREATE TRIGGER trg_prevent_duplicate_email
ON EMPLOYEES
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM EMPLOYEES WHERE EMAIL IN (SELECT EMAIL FROM INSERTED))
    BEGIN
        RAISERROR('Duplicate email address not allowed.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO EMPLOYEES (EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE_NO, DEPARTMENT_ID, LAST_MODIFIED)
        SELECT EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE_NO, DEPARTMENT_ID, GETDATE()
        FROM INSERTED;
    END
END;

--Trigger to Set Default Values on Insert

CREATE TRIGGER trg_set_defaultsz
ON EMPLOYEES
INSTEAD OF INSERT
AS
BEGIN
    INSERT INTO EMPLOYEES (EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE_NO, DEPARTMENT_ID)
    SELECT 
        EMPLOYEE_ID,
        ISNULL(FIRST_NAME, 'Unknown'), 
        ISNULL(LAST_NAME, 'Unknown'),  
        ISNULL(EMAIL, 'NoEmail@domain.com'), 
        ISNULL(PHONE_NO, '000-000-0000'), 
        ISNULL(DEPARTMENT_ID, 1) 
    FROM INSERTED;
END;

--Trigger to Prevent Deleting Specific Records
CREATE TRIGGER trg_prevent_deletion_of_management
ON EMPLOYEES
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM DELETED WHERE DEPARTMENT_ID = (SELECT DEPARTMENT_ID FROM DEPARTMENTS WHERE DEPARTMENT_NAME = 'Management'))
    BEGIN
        RAISERROR('Employees in the Management department cannot be deleted.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        DELETE FROM EMPLOYEES WHERE EMPLOYEE_ID IN (SELECT EMPLOYEE_ID FROM DELETED);
    END
END;



--Procedure to Get All Employees
CREATE PROCEDURE GetAllEmployees
as begin 
select * from EMPLOYEES;
End;

EXEC GetAllEmployees;

--Procedure to Insert a New Employee
CREATE PROCEDURE InsertEmployee
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @Email VARCHAR(100),
    @PhoneNo VARCHAR(20),
    @DepartmentID INT
AS
BEGIN
    INSERT INTO EMPLOYEES (FIRST_NAME, LAST_NAME, EMAIL, PHONE_NO, DEPARTMENT_ID)
    VALUES (@FirstName, @LastName, @Email, @PhoneNo, @DepartmentID);
END;

EXEC InsertEmployee 'Jane', 'Doe', 'jane.doe@example.com', '123-456-7890', 1;

--Procedure to Update Employee's Department

CREATE PROCEDURE UpdateEmployeeDepartment
    @EmployeeID INT,
    @NewDepartmentID INT
AS
BEGIN
    UPDATE EMPLOYEES
    SET DEPARTMENT_ID = @NewDepartmentID
    WHERE EMPLOYEE_ID = @EmployeeID;
END;

EXEC UpdateEmployeeDepartment 1, 2;

--Procedure to Delete an Employee

CREATE PROCEDURE DeleteEmployee
    @EmployeeID INT
AS
BEGIN
    DELETE FROM EMPLOYEES
    WHERE EMPLOYEE_ID = @EmployeeID;
END;
EXEC DeleteEmployee 1;





