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


-- =========================================================
-- Query 2: Department performance and attrition report
-- Purpose:
-- Combine department-level performance measurements
-- with attrition information.
-- =========================================================

WITH department_metrics AS (
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
        ) AS attrition_count
    FROM employees AS e
    INNER JOIN employee_performance AS p
        ON e.employee_id = p.employee_id
    GROUP BY e.department
)
SELECT
    department,
    employee_count,
    average_salary,
    average_job_satisfaction,
    average_kpi,
    average_attendance,
    attrition_count,
    ROUND(
        attrition_count * 100.0 / employee_count,
        2
    ) AS attrition_rate_percentage
FROM department_metrics
ORDER BY attrition_rate_percentage DESC;


-- =========================================================
-- Query 3: High-risk employee analysis
-- Purpose:
-- Identify employees who meet several risk conditions.
-- =========================================================

WITH employee_risk_data AS (
    SELECT
        e.employee_code,
        e.department,
        e.role,
        e.job_satisfaction,
        e.performance_score,
        e.attrition,
        p.kpi,
        p.attendance,
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
    employee_code,
    department,
    role,
    job_satisfaction,
    performance_score,
    kpi,
    attendance,
    attrition,
    risk_level
FROM employee_risk_data
WHERE risk_level IN ('High Risk', 'Medium Risk')
ORDER BY
    CASE risk_level
        WHEN 'High Risk' THEN 1
        WHEN 'Medium Risk' THEN 2
        ELSE 3
    END,
    job_satisfaction ASC,
    kpi ASC,
    attendance ASC;
    
    
-- =========================================================
-- Query 4: Employee risk summary
-- Purpose:
-- Count employees in each calculated risk category.
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
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_employees
FROM employee_risk_data
GROUP BY risk_level
ORDER BY employee_count DESC;


-- =========================================================
-- Query 5: Candidate composite score
-- Purpose:
-- Calculate an overall candidate score using
-- technical, interview, and skill-match measurements.
-- =========================================================

WITH candidate_scores AS (
    SELECT
        c.candidate_code,
        c.position,
        c.technical_score,
        c.interview_score,
        r.skill_match,
        c.recruitment_status,
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
ORDER BY composite_score DESC;


-- =========================================================
-- Query 6: Strong candidates by position
-- Purpose:
-- Identify candidates with a composite score of 65 or more.
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
)
SELECT
    candidate_code,
    position,
    ROUND(composite_score, 2) AS composite_score,
    recruitment_status
FROM candidate_scores
WHERE composite_score >= 65
ORDER BY
    position,
    composite_score DESC;
    
    
-- =========================================================
-- Query 7: Recruitment conversion analysis
-- Purpose:
-- Calculate recruitment outcomes and hiring percentage
-- for every position.
-- =========================================================

WITH recruitment_summary AS (
    SELECT
        position,
        COUNT(*) AS total_candidates,
        SUM(
            CASE
                WHEN recruitment_status = 'Hired' THEN 1
                ELSE 0
            END
        ) AS hired_candidates,
        SUM(
            CASE
                WHEN recruitment_status = 'Rejected' THEN 1
                ELSE 0
            END
        ) AS rejected_candidates,
        SUM(
            CASE
                WHEN recruitment_status = 'Pending' THEN 1
                ELSE 0
            END
        ) AS pending_candidates
    FROM candidates
    GROUP BY position
)
SELECT
    position,
    total_candidates,
    hired_candidates,
    rejected_candidates,
    pending_candidates,
    ROUND(
        hired_candidates * 100.0 / total_candidates,
        2
    ) AS hiring_rate_percentage
FROM recruitment_summary
ORDER BY hiring_rate_percentage DESC;


-- =========================================================
-- Query 8: Candidate score comparison by hiring status
-- Purpose:
-- Compare average scores for hired, rejected,
-- and pending candidates.
-- =========================================================

WITH recruitment_score_summary AS (
    SELECT
        c.recruitment_status,
        COUNT(*) AS candidate_count,
        AVG(c.technical_score) AS average_technical_score,
        AVG(c.interview_score) AS average_interview_score,
        AVG(r.skill_match) AS average_skill_match
    FROM candidates AS c
    INNER JOIN candidate_recommendations AS r
        ON c.candidate_id = r.candidate_id
    GROUP BY c.recruitment_status
)
SELECT
    recruitment_status,
    candidate_count,
    ROUND(average_technical_score, 2)
        AS average_technical_score,
    ROUND(average_interview_score, 2)
        AS average_interview_score,
    ROUND(average_skill_match, 2)
        AS average_skill_match
FROM recruitment_score_summary
ORDER BY recruitment_status;