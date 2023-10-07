--1
CREATE DATABASE subqueries_joins_booking_db;

--2
SELECT 
	concat(a.address, ' ', a.address_2) AS apartment_address,
	b.booked_for AS nights
FROM 
	apartments AS a JOIN
	bookings AS b 
		USING(booking_id)
ORDER BY a.apartment_id;

--3
SELECT 
	a.name,
	a.country,
	b.booked_at::DATE
FROM 
	apartments AS a LEFT JOIN
	bookings AS b 
		USING(booking_id)
LIMIT 10;

--4
SELECT
	b.booking_id,
	b.starts_at::DATE,
	b.apartment_id,
	concat(c.first_name, ' ', c.last_name) as customer_name
FROM
	bookings AS b RIGHT JOIN
	customers AS c 
		USING(customer_id)
ORDER BY customer_name
LIMIT 10;

--5
SELECT
	b.booking_id,
	a.name AS apartment_owner,
	a.apartment_id,
	concat(c.first_name, ' ', c.last_name) AS customer_name
FROM
	apartments AS a 
		FULL JOIN
	bookings AS b
		USING(booking_id)
		FULL JOIN
	customers AS c
		USING(customer_id)	
ORDER BY
	b.booking_id,
	apartment_owner,
	customer_name;

--6
SELECT
	b.booking_id,
	c.first_name AS customer_name
FROM
	bookings AS b 
		CROSS JOIN 
	customers AS c
ORDER BY customer_name;

--7
SELECT
	b.booking_id,
	b.apartment_id,
	c.companion_full_name
FROM
	bookings AS b JOIN
	customers AS c
		USING(customer_id)
WHERE b.apartment_id IS NULL;

--8
SELECT
	b.apartment_id,
	b.booked_for,
	c.first_name,
	c.country
FROM
	bookings AS b JOIN
	customers AS c
		USING(customer_id)
WHERE c.job_type = 'Lead';

--9
SELECT
	COUNT(confirmed)
FROM 
	bookings JOIN
	customers 
	USING(customer_id)
WHERE customers.last_name = 'Hahn';

--10
SELECT
	a.name,
	SUM(b.booked_for)
FROM
	apartments AS a JOIN
	bookings AS b
		USING(apartment_id)
GROUP BY name
ORDER BY name;

--11
SELECT
	a.country,
	COUNT(b.booking_id) AS booking_count
FROM
	apartments AS a JOIN
	bookings AS b 
		USING(apartment_id)
WHERE b.booked_at > '2021-05-18 07:52:09.904+03' AND b.booked_at < '2021-09-17 19:48:02.147+03'
GROUP BY country
ORDER BY booking_count DESC;

--Next database tasks:

--12
CREATE DATABASE subqueries_joins_geography_db;

--13
SELECT
	mc.country_code,
	m.mountain_range,
	p.peak_name,
	p.elevation
FROM
	mountains_countries AS mc JOIN
	mountains AS m ON
		mc.mountain_id = m.id
	JOIN
	peaks AS p ON
		m.id = p.mountain_id
WHERE 
	p.elevation > 2835 
	AND
	mc.country_code = 'BG'
ORDER BY p.elevation DESC;

--14
SELECT
	mc.country_code,
	COUNT(m.mountain_range) AS mountain_range_count
FROM
	mountains_countries AS mc JOIN
	mountains AS m ON
		mc.mountain_id = m.id
WHERE mc.country_code in ('US', 'RU', 'BG')
GROUP BY mc.country_code
ORDER BY mountain_range_count DESC;

--15
SELECT
	c.country_name,
	r.river_name
FROM
	countries AS c LEFT JOIN
	countries_rivers AS cr
		USING(country_code)
		LEFT JOIN
		rivers AS r ON
		r.id = cr.river_id
WHERE c.continent_code = 'AF'
ORDER BY c.country_name
LIMIT 5;

--16
SELECT 
	MIN(average) AS min_average_area
FROM 
(
	SELECT
		AVG(area_in_sq_km) AS average
	FROM 
		countries
	GROUP BY 
		continent_code
) AS average_area;

--17
SELECT
	COUNT(*) AS countries_without_mountains
FROM
	countries AS c LEFT JOIN
	mountains_countries AS mc
		USING(country_code)
WHERE mc.mountain_id IS NULL;

--18
CREATE TABLE IF NOT EXISTS monasteries(
	id SERIAL PRIMARY KEY,
	monastery_name VARCHAR(255),
	country_code CHAR(2)
);

INSERT INTO monasteries(monastery_name, country_code)
VALUES 
  ('Rila Monastery "St. Ivan of Rila"', 'BG'),
  ('Bachkovo Monastery "Virgin Mary"', 'BG'),
  ('Troyan Monastery "Holy Mother''s Assumption"', 'BG'),
  ('Kopan Monastery', 'NP'),
  ('Thrangu Tashi Yangtse Monastery', 'NP'),
  ('Shechen Tennyi Dargyeling Monastery', 'NP'),
  ('Benchen Monastery', 'NP'),
  ('Southern Shaolin Monastery', 'CN'),
  ('Dabei Monastery', 'CN'),
  ('Wa Sau Toi', 'CN'),
  ('Lhunshigyia Monastery', 'CN'),
  ('Rakya Monastery', 'CN'),
  ('Monasteries of Meteora', 'GR'),
  ('The Holy Monastery of Stavronikita', 'GR'),
  ('Taung Kalat Monastery', 'MM'),
  ('Pa-Auk Forest Monastery', 'MM'),
  ('Taktsang Palphug Monastery', 'BT'),
  ('Sümela Monastery', 'TR');
  
ALTER TABLE countries
ADD COLUMN three_rivers BOOL DEFAULT FALSE;

UPDATE countries
SET three_rivers = 
(
	SELECT 
		COUNT(*) >= 3
	FROM 
		countries_rivers AS cr
	WHERE 
		cr.country_code = countries.country_code
);

SELECT
	m.monastery_name,
	c.country_name
FROM 
	monasteries AS m JOIN
	countries AS c
		USING(country_code)
WHERE NOT c.three_rivers
ORDER BY monastery_name;

--19
UPDATE countries
SET country_name = 'Burma'
WHERE country_name = 'Myanmar';

INSERT INTO monasteries(monastery_name, country_code)
VALUES 
	('Hanga Abbey', 'TZ'),
	('Myin-Tin-Daik', 'MM');

SELECT
	con.continent_name,
	cou.country_name,
	COUNT(*) AS monasteries_count
FROM
	continents AS con LEFT JOIN
	countries AS cou
		USING(continent_code)
		LEFT JOIN
	monasteries AS m
			USING(country_code)
WHERE NOT cou.three_rivers
GROUP BY 
	continent_name,
	country_name
ORDER BY 
	monasteries_count DESC,
	country_name;

--20
CREATE VIEW continent_currency_usage AS
WITH CurrencyCounts AS (
    SELECT
        continent_code,
        currency_code,
        COUNT(*) AS currency_usage
    FROM countries
    GROUP BY continent_code, currency_code
    HAVING COUNT(*) > 1
),
RankedCurrencyCounts AS (
    SELECT
        continent_code,
        currency_code,
        currency_usage,
        DENSE_RANK() OVER (PARTITION BY continent_code ORDER BY currency_usage DESC) AS rank
    FROM CurrencyCounts
)
SELECT
    continent_code,
    currency_code,
    currency_usage
FROM RankedCurrencyCounts
WHERE rank = 1
ORDER BY currency_usage DESC;

--21
WITH row_number AS (
 	SELECT
    c.country_name,
    p.peak_name AS highest_peak_name,
    p.elevation AS highest_peak_elevation,
    m.mountain_range,
    ROW_NUMBER() OVER (PARTITION BY c.country_name ORDER BY p.elevation DESC) AS peak_rank
FROM
    countries AS c LEFT JOIN 
	mountains_countries AS mc ON 
		c.country_code = mc.country_code
    LEFT JOIN 
	peaks AS p ON 
		mc.mountain_id = p.mountain_id
    LEFT JOIN 
	mountains AS m ON 
		p.mountain_id = m.id
)

SELECT
  	country_name,
  	COALESCE(highest_peak_name, '(no highest peak)') AS highest_peak_name,
  	COALESCE(highest_peak_elevation, 0) AS highest_peak_elevation,
  	COALESCE(mountain_range, '(no mountain)') AS mountain
FROM
  	row_number
WHERE peak_rank = 1
ORDER BY country_name, highest_peak_elevation DESC;