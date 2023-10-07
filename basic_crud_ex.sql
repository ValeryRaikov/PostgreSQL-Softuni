--1
CREATE DATABASE softuni_management_db;

--2
SELECT * FROM cities
ORDER BY id ASC;

--3
SELECT
	concat("name", ' ', "state") AS "Cities Information",
	area AS "Area (km2)"
FROM 
	cities;

--4
SELECT 
	DISTINCT "name",
	area AS "Area (km2)"
FROM
	cities
	
ORDER BY "name" DESC;

--5
SELECT 
	"id" AS "ID",
	concat(first_name, ' ', last_name) AS "Full Name",
	job_title AS "Job Title"
FROM
	employees
	
ORDER BY first_name
LIMIT 50;

--6
SELECT
	id,
	concat(first_name, ' ', middle_name, ' ', last_name) AS "Full Name",
	hire_date AS "Hire Date"
FROM 
	employees
	
ORDER BY hire_date
OFFSET 9;

--7
SELECT
	id,
	concat("number", ' ', street) AS "Address",
	city_id
FROM 
	addresses
	
WHERE id >= 20;

--8
SELECT
	concat("number", ' ', street) AS "Address",
	city_id
FROM 
	addresses
	
WHERE city_id > 0 AND city_id % 2 = 0
ORDER BY city_id;

--9
SELECT
	name,
	start_date,
	end_date
FROM
	projects
	
WHERE start_date >= '2016-06-01 07:00:00' AND end_date < '2023-06-04 00:00:00'
ORDER BY start_date;

--10
SELECT
	"number",
	street
FROM
	addresses
WHERE id BETWEEN 50 AND 100 OR number < 1000;

--11
SELECT
	employee_id,
	project_id
FROM
	employees_projects
	
WHERE employee_id in (200, 250)
AND project_id NOT IN (50, 100);

--12
SELECT
	"name",
	start_date
FROM
	projects

WHERE "name" IN ('Mountain', 'Road', 'Touring')
LIMIT 20;

--13
SELECT
	concat(first_name, ' ', last_name) AS "Full Name",
	job_title,
	salary
FROM
	employees
	
WHERE salary in (12500, 14000, 23600, 25000)
ORDER BY salary DESC;

--14
SELECT
	id,
	first_name,
	last_name
FROM
	employees
WHERE middle_name is NULL
LIMIT 3;

--15
INSERT INTO departments(department, manager_id)
VALUES
	('Finance', 3),
	('Information Services', 42),
	('Document Control', 90),
	('Quality Assurance', 274),
	('Facilities and Maintenance', 218),
	('Shipping and Receiving', 85),
	('Executive', 109);

--16
CREATE TABLE IF NOT EXISTS company_chart 
AS
SELECT 
	concat(first_name, ' ', last_name) AS "Full Name",
	job_title AS "Job Title",
	department_id AS "Department ID",
	manager_id AS "Manager ID"
FROM employees;

--17
UPDATE 
	projects
SET 
	end_date = start_date + INTERVAL '5 months'
WHERE 
	end_date IS NULL;

--18
UPDATE 
	employees
SET
	salary = salary + 1500,
	job_title = 'Senior' || ' ' || job_title
	
WHERE hire_date BETWEEN '1998-01-01' AND '2000-01-05';

--19
DELETE FROM addresses
WHERE city_id IN (5, 17, 20, 30);

--20
CREATE VIEW view_company_chart AS
SELECT
	"Full Name",
	"Job Title"
FROM 
	company_chart
WHERE 
	"Manager ID" = 184;

--21
CREATE VIEW view_addresses AS
SELECT 
	concat(e.first_name, ' ', e.last_name) AS "Full Name",
	e.department_id,
	concat(a.number, ' ', a.street) AS "Address"
FROM 
	employees AS e
JOIN 
	addresses AS a
		ON 
	e.address_id = a.id
ORDER BY 
	"Address" ASC;

--22
ALTER VIEW view_addresses
RENAME TO view_employee_addresses_info;

--23
DROP VIEW view_company_chart;

--24(optional)
UPDATE
	projects
SET 	
	name = UPPER(name); 

--25(optional)
CREATE VIEW view_initials AS
SELECT
	SUBSTRING(first_name, 1, 2) AS initial,
	last_name
FROM
	employees
ORDER BY last_name;

--26(optional)
SELECT
	name,
	start_date
FROM
	projects
WHERE
	name LIKE 'MOUNT%'
ORDER BY id;