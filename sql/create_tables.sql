-- ============================================================================
-- Employee Depression Analysis — Table Definition
-- ============================================================================
-- Creates the employees table matching the real dataset (employee_data.csv).
-- The column name "emplpoyee_id" preserves the original CSV header.
-- Compatible with PostgreSQL; minor adjustments may be needed for other RDBMS.
-- ============================================================================

DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    emplpoyee_id   INTEGER      PRIMARY KEY,
    office_window  VARCHAR(3)   NOT NULL
                                CHECK (office_window IN ('yes', 'no')),
    beck_score     INTEGER      NOT NULL
                                CHECK (beck_score >= 0)
);

-- Index on office_window to speed up the primary grouping column.
CREATE INDEX idx_employees_office_window ON employees (office_window);

-- Index on beck_score for range queries and risk identification.
CREATE INDEX idx_employees_beck_score ON employees (beck_score);
