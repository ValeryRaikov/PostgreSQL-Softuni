--Personal exercise for the SoftUni course 'PostgreSQL' with data generated from Mockaroo:

--1
CREATE DATABASE test_project;

--2
SELECT
	COUNT(*) AS total_database_count
FROM
	test_project;

--3
SELECT
	MAX(salary) AS max_salary
FROM
	test_project;

--4
SELECT
	MIN(salary) AS min_salary
FROM
	test_project;

--5
SELECT
	TRUNC(AVG(salary), 2) AS avg_salary
FROM
	test_project;

--6
SELECT
	CONCAT(first_name, ' ', last_name) AS "Full Name",
	gender
FROM
	test_project
WHERE gender in ('Male', 'Female')
GROUP BY "Full Name", gender
ORDER BY "Full Name";

--7
SELECT
	gender,
	COUNT(*)
FROM
	test_project
GROUP BY gender
ORDER BY gender;

--8
SELECT
	COUNT(*) AS current_employees_count
FROM
	test_project
WHERE end_date IS NOT NULL;

--9
SELECT
	CONCAT(first_name, ' ', last_name) AS "Full Name",
	gender,
	CASE
		WHEN email LIKE '%.com' THEN '.com User'
		WHEN email LIKE '%.org' THEN '.org User'
		WHEN email LIKE '%.net' THEN '.net User'
		ELSE 'Other User'
	END AS email_info
FROM
	test_project
WHERE AGE(end_date, start_date) > '6months' OR end_date IS NULL
ORDER BY "Full Name";

--10
SELECT
	gender,
	SUM(salary) AS "Total Salary"
FROM
	test_project
GROUP BY gender
ORDER BY gender;

--11
SELECT
	gender,
	COUNT(email) AS ".com Users"
FROM
	test_project
WHERE email LIKE '%.com'
GROUP BY gender

ORDER BY gender;

--12
SELECT
	COUNT(DISTINCT gender) AS number_of_genders
FROM
	test_project;

--13
ALTER TABLE test_project
ADD COLUMN status VARCHAR(20);

--14
UPDATE test_project
SET status = 'Fired...'
WHERE end_date IS NULL

UPDATE test_project
SET status = 'Still working'
WHERE end_date IS NOT NULL;

--15
CREATE VIEW test_project_view_salary AS 
SELECT
	status,
	SUM(salary) AS "Current total salary"
FROM
	test_project
WHERE status = 'Still working'
GROUP BY status;

CREATE VIEW test_project_view AS 
SELECT
	status,
	SUM(salary) AS "Current total salary"
FROM
	test_project
WHERE status = 'Still working'
GROUP BY status
LIMIT 100;

--16
DROP DATABASE test_project WITH (FORCE);