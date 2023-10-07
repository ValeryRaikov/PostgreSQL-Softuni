--1
CREATE DATABASE geography_db;

--2
CREATE VIEW view_river_info 
AS
SELECT
	concat_ws(' ', 'The river', river_name, 'flows into the', outflow, 'and is', "length", 'kilometers long.')
	AS "River Information"
FROM
	rivers
ORDER BY river_name;

--3
CREATE VIEW view_continents_countries_currencies_details 
AS
SELECT
    concat(con.continent_name, ': ', con.continent_code) AS "Continent Details",
    concat_ws(' - ', cou.country_name, cou.capital, cou.area_in_sq_km, 'km2') AS "Country Information",
    concat(description, ' (', cur.currency_code, ')') AS "Currencies"
FROM
    continents AS con,
	countries AS cou,
	currencies AS cur
WHERE
    con.continent_code = cou.continent_code
		AND
	cou.currency_code = cur.currency_code
ORDER BY
	"Country Information" ASC,
	"Currencies" ASC;

--4
ALTER TABLE countries
ADD COLUMN 
	capital_code char(2);
	
UPDATE countries
SET capital_code = LEFT(capital, 2);

--5
SELECT
	SUBSTRING(description FROM 5) AS substring
FROM
	currencies;

--6
SELECT
	(REGEXP_MATCHES("River Information", '([0-9]{1,4})'))[1] AS river_length
FROM 
	view_river_info;

--7
SELECT
	REPLACE(mountain_range, 'a', '@') AS "replace_a",
	REPLACE(mountain_range, 'A', '$') AS "replace_A"
FROM
	mountains;

--8
SELECT
	capital,
	TRANSLATE(capital, 'áãåçéíñóú', 'aaaceinou') AS translated_name
FROM
	countries;

--9
SELECT 
	continent_name,
	LTRIM(continent_name) AS "trim"
FROM
	continents;

--10
SELECT 
	continent_name,
	RTRIM(continent_name) AS "trim"
FROM
	continents;

--11
SELECT
	LTRIM(peak_name, 'M') AS "Left Trim",
	RTRIM(peak_name, 'm') AS "Right Trim"
FROM
	peaks;

--12
SELECT
	CONCAT_WS(' ', m.mountain_range, p.peak_name) AS "Mountain Information",
	LENGTH(CONCAT_WS(' ', m.mountain_range, p.peak_name)) AS "Characters Length",
	BIT_LENGTH(CONCAT_WS(' ', m.mountain_range, p.peak_name)) AS "Bits of a String"
FROM
	mountains AS m,
	peaks AS p
WHERE
	m.id = p.mountain_id;

--13
SELECT
	population,
	LENGTH(population::VARCHAR) AS "length"
FROM
	countries;

--14
SELECT
	peak_name,
	LEFT(peak_name, 4) AS "Positive Left",
	LEFT(peak_name, -4) AS "Negative Left"
FROM
	peaks;

--15
SELECT
	peak_name,
	RIGHT(peak_name, 4) AS "Positive Right",
	RIGHT(peak_name, -4) AS "Negative Right"
FROM
	peaks;

--16
UPDATE countries
SET iso_code = UPPER(SUBSTRING(country_name, 1, 3))
WHERE iso_code IS NULL;

--17
UPDATE countries
SET country_code = LOWER(REVERSE(country_code));

--18
SELECT
	CONCAT_WS(' ', elevation, CONCAT(REPEAT('-', 3), REPEAT('>', 2)), peak_name) AS "Elevation --->> Peak Name"
FROM
	peaks
WHERE
	elevation >= 4884;

--19
CREATE DATABASE booking_db;

--20
CREATE TABLE bookings_calculation
AS
SELECT
	booked_for
FROM
	bookings
WHERE apartment_id = 93;

ALTER TABLE bookings_calculation
ADD COLUMN 
	multiplication NUMERIC,
ADD COLUMN
	modulo NUMERIC;
	
UPDATE bookings_calculation
SET
	multiplication = booked_for * 50,
	modulo = booked_for % 50;

--21
SELECT
	latitude,
	ROUND(latitude, 2) AS round,
	TRUNC(latitude, 2) AS trunc
FROM
	apartments;

--22
SELECT
	longitude,
	ABS(longitude) AS "abs"
FROM
	apartments;

--23
ALTER TABLE bookings
ADD COLUMN 
	billing_day TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP;
	
SELECT
	TO_CHAR(billing_day, 'DD "Day" MM "Month" YYYY "Year" HH24:MI:SS') AS "Billing Day"
FROM
	bookings;

--24
SELECT
	EXTRACT(YEAR FROM booked_at) AS YEAR,
	EXTRACT(MONTH FROM booked_at) AS MONTH,
	EXTRACT(DAY FROM booked_at) AS DAY,
	EXTRACT(HOUR FROM booked_at AT TIME ZONE 'UTC') AS HOUR,
	EXTRACT(MINUTE FROM booked_at) AS MINUTE,
	CEIL(EXTRACT(SECOND FROM booked_at)) AS SECOND
FROM
	bookings;

--25
SELECT
	user_id,
	AGE(starts_at, booked_at) AS "Early Birds"
FROM
	bookings
WHERE
	AGE(starts_at, booked_at) >= '10 MONTHS';

--26
SELECT
	companion_full_name,
	email
FROM
	users
WHERE
	companion_full_name ILIKE '%aNd%' AND
	email NOT LIKE '%@gmail';

--27
SELECT
	LEFT(first_name, 2) AS initials,
	COUNT('initials') AS user_count
FROM
	users
GROUP BY initials
ORDER BY
	user_count DESC,
	initials ASC;

--28
SELECT 
	SUM(booked_for) AS total_value
FROM 
	bookings
WHERE 
	apartment_id = 90;

--29
SELECT
	AVG(multiplication) AS average_value
FROM
	bookings_calculation;