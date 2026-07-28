USE optimized_sql_analytics;

-- =========================================================
-- Query 1: Rank employees by KPI within each department
-- Purpose:
-- Identify the highest-performing employees
-- in every department.
-- =========================================================

SELECT
    e.employee_code,
    e.department,
    e.role,
    p.kpi,
    p.attendance,
    DENSE_RANK() OVER (
        PARTITION BY e.department
        ORDER BY p.kpi DESC
    ) AS department_kpi_rank
FROM employees AS e
INNER JOIN employee_performance AS p
    ON e.employee_id = p.employee_id
ORDER BY
    e.department,
    department_kpi_rank,
    e.employee_code;
    
    
-- =========================================================
-- Query 2: Top three employees by department
-- Purpose:
-- Return only the top three KPI ranks
-- from each department.
-- =========================================================

WITH ranked_employees AS (
    SELECT
        e.employee_code,
        e.department,
        e.role,
        p.kpi,
        p.attendance,
        DENSE_RANK() OVER (
            PARTITION BY e.department
            ORDER BY p.kpi DESC
        ) AS department_kpi_rank
    FROM employees AS e
    INNER JOIN employee_performance AS p
        ON e.employee_id = p.employee_id
)
SELECT
    employee_code,
    department,
    role,
    kpi,
    attendance,
    department_kpi_rank
FROM ranked_employees
WHERE department_kpi_rank <= 3
ORDER BY
    department,
    department_kpi_rank,
    employee_code;
    

-- =========================================================
-- Query 3: Employee KPI versus department average
-- Purpose:
-- Compare every employee's KPI with the average KPI
-- of their department.
-- =========================================================

SELECT
    e.employee_code,
    e.department,
    p.kpi,
    ROUND(
        AVG(p.kpi) OVER (
            PARTITION BY e.department
        ),
        2
    ) AS department_average_kpi,
    ROUND(
        p.kpi
        - AVG(p.kpi) OVER (
            PARTITION BY e.department
        ),
        2
    ) AS difference_from_department_average
FROM employees AS e
INNER JOIN employee_performance AS p
    ON e.employee_id = p.employee_id
ORDER BY
    e.department,
    difference_from_department_average DESC;
    
    
-- =========================================================
-- Query 4: Employee salary ranking by department
-- Purpose:
-- Rank employees by salary within each department.
-- =========================================================

SELECT
    employee_code,
    department,
    role,
    salary,
    RANK() OVER (
        PARTITION BY department
        ORDER BY salary DESC
    ) AS department_salary_rank
FROM employees
ORDER BY
    department,
    department_salary_rank,
    employee_code;
    
    
-- =========================================================
-- Query 5: Employee salary quartiles
-- Purpose:
-- Divide employees into four salary groups
-- within each department.
-- =========================================================

SELECT
    employee_code,
    department,
    role,
    salary,
    NTILE(4) OVER (
        PARTITION BY department
        ORDER BY salary DESC
    ) AS salary_quartile
FROM employees
ORDER BY
    department,
    salary_quartile,
    salary DESC;
    
    
-- =========================================================
-- Query 6: Candidate ranking by position
-- Purpose:
-- Rank candidates using technical score,
-- interview score, and skill match.
-- =========================================================

SELECT
    c.candidate_code,
    c.position,
    c.technical_score,
    c.interview_score,
    r.skill_match,
    c.recruitment_status,
    DENSE_RANK() OVER (
        PARTITION BY c.position
        ORDER BY
            c.technical_score DESC,
            c.interview_score DESC,
            r.skill_match DESC
    ) AS position_rank
FROM candidates AS c
INNER JOIN candidate_recommendations AS r
    ON c.candidate_id = r.candidate_id
ORDER BY
    c.position,
    position_rank,
    c.candidate_code;
    
    
-- =========================================================
-- Query 7: Candidate composite-score ranking
-- Purpose:
-- Calculate and rank candidate composite scores
-- within each job position.
-- =========================================================

WITH candidate_scores AS (
    SELECT
        c.candidate_code,
        c.position,
        c.recruitment_status,
        c.technical_score,
        c.interview_score,
        r.skill_match,
        (
            c.technical_score * 0.40
            + c.interview_score * 0.30
            + r.skill_match * 0.30
        ) AS composite_score
    FROM candidates AS c
    INNER JOIN candidate_recommendations AS r
        ON c.candidate_id = r.candidate_id
)
SELECT
    candidate_code,
    position,
    technical_score,
    interview_score,
    skill_match,
    ROUND(composite_score, 2) AS composite_score,
    recruitment_status,
    DENSE_RANK() OVER (
        PARTITION BY position
        ORDER BY composite_score DESC
    ) AS position_composite_rank
FROM candidate_scores
ORDER BY
    position,
    position_composite_rank,
    candidate_code;
    
    
-- =========================================================
-- Query 8: Top five candidates per position
-- Purpose:
-- Return only the five highest composite-score ranks
-- for every position.
-- =========================================================

WITH candidate_scores AS (
    SELECT
        c.candidate_code,
        c.position,
        c.recruitment_status,
        (
            c.technical_score * 0.40
            + c.interview_score * 0.30
            + r.skill_match * 0.30
        ) AS composite_score
    FROM candidates AS c
    INNER JOIN candidate_recommendations AS r
        ON c.candidate_id = r.candidate_id
),
ranked_candidates AS (
    SELECT
        candidate_code,
        position,
        recruitment_status,
        composite_score,
        DENSE_RANK() OVER (
            PARTITION BY position
            ORDER BY composite_score DESC
        ) AS position_rank
    FROM candidate_scores
)
SELECT
    candidate_code,
    position,
    ROUND(composite_score, 2) AS composite_score,
    recruitment_status,
    position_rank
FROM ranked_candidates
WHERE position_rank <= 5
ORDER BY
    position,
    position_rank,
    candidate_code;
    
    
-- =========================================================
-- Query 9: Candidate technical score versus position average
-- Purpose:
-- Compare each candidate's technical score
-- with the average score for that position.
-- =========================================================

SELECT
    candidate_code,
    position,
    technical_score,
    ROUND(
        AVG(technical_score) OVER (
            PARTITION BY position
        ),
        2
    ) AS position_average_technical_score,
    ROUND(
        technical_score
        - AVG(technical_score) OVER (
            PARTITION BY position
        ),
        2
    ) AS difference_from_position_average
FROM candidates
ORDER BY
    position,
    difference_from_position_average DESC;
    
    
-- =========================================================
-- Query 10: Recruitment-status distribution
-- Purpose:
-- Calculate the number and percentage of candidates
-- in each recruitment status.
-- =========================================================

SELECT
    recruitment_status,
    COUNT(*) AS candidate_count,
    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_candidates
FROM candidates
GROUP BY recruitment_status
ORDER BY candidate_count DESC;