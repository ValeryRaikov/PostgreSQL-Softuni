--1
CREATE OR REPLACE FUNCTION fn_count_employees_by_town(town_name VARCHAR(20))
RETURNS INT AS
$$
    DECLARE
        employee_count INT;
    BEGIN
        SELECT
            COUNT(employee_id)
        FROM
            employees AS e JOIN addresses AS a
                USING (address_id) JOIN towns AS t
                    USING (town_id)
        WHERE t.name = town_name
        INTO employee_count;

        RETURN employee_count;
    END;
$$
LANGUAGE plpgsql;

--2
CREATE OR REPLACE PROCEDURE sp_increase_salaries(department_name VARCHAR)
AS
$$
    BEGIN
        UPDATE employees AS e
        SET salary = salary * 1.05
        WHERE e.department_id = (
            SELECT department_id FROM departments
                WHERE name = department_name
            );
    END;
$$
LANGUAGE plpgsql;

--3
CREATE PROCEDURE sp_increase_salary_by_id(id INT)
AS
$$
    BEGIN
        IF (SELECT salary FROM employees WHERE employee_id = id) IS NULL THEN
            RETURN;
        ELSE
            UPDATE employees
            SET salary = salary * 1.05
            WHERE employee_id = id;
        END IF;
        COMMIT;
    END;
$$
LANGUAGE plpgsql;

--4
CREATE TABLE IF NOT EXISTS deleted_employees(
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(20),
    last_name VARCHAR(20),
    middle_name VARCHAR(20),
    job_title VARCHAR(50),
    department_id INT,
    salary NUMERIC(19, 4)
);

CREATE OR REPLACE FUNCTION backup_fired_employees()
RETURNS TRIGGER AS
$$
    BEGIN
        INSERT INTO deleted_employees (
            first_name, last_name, middle_name, job_title, department_id, salary
        )
        VALUES
            (old.first_name, old.last_name, old.middle_name, old.job_title, old.department_id, old.salary);
        RETURN  new;
    END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER backup_employees
AFTER DELETE ON employees
FOR EACH ROW
EXECUTE PROCEDURE backup_fired_employees();