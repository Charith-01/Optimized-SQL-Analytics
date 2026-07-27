USE optimized_sql_analytics;

-- Remove child tables first if the script is rerun.
DROP TABLE IF EXISTS employee_performance;
DROP TABLE IF EXISTS candidate_recommendations;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS candidates;


-- =====================================================
-- Employees
-- Source: Employee_Attrition sheet
-- =====================================================

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_code VARCHAR(10) NOT NULL UNIQUE,
    age INT NOT NULL,
    department VARCHAR(50) NOT NULL,
    role VARCHAR(50) NOT NULL,
    years_of_service INT NOT NULL,
    salary DECIMAL(12, 2) NOT NULL,
    job_satisfaction INT NOT NULL,
    performance_score INT NOT NULL,
    attrition VARCHAR(10) NOT NULL,

    CONSTRAINT chk_employee_age
        CHECK (age >= 18),

    CONSTRAINT chk_years_of_service
        CHECK (years_of_service >= 0),

    CONSTRAINT chk_salary
        CHECK (salary >= 0),

    CONSTRAINT chk_job_satisfaction
        CHECK (job_satisfaction BETWEEN 1 AND 5),

    CONSTRAINT chk_performance_score
        CHECK (performance_score BETWEEN 1 AND 5),

    CONSTRAINT chk_attrition
        CHECK (attrition IN ('Yes', 'No'))
);


-- =====================================================
-- Employee performance
-- Source: Performance sheet
-- =====================================================

CREATE TABLE employee_performance (
    performance_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    kpi INT NOT NULL,
    attendance INT NOT NULL,
    rating VARCHAR(20) NOT NULL,

    CONSTRAINT uq_employee_performance
        UNIQUE (employee_id),

    CONSTRAINT fk_employee_performance
        FOREIGN KEY (employee_id)
        REFERENCES employees(employee_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT chk_kpi
        CHECK (kpi BETWEEN 0 AND 100),

    CONSTRAINT chk_attendance
        CHECK (attendance BETWEEN 0 AND 100)
);


-- =====================================================
-- Candidates
-- Source: Recruitment sheet
-- =====================================================

CREATE TABLE candidates (
    candidate_id INT PRIMARY KEY,
    candidate_code VARCHAR(10) NOT NULL UNIQUE,
    position VARCHAR(20) NOT NULL,
    experience_years INT NOT NULL,
    technical_score INT NOT NULL,
    interview_score INT NOT NULL,
    recruitment_status VARCHAR(20) NOT NULL,

    CONSTRAINT chk_candidate_experience
        CHECK (experience_years >= 0),

    CONSTRAINT chk_technical_score
        CHECK (technical_score BETWEEN 0 AND 100),

    CONSTRAINT chk_interview_score
        CHECK (interview_score BETWEEN 0 AND 100),

    CONSTRAINT chk_recruitment_status
        CHECK (
            recruitment_status IN (
                'Hired',
                'Rejected',
                'Pending'
            )
        )
);


-- =====================================================
-- Candidate recommendations
-- Source: Recommendation sheet
-- =====================================================

CREATE TABLE candidate_recommendations (
    recommendation_id INT AUTO_INCREMENT PRIMARY KEY,
    candidate_id INT NOT NULL,
    skill_match INT NOT NULL,
    recommendation_experience INT NOT NULL,
    recommendation_level VARCHAR(20) NOT NULL,

    CONSTRAINT uq_candidate_recommendation
        UNIQUE (candidate_id),

    CONSTRAINT fk_candidate_recommendation
        FOREIGN KEY (candidate_id)
        REFERENCES candidates(candidate_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT chk_skill_match
        CHECK (skill_match BETWEEN 0 AND 100),

    CONSTRAINT chk_recommendation_experience
        CHECK (recommendation_experience >= 0)
);


DESCRIBE employees;
DESCRIBE employee_performance;
DESCRIBE candidates;
DESCRIBE candidate_recommendations;