--1
CREATE DATABASE minions_db;

--2
CREATE TABLE minions(
	id serial PRIMARY KEY,
	name varchar(30),
	age int
);

--3
ALTER TABLE minions

RENAME TO minions_info;

--4
ALTER TABLE minions_info

ADD COLUMN code CHAR(4),
ADD COLUMN task TEXT,
ADD COLUMN salary NUMERIC(8, 3);

--5
ALTER TABLE minions_info

RENAME COLUMN salary TO banana;

--6
ALTER TABLE minions_info

ADD COLUMN email VARCHAR(20),
ADD COLUMN equipped BOOLEAN NOT NULL;

--7
CREATE TYPE type_mood
AS ENUM(
		'happy',
		'relaxed',
		'stressed',
		'sad'
);

ALTER TABLE minions_info
ADD COLUMN mood type_mood;

--8
ALTER TABLE minions_info

ALTER COLUMN age SET DEFAULT 0,
ALTER COLUMN name SET DEFAULT '',
ALTER COLUMN code SET DEFAULT '';

--9
ALTER TABLE minions_info

ADD CONSTRAINT unique_containt
UNIQUE(id, email),

ADD CONSTRAINT banana_check
CHECK(banana > 0);

--10
ALTER TABLE minions_info

ALTER COLUMN task
TYPE varchar(150);

--11
ALTER TABLE minions_info

ALTER COLUMN equipped
DROP NOT NULL;

--12
ALTER TABLE minions_info

DROP COLUMN age;

--13
CREATE TABLE minions_birthdays (
	id int UNIQUE NOT NULL,
	name varchar(50),
	date_of_birth date,
	age int,
	present varchar(100),
	party timestamptz
);

--14
INSERT INTO minions_info(
	name, code, task, banana, email, equipped, mood
)

VALUES
	('Mark', 'GKYA', 'Graphing Points', 3265.265, 'mark@minion.com', false, 'happy'),
	('Mel', 'HSK', 'Science Investigation', 54784.996, 'mel@minion.com', true, 'stressed'),
	('Bob', 'HF', 'Painting', 35.652, 'bob@minion.com', true, 'happy'),
	('Darwin', 'EHND', 'Create a Digital Greeting', 321.958, 'darwin@minion.com', false, 'relaxed'),
	('Kevin', 'KMHD', 'Construct with Virtual Blocks', 35214.789, 'kevin@minion.com', false, 'happy'),
	('Norbert', 'FEWB', 'Testing', 3265.500, 'norbert@minion.com', true, 'sad'),
	('Donny', 'L', 'Make a Map', 8.452, 'donny@minion.com', true, 'happy');

--15
SELECT 
	name, 
	task, 
	email, 
	banana
FROM
	minions_info;

--16
TRUNCATE TABLE minions_info;

--17
DROP TABLE minions_birthdays;

--18(optional)
DROP DATABASE minions_db WITH (FORCE);