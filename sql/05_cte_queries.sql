USE optimized_sql_analytics;

-- =========================================================
-- Query 1: Department attrition analysis using a CTE
-- Purpose:
-- Calculate employee count, attrition count,
-- and attrition percentage by department.
-- =========================================================

WITH department_attrition AS (
    SELECT
        department,
        COUNT(*) AS total_employees,
        SUM(
            CASE
                WHEN attrition = 'Yes' THEN 1
                ELSE 0
            END
        ) AS attrition_count
    FROM employees
    GROUP BY department
)
SELECT
    department,
    total_employees,
    attrition_count,
    ROUND(
        attrition_count * 100.0 / total_employees,
        2
    ) AS attrition_rate_percentage
FROM department_attrition
ORDER BY attrition_rate_percentage DESC;