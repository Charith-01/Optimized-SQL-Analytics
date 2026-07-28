USE optimized_sql_analytics;

-- =========================================================
-- Optimized Query 1
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
-- Optimized Query 2
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
-- Optimized Query 3
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
-- Optimized Query 4
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