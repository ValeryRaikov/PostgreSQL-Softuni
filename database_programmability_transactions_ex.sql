--1
CREATE DATABASE diablo_db;

CREATE OR REPLACE FUNCTION fn_full_name(first_name VARCHAR, last_name VARCHAR)
RETURNS VARCHAR AS
$$
BEGIN
    IF first_name IS NULL AND last_name IS NULL THEN
        RETURN NULL;
    ELSIF first_name IS NULL THEN
        RETURN INITCAP(first_name);
    ELSIF last_name IS NULL THEN
        RETURN INITCAP(last_name);
    ELSE
        RETURN INITCAP(CONCAT(first_name, ' ', last_name));
    END IF;
END;
$$
LANGUAGE plpgsql;

--2
CREATE OR REPLACE FUNCTION fn_calculate_future_value (
	initial_sum DECIMAL,
	yearly_interest_rate DECIMAL,
	number_of_years INT
)
RETURNS DECIMAL AS
$$
BEGIN
    RETURN TRUNC(initial_sum * POWER(1 + yearly_interest_rate, number_of_years), 4);
END;
$$
LANGUAGE plpgsql

--3
CREATE OR REPLACE FUNCTION fn_is_word_comprised(set_of_letters VARCHAR(50), word VARCHAR(50))
RETURNS BOOLEAN AS
$$
BEGIN
    RETURN TRIM(LOWER(word) FROM LOWER(set_of_letters)) = '';
END;
$$
LANGUAGE plpgsql;

--4
CREATE DATABASE diablo_db;

CREATE OR REPLACE FUNCTION fn_is_game_over(is_game_over BOOLEAN)
RETURNS TABLE(
    name VARCHAR(50),
    game_type_id INT,
    is_finished BOOLEAN
)
AS
$$
BEGIN
    RETURN QUERY
    SELECT
        name,
        game_type_id,
        is_finished
    FROM games
    WHERE is_finished = is_game_over;
END;
$$
LANGUAGE plpgsql;

--5
CREATE OR REPLACE FUNCTION fn_difficulty_level(level INT)
RETURNS VARCHAR(50) AS
$$
DECLARE
    difficulty_level VARCHAR(50);
BEGIN
    IF level > 60 THEN
        difficulty_level := 'Hell Difficulty';
    ELSIF level > 40 THEN
        difficulty_level := 'Nightmare Difficulty';
    ELSE
        difficulty_level := 'Normal Difficulty';
    END IF;

    RETURN difficulty_level;
END;
$$
LANGUAGE plpgsql;

SELECT
	user_id,
	level,
	cash,
	fn_difficulty_level(level)
FROM
	users_games
ORDER BY
	user_id ASC;

--6
CREATE OR REPLACE FUNCTION fn_cash_in_users_games(game_name VARCHAR(50))
RETURNS TABLE(
    total_cash NUMERIC
)
AS
$$
BEGIN
    RETURN QUERY
    WITH ranked_games AS (
        SELECT
            cash,
            ROW_NUMBER() OVER (ORDER BY cash DESC) AS row_num
        FROM
            users_games AS ug
        JOIN
            games AS g
        ON
            ug.game_id = g.id
        WHERE g.name = game_name
    )

    SELECT
        ROUND(SUM(cash), 2) AS total_cash
    FROM
        ranked_games
    WHERE
        row_num % 2 <> 0;
END;
$$
LANGUAGE plpgsql;

--7
CREATE DATABASE bank_db;

CREATE OR REPLACE PROCEDURE sp_retrieving_holders_with_balance_higher_than(searched_balance NUMERIC)
AS
$$
DECLARE
    holder_info RECORD;
BEGIN
    FOR holder_info IN
        SELECT
            CONCAT(ah.first_name, ' ', ah.last_name) AS full_name,
            SUM(a.balance) AS total_balance
        FROM
            account_holders AS ah JOIN
                accounts AS a ON
                    ah.id = a.account_holder_id
        GROUP BY
			full_name
		HAVING
			SUM(balance) > searched_balance
		ORDER BY
			full_name
    LOOP
        RAISE NOTICE '% - %', holder_info.full_name, holder_info.total_balance;
    END LOOP;
END;
$$
LANGUAGE plpgsql;

--8
CREATE OR REPLACE PROCEDURE sp_deposit_money(account_id INT, money_amount NUMERIC(10, 4))
AS
$$
BEGIN
    UPDATE accounts
    SET balance = balance + money_amount
    WHERE id = account_id;
END;
$$
LANGUAGE plpgsql;

--9
CREATE OR REPLACE PROCEDURE sp_withdraw_money(account_id INT, money_amount NUMERIC(10, 4))
AS
$$
DECLARE
    curr_balance NUMERIC;
BEGIN
    curr_balance := (SELECT balance FROM accounts WHERE id = account_id);

    IF (curr_balance - money_amount) >= 0 THEN
        UPDATE accounts
        SET balance = balance - money_amount
        WHERE id = account_id;
    ELSE
        RAISE NOTICE 'Insufficient balance to withdraw %', money_amount;
    END IF;
END;
$$
LANGUAGE plpgsql;

--10
CREATE OR REPLACE PROCEDURE sp_transfer_money(sender_id INT, receiver_id INT, amount NUMERIC(10, 4))
AS
$$
DECLARE
	curr_balance NUMERIC(10, 4);
BEGIN
    CALL sp_withdraw_money(sender_id, amount);
    CALL sp_deposit_money(receiver_id, amount);

    SELECT balance INTO curr_balance FROM accounts WHERE id = sender_id;

    IF curr_balance < 0 THEN
        ROLLBACK;
    END IF;
END;
$$
LANGUAGE plpgsql;

--11
DROP PROCEDURE sp_retrieving_holders_with_balance_higher_than;

--12
CREATE TABLE IF NOT EXISTS logs(
    id SERIAL PRIMARY KEY,
    account_id INT,
    old_sum NUMERIC(10, 4),
    new_sum NUMERIC(10, 4)
);

CREATE OR REPLACE FUNCTION trigger_fn_insert_new_entry_into_logs()
RETURNS TRIGGER AS
$$
BEGIN
    INSERT INTO logs(account_id, old_sum, new_sum)
    VALUES
        (old.id, old.balance, new.balance);

    RETURN new;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER tr_account_balance_change
    AFTER UPDATE OF balance ON accounts
    FOR EACH ROW
    WHEN
        (new.balance <> old.balance)
    EXECUTE FUNCTION
        trigger_fn_insert_new_entry_into_logs();

--13
CREATE TABLE IF NOT EXISTS notification_emails(
    id SERIAL PRIMARY KEY,
    recipient_id INT,
    subject VARCHAR,
    body VARCHAR
);

CREATE OR REPLACE FUNCTION trigger_fn_send_email_on_balance_change()
RETURNS TRIGGER AS
$$
BEGIN
    INSERT INTO notification_emails(recipient_id, subject, body)
    VALUES
        (new.recipient_id,
         concat('Balance change for account: ',new.subject),
         concat('On ', DATE(NOW()), ' your balance was changed from ', old.balance, ' to ', new.balance, '.')
        );

    RETURN new;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER tr_send_email_on_balance_change
    AFTER UPDATE ON logs
    FOR EACH ROW
    WHEN
	    (OLD.new_sum <> NEW.new_sum)
    EXECUTE FUNCTION
        trigger_fn_send_email_on_balance_change();