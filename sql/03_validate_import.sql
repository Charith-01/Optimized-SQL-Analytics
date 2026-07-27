USE optimized_sql_analytics;

-- Validate row counts.

SELECT
    'employees' AS table_name,
    COUNT(*) AS row_count
FROM employees

UNION ALL

SELECT
    'employee_performance',
    COUNT(*)
FROM employee_performance

UNION ALL

SELECT
    'candidates',
    COUNT(*)
FROM candidates

UNION ALL

SELECT
    'candidate_recommendations',
    COUNT(*)
FROM candidate_recommendations;


-- Validate employee relationship.

SELECT
    e.employee_id,
    e.employee_code,
    e.department,
    p.kpi,
    p.attendance,
    p.rating
FROM employees e
INNER JOIN employee_performance p
    ON e.employee_id = p.employee_id
LIMIT 10;


-- Validate candidate relationship.

SELECT
    c.candidate_id,
    c.candidate_code,
    c.position,
    c.recruitment_status,
    r.skill_match,
    r.recommendation_level
FROM candidates c
INNER JOIN candidate_recommendations r
    ON c.candidate_id = r.candidate_id
LIMIT 10;