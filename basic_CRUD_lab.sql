--1
CREATE DATABASE hotel;

--2
SELECT
	id,
	concat(first_name, ' ', last_name) AS "Full Name", 
	job_title AS "Job Title"
FROM 
	employees;

--3
SELECT 
	id,
	concat(first_name, ' ', last_name) AS full_name,
	job_title, 
	salary
FROM
	employees
	
WHERE salary > 1000
ORDER BY id ASC;

--4
SELECT
	id, 
	first_name,
	last_name,
	job_title, 
	department_id,
	salary
FROM
	employees
	
WHERE
	department_id = 4
	AND salary >= 1000
	
ORDER BY id ASC;

--5
INSERT INTO employees(first_name, last_name, job_title, department_id, salary)

VALUES
	('Samantha', 'Young', 'Housekeeping', 4, 900),
	('Roger', 'Palmer', 'Waiter', 3, 928.33);
	
SELECT * FROM employees;

--6
UPDATE employees
SET salary = salary + 100
WHERE job_title = 'Manager';

SELECT * FROM employees
WHERE job_title = 'Manager';

--7
DELETE FROM employees 
WHERE department_id IN (1, 2);

SELECT * FROM employees
ORDER BY id;

--8
CREATE VIEW top_paid_employee_view AS 
SELECT * FROM employees
ORDER BY salary DESC
LIMIT 1;

SELECT * FROM top_paid_employee_view;