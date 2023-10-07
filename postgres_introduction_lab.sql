--1
CREATE DATABASE gamebar;

--2
CREATE TABLE employees(
	id serial PRIMARY KEY NOT NULL,
	first_name VARCHAR(30),
	last_name VARCHAR(50),
	hiring_date date DEFAULT '2023-01-01',
	salary NUMERIC(10, 2),
	devices_number int
);

CREATE TABLE departments(
	id serial PRIMARY KEY NOT NULL,
	name VARCHAR(50),
	code char(3),
	description text
);

CREATE TABLE issues(
	id serial PRIMARY KEY UNIQUE,
	description VARCHAR(150),
	"date" date,
	"start" timestamp
);

--3(optional)
INSERT INTO employees(first_name, last_name, hiring_date, salary, devices_number)

VALUES
	('Valery', 'Raikov', '2023-09-15', 2500, 121222139),
	('Meggie', 'Filipova', '2022-07-06', 2250.75, 1234567),
	('Ivan', 'Muzakov', '1994-04-22', 1650, 110078963);

--4
ALTER TABLE employees

ADD COLUMN middle_name VARCHAR(50);

--5
ALTER TABLE employees

ALTER COLUMN salary
SET NOT NULL,

ALTER COLUMN salary
SET DEFAULT 0,

ALTER COLUMN hiring_date
SET NOT NULL;

--6
ALTER TABLE employees

ALTER COLUMN middle_name
TYPE VARCHAR(100);

--7
TRUNCATE TABLE issues;

--8
DROP TABLE departments;