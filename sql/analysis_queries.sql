-- ============================================================================
-- Employee Depression Analysis — Analytical Queries
-- ============================================================================
-- These queries analyze the employees table (emplpoyee_id, office_window,
-- beck_score) to explore the relationship between office window access and
-- Beck Depression Inventory scores.
-- Written in standard SQL with PostgreSQL functions where noted.
-- ============================================================================


-- ============================================================================
-- 1. Descriptive Statistics by Office Window Status
--    Mean, median (50th percentile), SD, min, max of beck_score for each group.
-- ============================================================================

SELECT
    office_window,
    COUNT(*)                                           AS n,
    ROUND(AVG(beck_score), 2)                          AS mean_beck,
    ROUND(PERCENTILE_CONT(0.5)
          WITHIN GROUP (ORDER BY beck_score), 2)       AS median_beck,
    ROUND(STDDEV(beck_score), 2)                       AS sd_beck,
    MIN(beck_score)                                    AS min_beck,
    MAX(beck_score)                                    AS max_beck
FROM employees
GROUP BY office_window
ORDER BY office_window;


-- ============================================================================
-- 2. Count and Proportion of Employees by Office Type
-- ============================================================================

SELECT
    office_window,
    COUNT(*)                                                    AS n,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)         AS pct
FROM employees
GROUP BY office_window
ORDER BY office_window;


-- ============================================================================
-- 3. Beck Score Distribution Buckets by Office Type
--    Buckets: 0-5 (minimal), 6-10 (mild), 11-15 (mild-moderate),
--             16-20 (moderate), 21+ (moderate-severe)
-- ============================================================================

SELECT
    office_window,
    CASE
        WHEN beck_score BETWEEN  0 AND  5 THEN '00-05'
        WHEN beck_score BETWEEN  6 AND 10 THEN '06-10'
        WHEN beck_score BETWEEN 11 AND 15 THEN '11-15'
        WHEN beck_score BETWEEN 16 AND 20 THEN '16-20'
        WHEN beck_score > 20              THEN '21+'
    END                                                         AS score_bucket,
    COUNT(*)                                                    AS n,
    ROUND(COUNT(*) * 100.0 /
          SUM(COUNT(*)) OVER (PARTITION BY office_window), 2)   AS pct_within_group
FROM employees
GROUP BY office_window, score_bucket
ORDER BY office_window, score_bucket;


-- ============================================================================
-- 4. Direct Comparison: Window vs No Window with Difference
--    Overall group means side by side.
-- ============================================================================

SELECT
    w.mean_window,
    nw.mean_no_window,
    ROUND(nw.mean_no_window - w.mean_window, 2) AS mean_difference
FROM
    (SELECT ROUND(AVG(beck_score), 2) AS mean_window
     FROM employees WHERE office_window = 'yes') w,
    (SELECT ROUND(AVG(beck_score), 2) AS mean_no_window
     FROM employees WHERE office_window = 'no') nw;


-- ============================================================================
-- 5. Percentile Analysis of Beck Scores by Office Type
--    Quartiles plus the 90th and 95th percentiles.
-- ============================================================================

SELECT
    office_window,
    ROUND(PERCENTILE_CONT(0.25)
          WITHIN GROUP (ORDER BY beck_score), 2) AS p25,
    ROUND(PERCENTILE_CONT(0.50)
          WITHIN GROUP (ORDER BY beck_score), 2) AS p50,
    ROUND(PERCENTILE_CONT(0.75)
          WITHIN GROUP (ORDER BY beck_score), 2) AS p75,
    ROUND(PERCENTILE_CONT(0.90)
          WITHIN GROUP (ORDER BY beck_score), 2) AS p90,
    ROUND(PERCENTILE_CONT(0.95)
          WITHIN GROUP (ORDER BY beck_score), 2) AS p95
FROM employees
GROUP BY office_window
ORDER BY office_window;


-- ============================================================================
-- 6. T-Test Summary Statistics
--    Group means, standard deviations, counts, standard error of the
--    difference, and an approximate t-statistic (Welch's approximation).
-- ============================================================================

WITH stats AS (
    SELECT
        office_window,
        COUNT(*)                          AS n,
        AVG(beck_score)                   AS mean_beck,
        STDDEV(beck_score)                AS sd_beck,
        VARIANCE(beck_score)              AS var_beck
    FROM employees
    GROUP BY office_window
),
two_group AS (
    SELECT
        MAX(CASE WHEN office_window = 'yes' THEN mean_beck END) AS mean_window,
        MAX(CASE WHEN office_window = 'no'  THEN mean_beck END) AS mean_no_window,
        MAX(CASE WHEN office_window = 'yes' THEN sd_beck   END) AS sd_window,
        MAX(CASE WHEN office_window = 'no'  THEN sd_beck   END) AS sd_no_window,
        MAX(CASE WHEN office_window = 'yes' THEN n         END) AS n_window,
        MAX(CASE WHEN office_window = 'no'  THEN n         END) AS n_no_window,
        MAX(CASE WHEN office_window = 'yes' THEN var_beck  END) AS var_window,
        MAX(CASE WHEN office_window = 'no'  THEN var_beck  END) AS var_no_window
    FROM stats
)
SELECT
    ROUND(mean_window, 2)                                              AS mean_window,
    ROUND(mean_no_window, 2)                                           AS mean_no_window,
    ROUND(sd_window, 2)                                                AS sd_window,
    ROUND(sd_no_window, 2)                                             AS sd_no_window,
    n_window,
    n_no_window,
    ROUND(SQRT(var_window / n_window + var_no_window / n_no_window), 4) AS se_diff,
    ROUND((mean_window - mean_no_window)
          / SQRT(var_window / n_window + var_no_window / n_no_window),
          4)                                                           AS approx_t_stat
FROM two_group;


-- ============================================================================
-- 7. High-Risk Identification (Beck Score > 20)
--    Employees with moderate-to-severe depression symptoms.
-- ============================================================================

SELECT
    emplpoyee_id,
    office_window,
    beck_score
FROM employees
WHERE beck_score > 20
ORDER BY beck_score DESC, emplpoyee_id;

-- Summary of high-risk employees by office type
SELECT
    office_window,
    COUNT(*)                                                        AS high_risk_count,
    ROUND(COUNT(*) * 100.0 /
          (SELECT COUNT(*) FROM employees e2
           WHERE e2.office_window = employees.office_window), 2)    AS pct_of_group,
    ROUND(AVG(beck_score), 2)                                       AS mean_beck_high_risk
FROM employees
WHERE beck_score > 20
GROUP BY office_window
ORDER BY office_window;


-- ============================================================================
-- 8. Missing Data Audit
--    Check for NULL values and out-of-range data.
-- ============================================================================

SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN emplpoyee_id IS NULL THEN 1 ELSE 0 END) AS null_id,
    SUM(CASE WHEN office_window IS NULL THEN 1 ELSE 0 END) AS null_window,
    SUM(CASE WHEN beck_score IS NULL THEN 1 ELSE 0 END) AS null_beck,
    SUM(CASE WHEN office_window NOT IN ('yes', 'no') THEN 1 ELSE 0 END) AS invalid_window,
    SUM(CASE WHEN beck_score < 0 THEN 1 ELSE 0 END) AS negative_beck,
    COUNT(DISTINCT emplpoyee_id) AS distinct_ids,
    COUNT(*) - COUNT(DISTINCT emplpoyee_id) AS duplicate_ids
FROM employees;


-- ============================================================================
-- 9. Window Functions: Rank Employees by Beck Score Within Each Office Type
--    Shows the top employees by depression severity in each group.
-- ============================================================================

SELECT
    emplpoyee_id,
    office_window,
    beck_score,
    RANK() OVER (PARTITION BY office_window ORDER BY beck_score DESC) AS rank_within_group,
    DENSE_RANK() OVER (PARTITION BY office_window ORDER BY beck_score DESC) AS dense_rank_within_group,
    NTILE(4) OVER (PARTITION BY office_window ORDER BY beck_score) AS quartile
FROM employees
ORDER BY office_window, rank_within_group
LIMIT 20;
