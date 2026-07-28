# Database ER Diagram

The relational database contains two analytical domains.

## Employee Analytics

The `employees` table stores employee master information.

The `employee_performance` table stores KPI, attendance, and rating data.

The tables are connected using `employee_id`.

## Recruitment Analytics

The `candidates` table stores candidate recruitment information.

The `candidate_recommendations` table stores skill-match and recommendation information.

The tables are connected using `candidate_id`.

Both child tables use unique foreign keys, resulting in one-to-one relationships in the current database design.