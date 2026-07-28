USE optimized_sql_analytics;

-- =========================================================
-- Baseline Query 1: Employee performance and attrition
-- Purpose:
-- Check the execution plan before adding indexes.
-- =========================================================

EXPLAIN
SELECT
    e.department,
    COUNT(*) AS employee_count,
    ROUND(AVG(p.kpi), 2) AS average_kpi,
    ROUND(AVG(p.attendance), 2) AS average_attendance
FROM employees AS e
INNER JOIN employee_performance AS p
    ON e.employee_id = p.employee_id
WHERE e.attrition = 'Yes'
GROUP BY e.department;


-- =========================================================
-- Baseline Query 2: Employees requiring attention
-- Purpose:
-- Check filtering and join performance.
-- =========================================================

EXPLAIN
SELECT
    e.employee_code,
    e.department,
    e.job_satisfaction,
    p.kpi,
    p.attendance
FROM employees AS e
INNER JOIN employee_performance AS p
    ON e.employee_id = p.employee_id
WHERE e.department = 'Engineering'
  AND e.attrition = 'Yes'
ORDER BY p.kpi DESC;


-- =========================================================
-- Baseline Query 3: Recruitment analysis
-- Purpose:
-- Check candidate filtering and join performance.
-- =========================================================

EXPLAIN
SELECT
    c.position,
    c.recruitment_status,
    COUNT(*) AS candidate_count,
    ROUND(AVG(r.skill_match), 2) AS average_skill_match
FROM candidates AS c
INNER JOIN candidate_recommendations AS r
    ON c.candidate_id = r.candidate_id
WHERE c.recruitment_status = 'Hired'
GROUP BY
    c.position,
    c.recruitment_status;


-- =========================================================
-- Baseline Query 4: Candidate score filtering
-- Purpose:
-- Check score-based filtering before optimization.
-- =========================================================

EXPLAIN
SELECT
    c.candidate_code,
    c.position,
    c.technical_score,
    c.interview_score,
    r.skill_match
FROM candidates AS c
INNER JOIN candidate_recommendations AS r
    ON c.candidate_id = r.candidate_id
WHERE c.position = 'Developer'
  AND c.technical_score >= 70
ORDER BY c.technical_score DESC;