--1
CREATE DATABASE camp;

--2
CREATE TABLE mountains(
	id SERIAL PRIMARY KEY,
	name VARCHAR(50)
);

CREATE TABLE peaks(
	id SERIAL PRIMARY KEY,
	name VARCHAR(50),
	mountain_id INT,
	CONSTRAINT fk_peaks_mountains
		FOREIGN KEY (mountain_id)
			REFERENCES mountains(id)
);

--Another solution:

CREATE TABLE mountains(
	id SERIAL PRIMARY KEY,
	name VARCHAR(50)
);

CREATE TABLE peaks(
	id SERIAL PRIMARY KEY,
	name VARCHAR(50),
	mountain_id INT REFERENCES mountains(id)
	
);

--3
SELECT
	v.driver_id,
	v.vehicle_type,
	CONCAT(c.first_name, ' ', c.last_name) AS driver_name
FROM
	vehicles AS v JOIN
	campers AS c ON
	v.driver_id = c.id
;

--4
SELECT
	r.start_point,
	r.end_point,
	r.leader_id,
	CONCAT(c.first_name, ' ', c.last_name) AS leader_name
FROM 
	routes AS r JOIN
	campers AS c ON
		r.leader_id = c.id
;

--5
DROP TABLE mountains CASCADE;
DROP TABLE peaks;

--6
CREATE TABLE mountains(
	id SERIAL PRIMARY KEY,
	name VARCHAR(50)
);

CREATE TABLE peaks(
	id SERIAL PRIMARY KEY,
	name VARCHAR(50),
	mountain_id INT,
	CONSTRAINT fk_mountain_id
		FOREIGN KEY (mountain_id)
			REFERENCES mountains(id)
				ON DELETE CASCADE
);

--Project management DB according to an E/R diagram:
--1
CREATE DATABASE project_management_db;

--2
CREATE TABLE clients (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    client_id INT,
    project_lead_id INT,
    CONSTRAINT fk_clients_projects
        FOREIGN KEY (client_id)
        	REFERENCES clients(id),
    CONSTRAINT fk_employees_projects
        FOREIGN KEY (project_lead_id)
        	REFERENCES employees(id)
);

CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(30),
    last_name VARCHAR(30),
    project_id INT,
    CONSTRAINT fk_employees_projects
        FOREIGN KEY (project_id)
        	REFERENCES projects(id)
);