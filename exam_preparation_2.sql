-- DDL
CREATE DATABASE taxi_company_db;

DROP TABLE IF EXISTS addresses CASCADE;
CREATE TABLE addresses(
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

DROP TABLE IF EXISTS categories CASCADE;
CREATE TABLE categories(
    id SERIAL PRIMARY KEY,
    name VARCHAR(10) NOT NULL
);

DROP TABLE IF EXISTS clients CASCADE;
CREATE TABLE clients(
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20) NOT NULL
);

DROP TABLE IF EXISTS drivers CASCADE;
CREATE TABLE drivers(
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    age INT NOT NULL,
    rating NUMERIC (3, 2) DEFAULT 5.5,
    CONSTRAINT drivers_age_check CHECK (age > 0)
);

DROP TABLE IF EXISTS cars CASCADE;
CREATE TABLE cars(
    id SERIAL PRIMARY KEY,
    make VARCHAR(20) NOT NULL,
    model VARCHAR(20),
    year INT DEFAULT 0 NOT NULL ,
    mileage INT DEFAULT 0,
    condition CHAR(1) NOT NULL,
    category_id INT NOT NULL,
    CONSTRAINT cars_year_check CHECK (year > 0),
    CONSTRAINT cars_mileage_check CHECK (mileage > 0),
    CONSTRAINT fk_cars_categories
        FOREIGN KEY (category_id)
            REFERENCES categories(id)
                ON UPDATE CASCADE
                ON DELETE CASCADE
);

DROP TABLE IF EXISTS courses CASCADE;
CREATE TABLE courses(
    id SERIAL PRIMARY KEY,
    from_address_id INT NOT NULL,
    start TIMESTAMP NOT NULL,
    bill NUMERIC(10, 2) DEFAULT 10,
    car_id INT NOT NULL,
    client_id INT NOT NULL,
    CONSTRAINT courses_bill_check CHECK (bill > 0),
    CONSTRAINT fk_courses_addresses
        FOREIGN KEY (from_address_id)
            REFERENCES addresses(id)
                ON UPDATE CASCADE
                ON DELETE CASCADE,
    CONSTRAINT fk_courses_cars
        FOREIGN KEY (car_id)
            REFERENCES cars(id)
                ON UPDATE CASCADE
                ON DELETE CASCADE,
    CONSTRAINT fk_courses_clients
        FOREIGN KEY (client_id)
            REFERENCES clients(id)
                ON UPDATE CASCADE
                ON DELETE CASCADE
);

DROP TABLE IF EXISTS cars_drivers CASCADE;
CREATE TABLE cars_drivers(
    car_id INT NOT NULL,
    driver_id INT NOT NULL,
    CONSTRAINT fk_cars_drivers_cars
        FOREIGN KEY (car_id)
            REFERENCES cars(id)
                ON UPDATE CASCADE
                ON DELETE CASCADE,
    CONSTRAINT fk_cars_drivers_drivers
        FOREIGN KEY (driver_id)
            REFERENCES drivers(id)
                ON UPDATE CASCADE
                ON DELETE CASCADE
);

--2 DML
INSERT INTO clients(full_name, phone_number)
SELECT
    CONCAT(first_name, ' ', last_name),
    CONCAT('(088) 9999', id * 2)
FROM
    drivers
WHERE id BETWEEN 10 AND 20;

UPDATE cars
SET condition = 'C'
WHERE 
	(mileage >= 800000 OR mileage IS NULL)
		AND 
	year <= 2010
		AND
	make <> 'Mercedes-Benz';

DELETE FROM clients
WHERE
    id NOT IN (SELECT client_id FROM courses)
AND
    LENGTH(full_name) > 3;

--3 Querying
SELECT
    make,
    model,
    condition
FROM
    cars;

SELECT
    d.first_name,
    d.last_name,
    c.make,
    c.model,
    c.mileage
FROM
    drivers AS d JOIN
        cars_drivers AS cd ON
            d.id = cd.driver_id JOIN
                cars AS c ON
                    cd.car_id = c.id
WHERE mileage IS NOT NULL
ORDER BY
    mileage DESC,
    first_name;

SELECT
    ca.id AS car_id,
    ca.make,
    ca.mileage,
    COUNT(co.id) AS count_of_courses,
    ROUND(AVG(co.bill), 2) AS average_bill
FROM
    cars AS ca LEFT JOIN
        courses AS co ON
            ca.id = co.car_id
GROUP BY ca.id, ca.make, ca.mileage
HAVING COUNT(co.id) <> 2
ORDER BY
    count_of_courses DESC,
    car_id

SELECT
    cl.full_name,
    COUNT(co.car_id) AS count_of_cars,
    SUM(co.bill) AS total_sum
FROM
    clients AS cl JOIN
        courses AS co ON
            cl.id = co.client_id
WHERE
    SUBSTRING(cl.full_name, 2, 1) = 'a'
GROUP BY full_name
HAVING COUNT(co.car_id) > 1
ORDER BY full_name;

SELECT
    a.name AS address,
    CASE
        WHEN EXTRACT('hour' FROM co.start) BETWEEN 6 AND 20 THEN
            'Day'
        WHEN EXTRACT('hour' FROM co.start) <= 5 OR EXTRACT('hour' FROM co.start) >= 21 THEN
            'Night'
    END AS day_time,
    co.bill,
    cl.full_name,
    ca.make,
    ca.model,
    cat.name
FROM
    addresses AS a JOIN
        courses AS co ON
            a.id = co.from_address_id JOIN
                clients AS cl ON
                    co.client_id = cl.id JOIN
                        cars AS ca ON
                            co.car_id = ca.id JOIN
                                categories AS cat ON
                                    ca.category_id = cat.id
ORDER BY co.id;

--4 Programmability
CREATE OR REPLACE FUNCTION fn_courses_by_client(phone_num VARCHAR(20))
RETURNS INT AS
$$
DECLARE
    total_courses INT;
BEGIN
    total_courses = (
        SELECT
    COUNT(co.id)
FROM
    clients AS cl JOIN
        courses AS co ON
            cl.id = co.client_id
WHERE cl.phone_number = phone_num
);

    RETURN total_courses;
END;
$$
LANGUAGE plpgsql;

CREATE TABLE search_results (
    id SERIAL PRIMARY KEY,
    address_name VARCHAR(50),
    full_name VARCHAR(100),
    level_of_bill VARCHAR(20),
    make VARCHAR(30),
    condition CHAR(1),
    category_name VARCHAR(50)
);

CREATE OR REPLACE PROCEDURE sp_courses_by_address(address_name VARCHAR(100))
AS
$$
BEGIN
    TRUNCATE TABLE search_results;

    INSERT INTO search_results(address_name, full_name, level_of_bill, make, condition, category_name)
    SELECT
        a.name,
        cl.full_name,
        CASE
            WHEN co.bill <= 20 THEN
                'Low'
            WHEN co.bill <= 30 THEN
                'Medium'
            ELSE
                'High'
        END,
        ca.make,
        ca.condition,
        cat.name
    FROM
        addresses AS a JOIN
            courses AS co ON
                a.id = co.from_address_id JOIN
                    clients AS cl ON
                        co.client_id = cl.id JOIN
                            cars AS ca ON co.car_id = ca.id JOIN
                                categories AS cat ON ca.category_id = cat.id
    WHERE a.name = address_name
    ORDER BY
        ca.make,
        cl.full_name;
END;
$$
LANGUAGE plpgsql;