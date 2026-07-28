USE optimized_sql_analytics;

-- =========================================================
-- Employee indexes
-- =========================================================

-- Supports filtering and grouping by department.
CREATE INDEX idx_employees_department
ON employees(department);

-- Supports filtering by attrition status.
CREATE INDEX idx_employees_attrition
ON employees(attrition);

-- Supports queries filtering by both department and attrition.
CREATE INDEX idx_employees_department_attrition
ON employees(department, attrition);

-- Supports job-satisfaction filtering.
CREATE INDEX idx_employees_job_satisfaction
ON employees(job_satisfaction);


-- =========================================================
-- Employee performance indexes
-- =========================================================

-- employee_id is already unique, but this explicitly supports
-- the employee-performance relationship if required.
-- Do not create another index if the UNIQUE constraint already
-- created one automatically.

-- Supports KPI filtering and sorting.
CREATE INDEX idx_employee_performance_kpi
ON employee_performance(kpi);

-- Supports attendance filtering.
CREATE INDEX idx_employee_performance_attendance
ON employee_performance(attendance);


-- =========================================================
-- Candidate indexes
-- =========================================================

-- Supports grouping and filtering by position.
CREATE INDEX idx_candidates_position
ON candidates(position);

-- Supports filtering by recruitment status.
CREATE INDEX idx_candidates_recruitment_status
ON candidates(recruitment_status);

-- Supports position and status analytical queries.
CREATE INDEX idx_candidates_position_status
ON candidates(position, recruitment_status);

-- Supports technical-score filtering and sorting.
CREATE INDEX idx_candidates_technical_score
ON candidates(technical_score);


-- =========================================================
-- Recommendation indexes
-- =========================================================

-- Supports skill-match filtering and sorting.
CREATE INDEX idx_recommendations_skill_match
ON candidate_recommendations(skill_match);

SHOW INDEXES FROM employees;
SHOW INDEXES FROM employee_performance;
SHOW INDEXES FROM candidates;
SHOW INDEXES FROM candidate_recommendations;