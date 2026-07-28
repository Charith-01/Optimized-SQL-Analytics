# Query Performance Comparison

## Overview

This document compares the MySQL execution plans before and after adding indexes to selected analytical queries.

The comparison focuses on:

- Access type
- Index used
- Estimated rows examined
- Extra execution information

The joined child tables already used efficient unique-key lookups through their foreign-key-related unique indexes. Therefore, the main performance improvements occurred in the `employees` and `candidates` tables.

---

## Query 1 — Employee Attrition Analysis

### Purpose

Analyze employees with attrition status `Yes`, grouped by department, while combining employee and performance data.

| Measurement | Before Indexing | After Indexing |
|---|---|---|
| Access type | `ALL` | `ref` |
| Index used | `NULL` | `idx_employees_attrition` |
| Estimated rows | `200` | `6` |
| Extra information | `Using where; Using temporary` | `Using temporary` |

### Interpretation

Before indexing, MySQL performed a full table scan on the `employees` table and estimated that it would examine all 200 rows.

After adding the attrition index, MySQL used `idx_employees_attrition`. The estimated number of examined employee rows decreased from 200 to 6.

The query continued to use a temporary table because it contains a `GROUP BY department` operation.

The joined `employee_performance` table used the unique index `uq_employee_performance` with an `eq_ref` access type in both execution plans. This indicates an efficient single-row lookup for each matched employee.

---

## Query 2 — Department and Attrition Filter

### Purpose

Filter employees by both department and attrition status, join their performance records, and sort the result by KPI.

| Measurement | Before Indexing | After Indexing |
|---|---|---|
| Access type | `ALL` | `ref` |
| Index used | `NULL` | `idx_employees_department_attrition` |
| Estimated rows | `200` | `1` |
| Extra information | `Using where; Using temporary; Using filesort` | `Using temporary; Using filesort` |

### Interpretation

Before indexing, MySQL scanned all 200 rows in the `employees` table.

After optimization, MySQL selected the composite index `idx_employees_department_attrition`. This reduced the estimated number of employee rows examined from 200 to 1.

The composite index is suitable because the query filters using both:

```sql
department = 'Engineering'
AND attrition = 'Yes'
```

`Using filesort` remained because the query sorts by `p.kpi`, which belongs to the joined `employee_performance` table rather than the indexed `employees` table.

The joined performance table continued to use the unique index `uq_employee_performance` with the efficient `eq_ref` access type.

---

## Query 3 — Recruitment Status Analysis

### Purpose

Analyze hired candidates by position and calculate their average skill-match score.

| Measurement | Before Indexing | After Indexing |
|---|---|---|
| Access type | `ALL` | `ref` |
| Index used | `NULL` | `idx_candidates_recruitment_status` |
| Estimated rows | `200` | `63` |
| Extra information | `Using where; Using temporary` | `Using temporary` |

### Interpretation

Before indexing, MySQL performed a full scan of the `candidates` table and estimated that it would examine all 200 rows.

After adding the recruitment-status index, MySQL used `idx_candidates_recruitment_status`. The estimated number of rows examined decreased from 200 to 63.

The temporary table remained because the query groups results by position and recruitment status.

The joined `candidate_recommendations` table used the unique index `uq_candidate_recommendation` with an `eq_ref` access type in both plans. This means MySQL efficiently retrieved one matching recommendation row for each candidate.

---

## Query 4 — Candidate Score Filter

### Purpose

Filter candidates by position and minimum technical score, join their recommendation details, and sort the result by technical score.

| Measurement | Before Indexing | After Indexing |
|---|---|---|
| Access type | `ALL` | `ref` |
| Index used | `NULL` | `idx_candidates_position` |
| Estimated rows | `200` | `1` |
| Extra information | `Using where; Using filesort` | `Using where; Using filesort` |

### Interpretation

Before indexing, MySQL scanned all 200 rows in the `candidates` table.

After optimization, MySQL used `idx_candidates_position`, reducing the estimated number of candidate rows examined from 200 to 1.

`Using where` remained because the query also filters using:

```sql
technical_score >= 70
```

The selected index covers `position` but does not directly cover `technical_score`.

`Using filesort` also remained because MySQL still needed to sort the filtered rows by technical score.

The joined recommendation table continued to use `uq_candidate_recommendation` with the efficient `eq_ref` access type.

---

## Overall Findings

The execution-plan comparison shows that indexing improved the main table access method from a full table scan, represented by `ALL`, to an indexed reference lookup, represented by `ref`.

| Query | Before Indexing | After Indexing | Estimated Reduction |
|---|---:|---:|---:|
| Employee attrition analysis | 200 | 6 | 194 rows |
| Department and attrition filter | 200 | 1 | 199 rows |
| Recruitment status analysis | 200 | 63 | 137 rows |
| Candidate score filter | 200 | 1 | 199 rows |

The most significant improvements occurred in queries that used selective filters supported by matching indexes.

The foreign-key relationships were already efficient because:

- `employee_performance.employee_id` used `uq_employee_performance`
- `candidate_recommendations.candidate_id` used `uq_candidate_recommendation`

Both joined tables used `eq_ref`, which is an efficient join access method for unique-key lookups.

Some execution plans continued to show temporary tables or file sorting because the queries contained `GROUP BY` or `ORDER BY` operations. These operations are not always removed simply by adding filter indexes.

---

## Recommended Additional Optimization

The candidate score query currently uses:

```sql
WHERE c.position = 'Developer'
  AND c.technical_score >= 70
ORDER BY c.technical_score DESC;
```

The current index covers only the `position` column. A composite index can better support both the equality filter and the technical-score range:

```sql
CREATE INDEX idx_candidates_position_technical_score
ON candidates(position, technical_score);
```

After creating the index, the same query should be tested again with `EXPLAIN` to confirm whether MySQL selects it.

---

## Conclusion

The indexing strategy successfully reduced the estimated number of rows examined and changed the main table access method from `ALL` to `ref` for all four tested queries.

Although the dataset contains only about 200 records per table, the execution plans demonstrate how suitable single-column and composite indexes can improve filtering and relational query performance.

The benefits of these indexes would become more significant as the database grows to contain thousands or millions of records.
