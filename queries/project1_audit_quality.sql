-- Project 1: Water Source Audit Quality Analysis
-- Author: Lissan_meles
-- Description: This project analyzes discrepancies between auditor reports
-- and water survey data to identify mistakes and employee performance.

------------------------------------------------------------
-- Step 1: Preview the data
------------------------------------------------------------
-- Get first 5 rows from the auditor_report table
SELECT *
FROM md_water_services.auditor_report
LIMIT 5;

-- Count total number of rows in auditor_report
SELECT COUNT(*) AS no_of_observations
FROM md_water_services.auditor_report;

------------------------------------------------------------
-- Step 2: Join auditor_report, visits, and water_quality
------------------------------------------------------------
-- Join tables to combine audit scores with survey scores
SELECT
    auditor_report.location_id,
    auditor_report.true_water_source_score,
    visits.record_id,
    water_quality.subjective_quality_score
FROM auditor_report
JOIN visits
    ON auditor_report.location_id = visits.location_id
JOIN water_quality
    ON visits.record_id = water_quality.record_id;

------------------------------------------------------------
-- Step 3: Compare audit vs surveyor scores
------------------------------------------------------------
-- Count number of matching scores when visit_count = 1
SELECT COUNT(*) AS num_equal_rows
FROM auditor_report
JOIN visits
    ON auditor_report.location_id = visits.location_id
JOIN water_quality
    ON visits.record_id = water_quality.record_id
WHERE auditor_report.true_water_source_score = water_quality.subjective_quality_score
  AND visits.visit_count = 1;

-- Get mismatched rows (auditor score vs survey score not equal)
SELECT
    auditor_report.location_id,
    auditor_report.true_water_source_score AS Audit_Score,
    visits.record_id,
    water_quality.subjective_quality_score AS Surveyor_Score
FROM auditor_report
JOIN visits
    ON auditor_report.location_id = visits.location_id
JOIN water_quality
    ON visits.record_id = water_quality.record_id
WHERE auditor_report.true_water_source_score <> water_quality.subjective_quality_score;

------------------------------------------------------------
-- Step 4: Add employee information
------------------------------------------------------------
-- Find mismatches with employee details
SELECT
    auditor_report.location_id,
    auditor_report.true_water_source_score AS Audit_Score,
    auditor_report.type_of_water_source AS Auditor_source,
    employee.employee_name AS Employee_Name,
    visits.record_id,
    water_quality.subjective_quality_score AS Surveyor_Score
FROM auditor_report
JOIN visits
    ON auditor_report.location_id = visits.location_id
JOIN water_quality
    ON visits.record_id = water_quality.record_id
JOIN employee
    ON employee.assigned_employee_id = visits.assigned_employee_id
WHERE auditor_report.true_water_source_score <> water_quality.subjective_quality_score;

------------------------------------------------------------
-- Step 5: Create a view of incorrect records
------------------------------------------------------------
CREATE OR REPLACE VIEW Incorrect_records_ed AS
SELECT
    auditor_report.location_id,
    auditor_report.true_water_source_score AS Audit_Score,
    auditor_report.statements,
    auditor_report.type_of_water_source AS Auditor_source,
    employee.employee_name AS Employee_Name,
    visits.record_id,
    water_quality.subjective_quality_score AS Surveyor_Score
FROM auditor_report
JOIN visits
    ON auditor_report.location_id = visits.location_id
JOIN water_quality
    ON visits.record_id = water_quality.record_id
JOIN employee
    ON employee.assigned_employee_id = visits.assigned_employee_id
WHERE auditor_report.true_water_source_score <> water_quality.subjective_quality_score
  AND visits.visit_count = 1;

-- Preview the incorrect records
SELECT * FROM Incorrect_records_ed;

------------------------------------------------------------
-- Step 6: Count mistakes per employee
------------------------------------------------------------
SELECT 
    Employee_Name,
    COUNT(*) AS mistake_count
FROM Incorrect_records_ed
GROUP BY Employee_Name
ORDER BY mistake_count DESC;

------------------------------------------------------------
-- Step 7: Find employees above the average mistake count
------------------------------------------------------------
WITH mistake_count_per_employee AS (
    SELECT 
        Employee_Name,
        COUNT(*) AS mistake_count
    FROM Incorrect_records_ed
    GROUP BY Employee_Name
),
avg_mistakes AS (
    SELECT AVG(mistake_count) AS avg_mistake_count
    FROM mistake_count_per_employee
)
SELECT 
    m.Employee_Name,
    m.mistake_count
FROM mistake_count_per_employee m
CROSS JOIN avg_mistakes a
WHERE m.mistake_count > a.avg_mistake_count
ORDER BY m.mistake_count DESC;

------------------------------------------------------------
-- END OF PROJECT 1
------------------------------------------------------------
