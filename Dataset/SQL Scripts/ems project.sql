--                                                  SQL PROJECT 

--                                              EMPLOYEE MANAGEMENT SYSTEM 

-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- The Employee Management System (EMS) is designed to streamline the management of employee data,job roles, and departmental information within an organization. This system allows for efficient tracking of employee details, job assignments, qualifications, and performance metrics. Key domain knowledge elements for this system include:

-- 1. Employee Information Management: The system stores personal details of employees such as name, contact information, gender, and unique login credentials. It is crucial for ensuring secure access and easy retrieval of employee records.
-- 2. Job Role Assignment: Each employee is associated with a specific job role, which is linked to the department they work in. This connection ensures that employees are correctly aligned with their job functions and responsibilities within the organization.
-- 3. Departmental Structure: The organization is divided into various departments (e.g., HR, Finance, IT), each with distinct job roles. The system should manage these departments and the employees assigned to each role efficiently.
-- 4. Payroll and Compensation: Employee compensation details, including salary and bonuses, are stored in the system. Payroll processing and salary allocations are automatically calculated based on the job roles and associated salary ranges.
-- 5. Qualifications and Skills Tracking: The system tracks employee qualifications, certifications, and skills to ensure that employees meet the requirements for their roles and identify opportunities for professional development.
-- 6. Leave and Absence Management: The system manages employee leave records, including vacation days, sick leaves, and other types of absences, with appropriate deductions applied to payroll based on the employee’s leave history.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- ========================================================================================================
-- CREATION OF DATABASE 
-- ========================================================================================================

CREATE DATABASE ems; 

USE ems;

-- ===========================================================================================================
-- Table Structure 
-- ===========================================================================================================

-- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);
SELECT * FROM JobDepartment;

-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
SELECT * FROM SalaryBonus;

-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

SELECT * FROM Employee;

-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

SELECT * FROM Qualification;


-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

SELECT * FROM Leaves;

-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);


-- ===============================================
-- Analysis Questions
-- ===============================================

-- -----------------------------------------------------------
-- 1. EMPLOYEE INSIGHTS
-- -------------------------------------------------------------
## How many unique employees are currently in the system?
SELECT COUNT(DISTINCT emp_ID) AS total_employee FROM Employee;

## Which departments have the highest number of employees?
SELECT 
    jd.jobdept,
    COUNT(e.emp_ID) AS employee_count
FROM JobDepartment jd
JOIN Employee e
    ON jd.Job_ID = e.Job_ID
GROUP BY jd.jobdept
ORDER BY employee_count DESC;

## What is the average salary per department?
SELECT jd.jobdept , AVG(sb.amount) AS avg_salary 
FROM JobDepartment jd 
JOIN salarybonus sb 
ON jd.job_ID = sb.job_ID 
GROUP BY jd.jobdept ;

## Who are the top 5 highest-paid employees?
SELECT e.emp_ID , e.firstname , e.lastname , sb.amount 
FROM Employee e 
JOIN salarybonus sb 
ON e.job_ID = sb.job_ID 
ORDER BY sb.amount DESC 
LIMIT 5;


## What is the total salary expenditure across the company?
SELECT SUM(sb.annual + sb.bonus) as salary_expenditure 
FROM  Employee e
JOIN SalaryBonus sb
ON e.job_id = sb.job_id;

-- ------------------------------------------------------------------------------------------------
-- 2. JOB ROLE AND DEPARTMENT ANALYSIS
-- -----------------------------------------------------------------------------------------------

## How many different job roles exist in each department?
SELECT jobdept ,COUNT(*) as job_roles FROM JobDepartment GROUP BY jobdept;

## What is the average salary range per department?
SELECT
    jd.jobdept,
    MIN(sb.amount) AS min_salary,
    MAX(sb.amount) AS max_salary,
    (MIN(sb.amount) + MAX(sb.amount)) / 2 AS avg_salary_range
FROM JobDepartment jd
JOIN SalaryBonus sb
    ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept;

## Which job roles offer the highest salary?
SELECT
    jd.name,
    sb.amount
FROM JobDepartment jd
JOIN SalaryBonus sb
    ON jd.Job_ID = sb.Job_ID
WHERE sb.amount = (
    SELECT MAX(amount)
    FROM SalaryBonus
);


## Which departments have the highest total salary allocation?
SELECT
    jd.jobdept,
    SUM(sb.amount) AS total_salary_allocation
FROM Employee e
JOIN JobDepartment jd
    ON e.Job_ID = jd.Job_ID
JOIN SalaryBonus sb
    ON e.Job_ID = sb.Job_ID
GROUP BY jd.jobdept
ORDER BY total_salary_allocation DESC
LIMIT 1;

-- ------------------------------------------------------------------------------
-- 3. QUALIFICATION AND SKILLS ANALYSIS
-- ------------------------------------------------------------------------------


## How many employees have at least one qualification listed?
SELECT COUNT(DISTINCT e.emp_ID) AS employees_with_qualifications
FROM Employee e
JOIN Qualification q
    ON e.emp_ID = q.Emp_ID;
    
## Which positions require the most qualifications?
SELECT
    Position,
    COUNT(*) AS qualification_count
FROM Qualification
GROUP BY Position
ORDER BY qualification_count DESC;

## Which employees have the highest number of qualifications?
SELECT
    e.emp_ID,
    e.firstname,
    e.lastname,
    COUNT(q.QualID) AS total_qualifications
FROM Employee e
JOIN Qualification q
    ON e.emp_ID = q.Emp_ID
GROUP BY e.emp_ID, e.firstname, e.lastname
ORDER BY total_qualifications DESC;
    
-- ----------------------------------------------------------------------------
-- 4. LEAVE AND ABSENCE PATTERNS
-- ----------------------------------------------------------------------------

## Which year had the most employees taking leaves?
SELECT
    YEAR(date) AS leave_year,
    COUNT(DISTINCT emp_ID) AS employees_on_leave
FROM Leaves
GROUP BY YEAR(date)
ORDER BY employees_on_leave DESC
LIMIT 1;

## What is the average number of leave days taken by its employees per department?
SELECT
    jd.jobdept,
    COUNT(l.leave_ID) * 1.0 / COUNT(DISTINCT e.emp_ID) AS avg_leaves_per_employee
FROM Employee e
JOIN JobDepartment jd
    ON e.Job_ID = jd.Job_ID
LEFT JOIN Leaves l
    ON e.emp_ID = l.emp_ID
GROUP BY jd.jobdept;

## Which employees have taken the most leaves?
SELECT e.emp_id,e.firstname,e.lastname,COUNT(l.leave_ID)
FROM employee e
JOIN leaves l 
ON e.emp_id = l.emp_id
GROUP BY e.emp_ID, e.firstname, e.lastname;

SELECT
    e.emp_ID,
    e.firstname,
    e.lastname,
    COUNT(l.leave_ID) AS total_leaves
FROM Employee e
JOIN Leaves l
    ON e.emp_ID = l.emp_ID
GROUP BY e.emp_ID, e.firstname, e.lastname
ORDER BY total_leaves DESC
LIMIT 1;

## What is the total number of leave days taken company-wide?
SELECT COUNT(*) AS total_leave_records
FROM Leaves;

## How do leave days correlate with payroll amounts?
SELECT
    e.emp_ID,
    e.firstname,
    e.lastname,
    COUNT(l.leave_ID) AS total_leaves,
    AVG(p.total_amount) AS avg_payroll
FROM Employee e
LEFT JOIN Leaves l
    ON e.emp_ID = l.emp_ID
LEFT JOIN Payroll p
    ON e.emp_ID = p.emp_ID
GROUP BY e.emp_ID, e.firstname, e.lastname;

-- -----------------------------------------------------------
-- 5. PAYROLL AND COMPENSATION ANALYSIS
-- ------------------------------------------------------------

## What is the total monthly payroll processed?
SELECT
YEAR(date) AS payroll_year,
MONTH(date) AS payroll_month,
SUM(total_amount) AS total_monthly_payroll
FROM Payroll
GROUP BY YEAR(date), MONTH(date)
ORDER BY payroll_year, payroll_month;

## What is the average bonus given per department?
SELECT jd.jobdept,AVG(sb.bonus) AS avg_bonus
FROM JobDepartment jd
JOIN SalaryBonus sb
ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept;

## Which department receives the highest total bonuses?
SELECT jd.jobdept, SUM(sb.bonus) AS total_bonus
FROM JobDepartment jd
JOIN SalaryBonus sb
ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept
ORDER BY total_bonus DESC;

## What is the average value of total_amount after considering leave deductions?
SELECT AVG(total_amount) AS avg_payroll_after_deductions
FROM Payroll;

