-- ============================================================================
-- Employee Depression Analysis — Data Loading
-- ============================================================================
-- Import employee_data.csv into the employees table.
-- Two methods are provided: one for PostgreSQL and one for MySQL.
-- Adjust the file path to match your local environment.
-- ============================================================================


-- ---------------------------------------------------------------------------
-- Method 1: PostgreSQL — COPY command
-- ---------------------------------------------------------------------------
-- Run from psql or a PostgreSQL client. The file path must be absolute and
-- accessible to the PostgreSQL server process.

-- \COPY employees (emplpoyee_id, office_window, beck_score)
-- FROM '/path/to/employee_data.csv'
-- WITH (FORMAT csv, HEADER true, DELIMITER ',');

COPY employees (
    emplpoyee_id,
    office_window,
    beck_score
)
FROM '/path/to/employee_data.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);


-- ---------------------------------------------------------------------------
-- Method 2: MySQL — LOAD DATA INFILE
-- ---------------------------------------------------------------------------
-- Uncomment the block below if using MySQL. Make sure the server has
-- FILE privilege and the path is correct.

-- LOAD DATA INFILE '/path/to/employee_data.csv'
-- INTO TABLE employees
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (emplpoyee_id, office_window, beck_score);


-- ---------------------------------------------------------------------------
-- Verification: quick row count and sample after loading
-- ---------------------------------------------------------------------------
SELECT COUNT(*) AS total_rows FROM employees;

SELECT * FROM employees LIMIT 5;
