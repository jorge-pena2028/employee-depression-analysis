# Employee Depression Analysis: Natural Light and the Beck Depression Inventory

## Project Overview

This project investigates whether access to natural light through office windows is associated with differences in employee depression levels. Depression is measured using the **Beck Depression Inventory (BDI)**, a widely used 21-item self-report instrument for assessing the severity of depressive symptoms. The analysis combines statistical testing in R with structured data querying in SQL to provide a thorough, reproducible examination of the relationship between workspace environment and mental health outcomes.

## Data Description

The dataset (`employee_data.csv`) contains **800 employee records** with three variables:

| Column | Type | Description |
|---|---|---|
| `emplpoyee_id` | Integer (1--800) | Unique employee identifier |
| `office_window` | String (`yes`/`no`) | Whether the employee's office has a window |
| `beck_score` | Integer | Beck Depression Inventory score |

BDI score interpretation guidelines:
- **0--9**: Minimal depression
- **10--18**: Mild depression
- **19--29**: Moderate depression
- **30+**: Severe depression

## Methodology

### R Analysis (`analysis.R`)

The R script performs the full statistical analysis pipeline:

1. **Data Loading and Quality Audit** -- Reads the CSV, checks for missing values, duplicates, and out-of-range entries.
2. **Descriptive Statistics** -- Computes mean, median, standard deviation, and quartiles of Beck scores for employees with and without office windows.
3. **Data Visualization** -- Generates five publication-quality plots:
   - Overlapping histogram of Beck scores by office type
   - Boxplot comparing Beck score distributions
   - Density plot with group means
   - Bar chart of mean Beck scores with 95% confidence interval error bars
   - Violin plot with jittered individual data points
4. **Assumption Checking** -- Tests normality (Shapiro-Wilk) and equality of variances (F-test) prior to hypothesis testing.
5. **Hypothesis Testing** -- Performs both Welch's and Student's two-sample t-tests to compare mean Beck scores between the window and no-window groups.
6. **Effect Size** -- Calculates Cohen's d to quantify the practical significance of any observed difference.
7. **Policy Recommendation** -- Provides evidence-based workplace recommendations.

### SQL Analysis (`sql/`)

SQL plays a prominent role in this project, demonstrating how relational database techniques can support and complement statistical analysis. The SQL component includes:

- **Schema Design** (`create_tables.sql`): Table definition with a primary key, NOT NULL constraints, and CHECK constraints that enforce valid values for `office_window` and non-negative `beck_score`. Indexes on `office_window` and `beck_score` optimize query performance.

- **Data Import** (`load_data.sql`): COPY statements for PostgreSQL (with a MySQL alternative) to load the CSV data, plus verification queries.

- **Analytical Queries** (`analysis_queries.sql`): Nine queries that mirror and extend the R analysis:

| Query | Description |
|---|---|
| 1. Descriptive Statistics | Mean, median, SD, min, max of Beck scores by office type |
| 2. Counts and Proportions | Employee distribution across office types |
| 3. Distribution Buckets | Beck score frequency in clinically meaningful ranges (0--5, 6--10, 11--15, 16--20, 21+) |
| 4. Direct Comparison | Side-by-side window vs. no-window means with computed difference |
| 5. Percentile Analysis | P25, P50, P75, P90, P95 of Beck scores by office type |
| 6. T-Test Summary Statistics | Group means, SDs, counts, standard error, and approximate t-statistic computed entirely in SQL |
| 7. High-Risk Identification | Employees with Beck score > 20 (moderate-severe depression), with group-level prevalence rates |
| 8. Missing Data Audit | NULL checks, invalid value detection, and duplicate ID identification |
| 9. Window Functions | RANK, DENSE_RANK, and NTILE to rank employees by Beck score within each office type |

## How to Run

**Prerequisites:** R (>= 4.0) with packages `ggplot2`, `dplyr`, and `readr`.

```bash
cd employee-depression-analysis

# Run the full analysis
Rscript analysis.R
```

Plots are saved to the `output/` directory. Statistical results and policy recommendations are printed to the console.

To run the SQL queries, load the schema and data into PostgreSQL (or adapt for your RDBMS), then execute the queries in `sql/analysis_queries.sql`.

## Project Structure

```
employee-depression-analysis/
├── README.md                    # Project documentation
├── .gitignore                   # Git ignore rules
├── analysis.R                   # Main R analysis script
├── employee_data.csv            # Dataset (800 employee records)
├── output/                      # Visualization output directory
│   ├── histogram_beck_scores.png
│   ├── boxplot_beck_scores.png
│   ├── density_beck_scores.png
│   ├── barchart_mean_beck.png
│   └── violin_beck_scores.png
└── sql/                         # SQL-based analysis
    ├── create_tables.sql        # Table DDL with constraints and indexes
    ├── load_data.sql            # CSV import statements
    └── analysis_queries.sql     # 9 analytical queries
```

## Key Findings and Policy Recommendation

The analysis examines whether employees with office windows report different Beck Depression Inventory scores compared to those without windows. Statistical testing (Welch's t-test) and effect size estimation (Cohen's d) are used to evaluate both the statistical and practical significance of any observed difference.

Based on the results, the project recommends:

1. Prioritize window-adjacent seating in office floor plans.
2. Where windows are unavailable, invest in full-spectrum lighting that mimics natural daylight.
3. Implement flexible seating rotations to provide equitable access to natural light.
4. Incorporate natural light considerations into broader workplace wellness initiatives.
5. Conduct a follow-up longitudinal study to evaluate causal effects of lighting changes on depression outcomes.
