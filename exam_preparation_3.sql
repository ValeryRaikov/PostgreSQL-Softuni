--1 DDL
CREATE DATABASE board_games_db;

CREATE TABLE IF NOT EXISTS categories(
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS addresses(
    id SERIAL PRIMARY KEY,
    street_name VARCHAR(100) NOT NULL,
    street_number INT NOT NULL ,
    town VARCHAR(30) NOT NULL,
    country VARCHAR(50) NOT NULL,
    zip_code INT NOT NULL
    CONSTRAINT addresses_street_number_check CHECK (street_number > 0),
    CONSTRAINT addresses_zip_code_check CHECK (zip_code > 0)
);

CREATE TABLE IF NOT EXISTS publishers(
    id SERIAL PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    address_id INT NOT NULL,
    website VARCHAR(40),
    phone VARCHAR(20),
    CONSTRAINT fk_publishers_addresses
        FOREIGN KEY (address_id)
            REFERENCES addresses(id)
                ON DELETE CASCADE
                ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS players_ranges(
    id SERIAL PRIMARY KEY,
    min_players INT NOT NULL,
    max_players INT NOT NULL,
    CONSTRAINT players_ranges_min_players_check CHECK (min_players > 0),
    CONSTRAINT players_ranges_max_players_check CHECK (max_players > 0)
);

CREATE TABLE IF NOT EXISTS creators(
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    email VARCHAR(30) NOT NULL
);

CREATE TABLE IF NOT EXISTS board_games
(
    id SERIAL PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    release_year INT NOT NULL,
    rating NUMERIC(3, 2) NOT NULL,
    category_id INT NOT NULL,
    publisher_id INT NOT NULL,
    players_range_id INT NOT NULL,
    CONSTRAINT board_games_release_year_check CHECK (release_year > 0),
    CONSTRAINT fk_board_games_categories
        FOREIGN KEY (category_id)
            REFERENCES categories(id)
                ON DELETE CASCADE
	            ON UPDATE CASCADE,
    CONSTRAINT fk_board_games_publishers
        FOREIGN KEY (publisher_id)
            REFERENCES publishers(id)
                ON DELETE CASCADE
	            ON UPDATE CASCADE,
    CONSTRAINT fk_board_games_players_ranges
        FOREIGN KEY (players_range_id)
            REFERENCES players_ranges(id)
                ON DELETE CASCADE
	            ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS creators_board_games(
    creator_id INT NOT NULL,
    board_game_id INT NOT NULL,
    CONSTRAINT fk_creators_board_games_creators
	    FOREIGN KEY (creator_id)
	        REFERENCES creators("id")
	            ON DELETE CASCADE
	            ON UPDATE CASCADE,
    CONSTRAINT fk_creators_board_games_board_games
	    FOREIGN KEY (board_game_id)
	        REFERENCES board_games("id")
	            ON DELETE CASCADE
	            ON UPDATE CASCADE
);

--2 DML
INSERT INTO board_games(name, release_year, rating, category_id, publisher_id, players_range_id)
VALUES
    ('Deep Blue', 2019, 5.67, 1, 15, 7),
	('Paris', 2016, 9.78, 7, 1, 5),
	('Catan: Starfarers', 2021, 9.87, 7, 13, 6),
	('Bleeding Kansas', 2020, 3.25, 3, 7, 4),
	('One Small Step', 2019, 5.75, 5, 9, 2);

INSERT INTO publishers(name, address_id, website, phone)
VALUES
    ('Agman Games', 5, 'www.agmangames.com', '+16546135542'),
	('Amethyst Games', 7, 'www.amethystgames.com', '+15558889992'),
	('BattleBooks', 13, 'www.battlebooks.com', '+12345678907');

UPDATE players_ranges
SET max_players = max_players + 1
WHERE
    min_players = 2
AND
    max_players = 2;

UPDATE board_games
SET name = concat(name, ' V2')
WHERE
    release_year >= 2020;

DELETE FROM board_games
WHERE publisher_id IN(
    SELECT id
    FROM publishers
    WHERE address_id IN(
        SELECT id
        FROM addresses
        WHERE LEFT(town, 1) = 'L'
    )
);

DELETE FROM publishers
WHERE address_id IN(
    SELECT id
    FROM addresses
    WHERE LEFT(town, 1) = 'L'
);

DELETE FROM addresses
WHERE
    LEFT(town, 1) = 'L';

--3 Querying
SELECT
    name,
    rating
FROM
    board_games
ORDER BY
    release_year,
    name DESC;

SELECT
    bg.id,
    bg.name,
    bg.release_year,
    c.name AS category_name
FROM
    board_games AS bg JOIN
        categories AS c ON
            bg.category_id = c.id
WHERE c.name IN ('Strategy Games', 'Wargames')
ORDER BY bg.release_year DESC;

SELECT
    c.id,
    CONCAT_WS(' ', c.first_name, c.last_name) AS creator_name,
    c.email
FROM
	creators AS c LEFT JOIN
	    creators_board_games AS cbg ON
	        cbg.creator_id = c.id
WHERE
	cbg.creator_id IS NULL
ORDER BY creator_name;

SELECT
    bg.name AS name,
    bg.rating,
    c.name AS category_name
FROM
    board_games AS bg
JOIN
    categories AS c ON
        bg.category_id = c.id
JOIN
    players_ranges AS pr ON
        bg.players_range_id = pr.id

WHERE (
    bg.rating > 7.00 AND
    bg.name ILIKE '%a%'
    )
OR (
    bg.rating > 7.50 AND
    pr.min_players >= 2 AND
    pr.max_players <= 5
    )
ORDER BY
    bg.name,
    bg.rating DESC
LIMIT 5;

SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    c.email,
    MAX(bg.rating)
FROM
    creators AS c
JOIN
    creators_board_games AS cbg ON
        c.id = cbg.creator_id
JOIN
    board_games AS bg ON
        cbg.board_game_id = bg.id
WHERE c.email LIKE '%.com'
GROUP BY 
    full_name,
    c.email
ORDER BY full_name;

SELECT
    c.last_name,
    ceiling(AVG(bg.rating)) AS average_rating,
    p.name AS publisher_name
FROM
    creators AS c
JOIN
    creators_board_games AS cbg ON
        c.id = cbg.creator_id
JOIN
    board_games AS bg ON
        cbg.board_game_id = bg.id
JOIN
    publishers AS p ON
        bg.publisher_id = p.id
WHERE p.name = 'Stonemaier Games'
GROUP BY
    c.last_name,
    p.name
ORDER BY average_rating DESC;

--4 Programmability
CREATE OR REPLACE FUNCTION fn_creator_with_board_games(f_name VARCHAR(30))
RETURNS INT AS
$$
DECLARE
    total_games_created INT;
BEGIN
    total_games_created = (
        SELECT
            COUNT(*)
        FROM
            creators AS c JOIN
                creators_board_games AS cbg ON
                    c.id = cbg.creator_id
        WHERE c.first_name = f_name
    );
    RETURN total_games_created;
END;
$$
LANGUAGE plpgsql;

CREATE TABLE search_results (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    release_year INT,
    rating FLOAT,
    category_name VARCHAR(50),
    publisher_name VARCHAR(50),
    min_players VARCHAR(50),
    max_players VARCHAR(50)
);

CREATE OR REPLACE PROCEDURE usp_search_by_category(category VARCHAR(50))
AS
$$
BEGIN
    INSERT INTO search_results (
		name,
		release_year,
		rating,
		category_name,
		publisher_name,
		min_players,
		max_players
	)
    SELECT
        bg.name,
        bg.release_year,
        bg.rating,
        c.name AS category_name,
        p.name AS publisher_name,
        CONCAT(pr.min_players, ' people'),
        CONCAT(pr.max_players, ' people')
    FROM
		board_games AS bg JOIN
		    publishers AS p ON
		        bg.publisher_id = p.id
    JOIN
		categories AS c ON
		    bg.category_id = c.id
    JOIN
		players_ranges AS pr ON
		    bg.players_range_id = pr.id
    WHERE c.name = category
    ORDER BY
		publisher_name,
		release_year DESC;
END;
$$
LANGUAGE plpgsql;