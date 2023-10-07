--1
CREATE DATABASE book_library;

--2
SELECT
	title
FROM
	books
WHERE 
	SUBSTRING(title, 1, 3) = 'The'
ORDER BY id;

--3
SELECT
	REPLACE(title, 'The', '***')
FROM
	books
WHERE LEFT(title, 3) = 'The'
ORDER BY id;

--4
SELECT 
	id,
	side * height / 2 AS area
FROM
	triangles
ORDER BY id;

--5
SELECT
	title,
	round(cost, 3) AS modified_price
FROM
	books
ORDER BY id;

--6
SELECT
	first_name,
	last_name,
	EXTRACT('year' from born)
FROM
	authors;

--7
SELECT
	last_name AS "Last Name",
	to_char(born, 'DD (Dy) Mon YYYY') AS "Date of Birth"
FROM
	authors;

--8
SELECT
	title
FROM
	books
WHERE title LIKE 'Harry Potter%'
ORDER BY id;