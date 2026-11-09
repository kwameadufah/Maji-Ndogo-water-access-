-- Maji Ndogo water access, part 3
-- Database: md_water_services (MySQL). Load data/md_water_services.sql first.


-- Integrating the Report
SELECT 
    location_id,
    true_water_source_score
FROM auditor_report
LIMIT 10;


-- join the visits table to the auditor_report table
SELECT
    aud.location_id AS audit_location,
    aud.true_water_source_score,
    v.location_id AS visit_location,
    v.record_id

FROM auditor_report aud
JOIN visits v
    ON aud.location_id = v.location_id

LIMIT 10;

SELECT
    aud.location_id AS audit_location,
    aud.true_water_source_score,
    v.location_id AS visit_location,
    v.record_id,
    wq.subjective_quality_score

FROM auditor_report aud
JOIN visits v
    ON aud.location_id = v.location_id
JOIN water_quality wq
    ON v.record_id = wq.record_id

LIMIT 10;

SELECT
    aud.location_id AS location_id,
    v.record_id,
    aud.true_water_source_score as auditor_score,
    wq.subjective_quality_score as surveyor_score
    

FROM auditor_report aud
JOIN visits v
    ON aud.location_id = v.location_id
JOIN water_quality wq
    ON v.record_id = wq.record_id
LIMIT 10;

SELECT
    aud.location_id AS location_id,
    v.record_id,
    aud.true_water_source_score as auditor_score,
    wq.subjective_quality_score as surveyor_score
    

FROM auditor_report aud
JOIN visits v
    ON aud.location_id = v.location_id
JOIN water_quality wq
    ON v.record_id = wq.record_id
WHERE aud.true_water_source_score = wq.subjective_quality_score
limit 10;

SELECT
    aud.location_id AS location_id,
    v.record_id,
    aud.true_water_source_score as auditor_score,
    wq.subjective_quality_score as surveyor_score
    

FROM auditor_report aud
JOIN visits v
    ON aud.location_id = v.location_id
JOIN water_quality wq
    ON v.record_id = wq.record_id
WHERE aud.true_water_source_score = wq.subjective_quality_score
    AND v.visit_count = 1

LIMIT 10;

SELECT
    aud.location_id AS location_id,
    v.record_id,
    aud.true_water_source_score as auditor_score,
    wq.subjective_quality_score as surveyor_score
    

FROM auditor_report aud
JOIN visits v
    ON aud.location_id = v.location_id
JOIN water_quality wq
    ON v.record_id = wq.record_id
WHERE aud.true_water_source_score != wq.subjective_quality_score
    AND v.visit_count = 1
limit 10;

SELECT
    aud.location_id AS location_id,
    ws.type_of_water_source as survey_source,
    aud.type_of_water_source as auditor_source,
    v.record_id,
    aud.true_water_source_score as auditor_score,
    wq.subjective_quality_score as surveyor_score
    

FROM auditor_report aud
JOIN visits v
    ON aud.location_id = v.location_id
JOIN water_quality wq
    ON v.record_id = wq.record_id
JOIN water_source ws
    ON ws.source_id = v.source_id
WHERE aud.true_water_source_score != wq.subjective_quality_score
    AND v.visit_count = 1

LIMIT 10;


-- Linking Records
SELECT
    aud.location_id AS location_id,
    v.record_id,
    e.employee_name,
    aud.true_water_source_score as auditor_score,
    wq.subjective_quality_score as surveyor_score

FROM auditor_report aud
JOIN visits v
    ON aud.location_id = v.location_id
JOIN water_quality wq
    ON v.record_id = wq.record_id
JOIN employee e
    ON v.assigned_employee_id = e.assigned_employee_id
WHERE aud.true_water_source_score != wq.subjective_quality_score
    AND v.visit_count = 1

limit 10;


-- Setting the Query as CTE
WITH Incorrect_records AS (SELECT
    aud.location_id AS location_id,
    v.record_id,
    e.employee_name,
    aud.true_water_source_score as auditor_score,
    wq.subjective_quality_score as surveyor_score,
    aud.statements

FROM auditor_report aud
JOIN visits v
    ON aud.location_id = v.location_id
JOIN water_quality wq
    ON v.record_id = wq.record_id
JOIN employee e
    ON v.assigned_employee_id = e.assigned_employee_id
WHERE aud.true_water_source_score != wq.subjective_quality_score
    AND v.visit_count = 1)

SELECT * FROM Incorrect_records
limit 10;

WITH Incorrect_records AS (SELECT
    aud.location_id AS location_id,
    v.record_id,
    e.employee_name,
    aud.true_water_source_score as auditor_score,
    wq.subjective_quality_score as surveyor_score,
    aud.statements

FROM auditor_report aud
JOIN visits v
    ON aud.location_id = v.location_id
JOIN water_quality wq
    ON v.record_id = wq.record_id
JOIN employee e
    ON v.assigned_employee_id = e.assigned_employee_id
WHERE aud.true_water_source_score != wq.subjective_quality_score
    AND v.visit_count = 1)

SELECT DISTINCT employee_name

FROM Incorrect_records;

WITH Incorrect_records AS (SELECT
    aud.location_id AS location_id,
    v.record_id,
    e.employee_name,
    aud.true_water_source_score as auditor_score,
    wq.subjective_quality_score as surveyor_score,
    aud.statements

FROM auditor_report aud
JOIN visits v
    ON aud.location_id = v.location_id
JOIN water_quality wq
    ON v.record_id = wq.record_id
JOIN employee e
    ON v.assigned_employee_id = e.assigned_employee_id
WHERE aud.true_water_source_score != wq.subjective_quality_score
    AND v.visit_count = 1)

SELECT 
    employee_name,
    COUNT(employee_name) as number_of_mistakes
FROM Incorrect_records
GROUP BY employee_name;

WITH Incorrect_records AS (SELECT
    aud.location_id AS location_id,
    v.record_id,
    e.employee_name,
    aud.true_water_source_score as auditor_score,
    wq.subjective_quality_score as surveyor_score,
    aud.statements

FROM auditor_report aud
JOIN visits v
    ON aud.location_id = v.location_id
JOIN water_quality wq
    ON v.record_id = wq.record_id
JOIN employee e
    ON v.assigned_employee_id = e.assigned_employee_id
WHERE aud.true_water_source_score != wq.subjective_quality_score
    AND v.visit_count = 1)

SELECT 
    employee_name,
    COUNT(employee_name) as number_of_mistakes
FROM Incorrect_records
GROUP BY employee_name
ORDER BY number_of_mistakes DESC;


-- GATHERING EVIDENCE
WITH Incorrect_records AS (SELECT
    aud.location_id AS location_id,
    v.record_id,
    e.employee_name,
    aud.true_water_source_score as auditor_score,
    wq.subjective_quality_score as surveyor_score,
    aud.statements

FROM auditor_report aud
JOIN visits v
    ON aud.location_id = v.location_id
JOIN water_quality wq
    ON v.record_id = wq.record_id
JOIN employee e
    ON v.assigned_employee_id = e.assigned_employee_id
WHERE aud.true_water_source_score != wq.subjective_quality_score
    AND v.visit_count = 1),

error_count AS (SELECT 
    employee_name,
    COUNT(employee_name) as number_of_mistakes
FROM Incorrect_records
GROUP BY employee_name)

SELECT AVG(number_of_mistakes) AS avg_error_count_per_empl
FROM error_count;

WITH Incorrect_records AS (SELECT
    aud.location_id AS location_id,
    v.record_id,
    e.employee_name,
    aud.true_water_source_score as auditor_score,
    wq.subjective_quality_score as surveyor_score,
    aud.statements

FROM auditor_report aud
JOIN visits v
    ON aud.location_id = v.location_id
JOIN water_quality wq
    ON v.record_id = wq.record_id
JOIN employee e
    ON v.assigned_employee_id = e.assigned_employee_id
WHERE aud.true_water_source_score != wq.subjective_quality_score
    AND v.visit_count = 1),

error_count AS (SELECT 
    employee_name,
    COUNT(employee_name) as number_of_mistakes
FROM Incorrect_records
GROUP BY employee_name)


SELECT 
    employee_name,
    number_of_mistakes
FROM error_count
WHERE number_of_mistakes > (SELECT 
                                AVG(number_of_mistakes) AS avg_error_count_per_empl
                            FROM error_count);


-- CREATE VIEW WITH INCORRECT RECORDS CTE
DROP VIEW IF EXISTS Incorrect_records;

CREATE VIEW Incorrect_records AS (SELECT
    aud.location_id AS location_id,
    v.record_id,
    e.employee_name,
    aud.true_water_source_score as auditor_score,
    wq.subjective_quality_score as surveyor_score,
    aud.statements

FROM auditor_report aud
JOIN visits v
    ON aud.location_id = v.location_id
JOIN water_quality wq
    ON v.record_id = wq.record_id
JOIN employee e
    ON v.assigned_employee_id = e.assigned_employee_id
WHERE aud.true_water_source_score != wq.subjective_quality_score
    AND v.visit_count = 1);

SELECT * FROM Incorrect_records

LIMIT 5;


-- CONVERT ERROR COUNT TO CTE
WITH error_count AS (SELECT 
    employee_name,
    COUNT(employee_name) as number_of_mistakes
FROM Incorrect_records
GROUP BY employee_name)

SELECT * FROM error_count;

WITH error_count AS (SELECT 
    employee_name,
    COUNT(employee_name) as number_of_mistakes
FROM Incorrect_records
GROUP BY employee_name)

SELECT AVG(number_of_mistakes)
FROM error_count;

WITH error_count AS (SELECT 
    employee_name,
    COUNT(employee_name) as number_of_mistakes
FROM Incorrect_records
GROUP BY employee_name)

SELECT 
    employee_name,
    number_of_mistakes
FROM error_count
WHERE number_of_mistakes > (SELECT 
                                AVG(number_of_mistakes) AS avg_error_count_per_empl
                            FROM error_count);


-- Convert Suspect list to CTE
WITH error_count AS (SELECT 
    employee_name,
    COUNT(employee_name) as number_of_mistakes
FROM Incorrect_records
GROUP BY employee_name),

suspect_list AS (SELECT 
    employee_name,
    number_of_mistakes
FROM error_count
WHERE number_of_mistakes > (SELECT 
                                AVG(number_of_mistakes) AS avg_error_count_per_empl
                            FROM error_count))

SELECT 
    employee_name,
    number_of_mistakes
FROM suspect_list;

WITH error_count AS (SELECT 
    employee_name,
    COUNT(employee_name) as number_of_mistakes
FROM Incorrect_records
GROUP BY employee_name),

suspect_list AS (SELECT 
    employee_name,
    number_of_mistakes
FROM error_count
WHERE number_of_mistakes > (SELECT 
                                AVG(number_of_mistakes) AS avg_error_count_per_empl
                            FROM error_count))

SELECT 
    employee_name,
    location_id,
    statements
FROM Incorrect_records
WHERE employee_name IN (SELECT employee_name FROM suspect_list);

WITH error_count AS (SELECT 
    employee_name,
    COUNT(employee_name) as number_of_mistakes
FROM Incorrect_records
GROUP BY employee_name),

suspect_list AS (SELECT 
    employee_name,
    number_of_mistakes
FROM error_count
WHERE number_of_mistakes > (SELECT 
                                AVG(number_of_mistakes) AS avg_error_count_per_empl
                            FROM error_count))

SELECT 
    employee_name,
    location_id,
    statements
FROM Incorrect_records
WHERE employee_name IN (SELECT employee_name FROM suspect_list)
    AND location_id in ('AkRu04508', 'AkRu07310', 'KiRu29639', 'AmAm09607');

WITH error_count AS (SELECT 
    employee_name,
    COUNT(employee_name) as number_of_mistakes
FROM Incorrect_records
GROUP BY employee_name),

suspect_list AS (SELECT 
    employee_name,
    number_of_mistakes
FROM error_count
WHERE number_of_mistakes > (SELECT 
                                AVG(number_of_mistakes) AS avg_error_count_per_empl
                            FROM error_count))

SELECT 
    employee_name,
    location_id,
    statements
FROM Incorrect_records
WHERE employee_name IN (SELECT employee_name FROM suspect_list)
    AND statements LIKE ('%cash%');

WITH error_count AS (SELECT 
    employee_name,
    COUNT(employee_name) as number_of_mistakes
FROM Incorrect_records
GROUP BY employee_name),

suspect_list AS (SELECT 
    employee_name,
    number_of_mistakes
FROM error_count
WHERE number_of_mistakes > (SELECT 
                                AVG(number_of_mistakes) AS avg_error_count_per_empl
                            FROM error_count))

SELECT 
    employee_name,
    location_id,
    statements
FROM Incorrect_records
WHERE employee_name IN (SELECT employee_name FROM suspect_list)
    AND statements LIKE ('%cash%') 
    AND employee_name NOT IN (SELECT employee_name FROM suspect_list);

WITH error_count AS (SELECT 
    employee_name,
    COUNT(employee_name) as number_of_mistakes
FROM Incorrect_records
GROUP BY employee_name),

suspect_list AS (SELECT 
    employee_name,
    number_of_mistakes
FROM error_count
WHERE number_of_mistakes > (SELECT 
                                AVG(number_of_mistakes) AS avg_error_count_per_empl
                            FROM error_count))

SELECT 
    employee_name,
    location_id,
    statements
FROM Incorrect_records
WHERE employee_name IN (SELECT employee_name FROM suspect_list)
      AND statements LIKE '%aloof%';

SELECT
    auditorRep.location_id,
    visitsTbl.record_id,
    auditorRep.true_water_source_score AS auditor_score,
    wq.subjective_quality_score AS employee_score,
    wq.subjective_quality_score - auditorRep.true_water_source_score  AS score_diff
FROM auditor_report AS auditorRep
JOIN visits AS visitsTbl
    ON auditorRep.location_id = visitsTbl.location_id
JOIN water_quality AS wq
    ON visitsTbl.record_id = wq.record_id
WHERE (wq.subjective_quality_score - auditorRep.true_water_source_score) > 9;

