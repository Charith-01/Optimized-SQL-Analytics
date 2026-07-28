USE optimized_sql_analytics;

-- =========================================================
-- Finding 1: Department attrition and performance summary
-- =========================================================

SELECT
    e.department,
    COUNT(*) AS employee_count,
    ROUND(AVG(e.salary), 2) AS average_salary,
    ROUND(AVG(e.job_satisfaction), 2)
        AS average_job_satisfaction,
    ROUND(AVG(p.kpi), 2) AS average_kpi,
    ROUND(AVG(p.attendance), 2) AS average_attendance,
    SUM(
        CASE
            WHEN e.attrition = 'Yes' THEN 1
            ELSE 0
        END
    ) AS attrition_count,
    ROUND(
        SUM(
            CASE
                WHEN e.attrition = 'Yes' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS attrition_rate_percentage
FROM employees AS e
INNER JOIN employee_performance AS p
    ON e.employee_id = p.employee_id
GROUP BY e.department
ORDER BY attrition_rate_percentage DESC;


-- =========================================================
-- Finding 2: Compare employees who stayed and left
-- =========================================================

SELECT
    e.attrition,
    COUNT(*) AS employee_count,
    ROUND(AVG(e.salary), 2) AS average_salary,
    ROUND(AVG(e.job_satisfaction), 2)
        AS average_job_satisfaction,
    ROUND(AVG(e.performance_score), 2)
        AS average_performance_score,
    ROUND(AVG(p.kpi), 2) AS average_kpi,
    ROUND(AVG(p.attendance), 2) AS average_attendance
FROM employees AS e
INNER JOIN employee_performance AS p
    ON e.employee_id = p.employee_id
GROUP BY e.attrition;


-- =========================================================
-- Finding 3: Employee risk distribution
-- =========================================================

WITH employee_risk_data AS (
    SELECT
        e.employee_id,
        CASE
            WHEN e.job_satisfaction <= 2
             AND p.kpi < 50
             AND p.attendance < 60
                THEN 'High Risk'

            WHEN e.job_satisfaction <= 2
              OR p.kpi < 50
              OR p.attendance < 60
                THEN 'Medium Risk'

            ELSE 'Low Risk'
        END AS risk_level
    FROM employees AS e
    INNER JOIN employee_performance AS p
        ON e.employee_id = p.employee_id
)
SELECT
    risk_level,
    COUNT(*) AS employee_count,
    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (),
        2
    ) AS employee_percentage
FROM employee_risk_data
GROUP BY risk_level
ORDER BY employee_count DESC;


-- =========================================================
-- Finding 4: Recruitment performance by position
-- =========================================================

SELECT
    c.position,
    COUNT(*) AS total_candidates,
    ROUND(AVG(c.experience_years), 2)
        AS average_experience,
    ROUND(AVG(c.technical_score), 2)
        AS average_technical_score,
    ROUND(AVG(c.interview_score), 2)
        AS average_interview_score,
    ROUND(AVG(r.skill_match), 2)
        AS average_skill_match,
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
-- Finding 5: Score comparison by recruitment status
-- =========================================================

SELECT
    c.recruitment_status,
    COUNT(*) AS candidate_count,
    ROUND(AVG(c.technical_score), 2)
        AS average_technical_score,
    ROUND(AVG(c.interview_score), 2)
        AS average_interview_score,
    ROUND(AVG(r.skill_match), 2)
        AS average_skill_match
FROM candidates AS c
INNER JOIN candidate_recommendations AS r
    ON c.candidate_id = r.candidate_id
GROUP BY c.recruitment_status
ORDER BY c.recruitment_status;


-- =========================================================
-- Finding 6: Top ten candidates by composite score
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
    recruitment_status
FROM candidate_scores
ORDER BY composite_score DESC
LIMIT 10;