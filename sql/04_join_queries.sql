USE optimized_sql_analytics;

-- =========================================================
-- Query 1: Employee details with performance information
-- Purpose:
-- Combine employee information with KPI, attendance,
-- and rating information.
-- =========================================================

SELECT
    e.employee_id,
    e.employee_code,
    e.department,
    e.role,
    e.salary,
    e.job_satisfaction,
    e.performance_score,
    e.attrition,
    p.kpi,
    p.attendance,
    p.rating
FROM employees AS e
INNER JOIN employee_performance AS p
    ON e.employee_id = p.employee_id
ORDER BY e.employee_id;


-- =========================================================
-- Query 2: Department performance summary
-- Purpose:
-- Compare average KPI, attendance, salary,
-- and job satisfaction by department.
-- =========================================================

SELECT
    e.department,
    COUNT(*) AS employee_count,
    ROUND(AVG(e.salary), 2) AS average_salary,
    ROUND(AVG(e.job_satisfaction), 2) AS average_job_satisfaction,
    ROUND(AVG(p.kpi), 2) AS average_kpi,
    ROUND(AVG(p.attendance), 2) AS average_attendance
FROM employees AS e
INNER JOIN employee_performance AS p
    ON e.employee_id = p.employee_id
GROUP BY e.department
ORDER BY average_kpi DESC;


-- =========================================================
-- Query 3: Performance comparison by attrition status
-- Purpose:
-- Compare employees who stayed with employees who left.
-- =========================================================

SELECT
    e.attrition,
    COUNT(*) AS employee_count,
    ROUND(AVG(e.salary), 2) AS average_salary,
    ROUND(AVG(e.job_satisfaction), 2) AS average_job_satisfaction,
    ROUND(AVG(e.performance_score), 2) AS average_performance_score,
    ROUND(AVG(p.kpi), 2) AS average_kpi,
    ROUND(AVG(p.attendance), 2) AS average_attendance
FROM employees AS e
INNER JOIN employee_performance AS p
    ON e.employee_id = p.employee_id
GROUP BY e.attrition
ORDER BY e.attrition;


-- =========================================================
-- Query 4: Employees requiring management attention
-- Purpose:
-- Identify employees with low satisfaction,
-- low KPI, or low attendance.
-- =========================================================

SELECT
    e.employee_code,
    e.department,
    e.role,
    e.job_satisfaction,
    e.performance_score,
    p.kpi,
    p.attendance,
    p.rating,
    e.attrition
FROM employees AS e
INNER JOIN employee_performance AS p
    ON e.employee_id = p.employee_id
WHERE e.job_satisfaction <= 2
   OR p.kpi < 50
   OR p.attendance < 60
ORDER BY
    e.job_satisfaction ASC,
    p.kpi ASC,
    p.attendance ASC;
    
    
-- =========================================================
-- Query 5: Candidate recruitment and recommendation details
-- Purpose:
-- Combine recruitment results with recommendation data.
-- =========================================================

SELECT
    c.candidate_id,
    c.candidate_code,
    c.position,
    c.experience_years,
    c.technical_score,
    c.interview_score,
    c.recruitment_status,
    r.skill_match,
    r.recommendation_experience,
    r.recommendation_level
FROM candidates AS c
INNER JOIN candidate_recommendations AS r
    ON c.candidate_id = r.candidate_id
ORDER BY c.candidate_id;


-- =========================================================
-- Query 6: Recruitment summary by position
-- Purpose:
-- Compare candidate scores and hiring results by position.
-- =========================================================

SELECT
    c.position,
    COUNT(*) AS total_candidates,
    ROUND(AVG(c.experience_years), 2) AS average_experience,
    ROUND(AVG(c.technical_score), 2) AS average_technical_score,
    ROUND(AVG(c.interview_score), 2) AS average_interview_score,
    ROUND(AVG(r.skill_match), 2) AS average_skill_match,
    SUM(
        CASE
            WHEN c.recruitment_status = 'Hired' THEN 1
            ELSE 0
        END
    ) AS hired_candidates
FROM candidates AS c
INNER JOIN candidate_recommendations AS r
    ON c.candidate_id = r.candidate_id
GROUP BY c.position
ORDER BY hired_candidates DESC;


-- =========================================================
-- Query 7: Hiring conversion rate by position
-- Purpose:
-- Calculate the percentage of candidates hired
-- for each job position.
-- =========================================================

SELECT
    c.position,
    COUNT(*) AS total_candidates,
    SUM(
        CASE
            WHEN c.recruitment_status = 'Hired' THEN 1
            ELSE 0
        END
    ) AS hired_candidates,
    ROUND(
        SUM(
            CASE
                WHEN c.recruitment_status = 'Hired' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS hiring_rate_percentage
FROM candidates AS c
INNER JOIN candidate_recommendations AS r
    ON c.candidate_id = r.candidate_id
GROUP BY c.position
ORDER BY hiring_rate_percentage DESC;


-- =========================================================
-- Query 8: Strong candidates who were not hired
-- Purpose:
-- Identify non-hired candidates with a strong overall score
-- who may deserve additional review.
-- =========================================================

SELECT
    c.candidate_code,
    c.position,
    c.technical_score,
    c.interview_score,
    r.skill_match,
    ROUND(
        (
            c.technical_score
            + c.interview_score
            + r.skill_match
        ) / 3.0,
        2
    ) AS average_candidate_score,
    c.recruitment_status
FROM candidates AS c
INNER JOIN candidate_recommendations AS r
    ON c.candidate_id = r.candidate_id
WHERE c.recruitment_status <> 'Hired'
  AND (
        c.technical_score
        + c.interview_score
        + r.skill_match
      ) / 3.0 >= 65
ORDER BY
    average_candidate_score DESC,
    c.technical_score DESC,
    c.interview_score DESC;