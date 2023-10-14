--DDL
CREATE DATABASE soccer_talent_db;

DROP TABLE IF EXISTS towns CASCADE;
CREATE TABLE towns (
    id SERIAL PRIMARY KEY,
    name VARCHAR(45) NOT NULL
);

DROP TABLE IF EXISTS stadiums CASCADE;
CREATE TABLE stadiums (
    id SERIAL PRIMARY KEY,
    name VARCHAR(45) NOT NULL,
    capacity INT NOT NULL CHECK (capacity > 0),
    town_id INT NOT NULL,
    CONSTRAINT fk_stadiums_towns
        FOREIGN KEY (town_id)
            REFERENCES towns(id) 
                ON UPDATE CASCADE 
                ON DELETE CASCADE
);

DROP TABLE IF EXISTS teams CASCADE;
CREATE TABLE teams (
    id SERIAL PRIMARY KEY,
    name VARCHAR(45) NOT NULL,
    established DATE NOT NULL,
    fan_base INT DEFAULT 0 NOT NULL CHECK (fan_base >= 0),
    stadium_id INT NOT NULL,
    CONSTRAINT fk_teams_stadiums
        FOREIGN KEY (stadium_id)
            REFERENCES stadiums(id) 
                ON UPDATE CASCADE 
                ON DELETE CASCADE
);

DROP TABLE IF EXISTS coaches CASCADE;
CREATE TABLE coaches (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(10) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    salary NUMERIC(10, 2) DEFAULT 0 NOT NULL CHECK (salary >= 0),
    coach_level INT DEFAULT 0 NOT NULL CHECK (coach_level >= 0)
);

DROP TABLE IF EXISTS skills_data CASCADE;
CREATE TABLE skills_data (
    id SERIAL PRIMARY KEY,
    dribbling INT DEFAULT 0 CHECK (dribbling >= 0),
    pace INT DEFAULT 0 CHECK (pace >= 0),
    passing INT DEFAULT 0 CHECK (passing >= 0),
    shooting INT DEFAULT 0 CHECK (shooting >= 0),
    speed INT DEFAULT 0 CHECK (speed >= 0),
    strength INT DEFAULT 0 CHECK (strength >= 0)
);

DROP TABLE IF EXISTS players CASCADE;
CREATE TABLE players (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(10) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    age INT DEFAULT 0 NOT NULL CHECK (age >= 0),
    position CHAR(1) NOT NULL,
    salary NUMERIC(10, 2) DEFAULT 0 NOT NULL CHECK (salary >= 0),
    hire_date TIMESTAMP,
    skills_data_id INT NOT NULL,
    team_id INT,
    CONSTRAINT fk_players_skills_data
        FOREIGN KEY (skills_data_id)
            REFERENCES skills_data(id) 
            ON UPDATE CASCADE 
            ON DELETE CASCADE,
    CONSTRAINT fk_players_teams
        FOREIGN KEY (team_id)
            REFERENCES teams(id) 
                ON UPDATE CASCADE 
                ON DELETE CASCADE
);

DROP TABLE IF EXISTS players_coaches CASCADE;
CREATE TABLE players_coaches (
    player_id INT,
    coach_id INT,
    CONSTRAINT fk_players_coaches_players
        FOREIGN KEY (player_id)
            REFERENCES players(id) 
                ON UPDATE CASCADE 
                ON DELETE CASCADE,
    CONSTRAINT fk_players_coaches_coaches
        FOREIGN KEY (coach_id)
            REFERENCES coaches(id)
                ON UPDATE CASCADE 
                ON DELETE CASCADE 
);

--DML
INSERT INTO coaches (first_name, last_name, salary, coach_level)
SELECT
    p.first_name,
    p.last_name,
    p.salary * 2,
    LENGTH(p.first_name)
FROM
    players AS p
WHERE
    p.hire_date < '2013-12-13 07:18:46';

UPDATE coaches
SET salary = salary * coach_level
WHERE
    LEFT(first_name, 1) = 'C'
AND
    id IN (
        SELECT
           DISTINCT coach_id
        FROM
            players_coaches
        )

DELETE FROM players_coaches CASCADE
WHERE
    player_id IN (
        SELECT
            id
        FROM
            players
        WHERE hire_date < '2013-12-13 07:18:46'
);

DELETE FROM players CASCADE
WHERE hire_date < '2013-12-13 07:18:46';

--Querying
SELECT
    CONCAT(first_name, ' ', last_name) AS full_name,
    age,
    hire_date
FROM
    players
WHERE
    LEFT(first_name, 1) = 'M'
ORDER BY
    age DESC ,
    full_name;

SELECT
    p.id,
    CONCAT(p.first_name, ' ', p.last_name) AS full_name,
    p.age,
    p.position,
    p.salary,
    sd.pace,
    sd.shooting
FROM
    players AS p LEFT JOIN
        skills_data AS sd ON
            p.skills_data_id = sd.id
WHERE
    p.position = 'A'
AND
    sd.pace + sd.shooting > 130
AND
    p.team_id IS NULL;

SELECT
    t.id AS team_id,
    t.name,
    COUNT(p.team_id) AS player_count,
    t.fan_base
FROM
    teams AS t LEFT JOIN
        players AS p ON
            t.id = p.team_id
WHERE t.fan_base > 30000
GROUP BY
    t.id, t.name, t.fan_base
ORDER BY
    player_count DESC,
    t.fan_base DESC;

SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS coach_full_name,
    CONCAT(p.first_name, ' ', p.last_name) AS player_full_name,
    t.name AS team_name,
    s.passing,
    s.shooting,
    s.speed
FROM
    coaches AS c JOIN
        players_coaches AS pc ON
            c.id = pc.coach_id JOIN
                players AS p ON
                    pc.player_id = p.id JOIN
                        skills_data AS s ON
                            p.skills_data_id = s.id JOIN
                                teams AS t ON
                                    p.team_id = t.id
ORDER BY
    coach_full_name,
    player_full_name DESC;

--Programmability
CREATE OR REPLACE FUNCTION fn_stadium_team_name(stadium_name VARCHAR(30))
RETURNS TABLE(
    team_name VARCHAR(45)
)
AS
$$
BEGIN
    RETURN QUERY
    SELECT
        t.name
    FROM
        teams AS t JOIN
            stadiums AS s ON
                t.stadium_id = s.id
    WHERE s.name = stadium_name
    ORDER BY t.name;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE sp_players_team_name(IN player_name VARCHAR(50), OUT team_name VARCHAR(45))
AS
$$
BEGIN
    team_name := (
        SELECT
            t.name
        FROM
            players AS p JOIN
                teams AS t ON
                    p.team_id = t.id
        WHERE CONCAT(p.first_name, ' ', p.last_name) = player_name
);
    IF team_name IS NULL THEN
        team_name = 'The player currently has no team';
    END IF;
END;
$$
LANGUAGE plpgsql;