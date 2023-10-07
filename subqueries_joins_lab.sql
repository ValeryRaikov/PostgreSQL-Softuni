--1
CREATE DATABASE soft_uni;

--2
SELECT 
	t.town_id,
	t.name AS town_name,
	a.address_text
FROM 
	towns AS t JOIN
	addresses AS a ON
		t.town_id = a.town_id
WHERE t.name IN ('San Francisco', 'Sofia', 'Carnation')
ORDER BY 
	town_id, 
	a.address_id;

--3
SELECT 
	e.employee_id,
	concat(e.first_name, ' ', e.last_name) AS full_name,
	d.department_id,
	d.name AS department_name
FROM 
	employees AS e JOIN
	departments AS d ON
		e.employee_id = d.manager_id
ORDER BY employee_id
LIMIT 5;

--4
SELECT
	e.employee_id,
	CONCAT(e.first_name, ' ', e.last_name) AS full_name,
	p.project_id,
	p.name AS project_name
FROM
	employees AS e JOIN
	employees_projects AS ep 
		USING(employee_id) JOIN
		projects AS p
			USING(project_id)
WHERE project_id = 1;

--5
SELECT
	COUNT(salary)
FROM
	employees
WHERE
	salary > (SELECT AVG(salary) FROM employees);
