-- Maji Ndogo water access, part 4
-- Database: md_water_services (MySQL). Load data/md_water_services.sql first.


-- Joining Visit, Location and Water Sources
SELECT 
    l.province_name,
    l.town_name,
    v.visit_count,
    l.location_id
FROM visits v
JOIN location l
    ON v.location_id = l.location_id
LIMIT 10;

SELECT 
    l.province_name,
    l.town_name,
    v.visit_count,
    l.location_id,
    ws.type_of_water_source,
    ws.number_of_people_served
FROM visits v
JOIN location l
    ON v.location_id = l.location_id
JOIN water_source ws
    ON v.source_id = ws.source_id
LIMIT 10;

SELECT 
    l.province_name,
    l.town_name,
    v.visit_count,
    l.location_id,
    ws.type_of_water_source,
    ws.number_of_people_served
FROM visits v
JOIN location l
    ON v.location_id = l.location_id
JOIN water_source ws
    ON v.source_id = ws.source_id
WHERE v.location_id = 'AkHa00103'

-- LIMIT 10;

SELECT 
    l.province_name,
    l.town_name,
    v.visit_count,
    l.location_id,
    ws.type_of_water_source,
    ws.number_of_people_served
FROM visits v
JOIN location l
    ON v.location_id = l.location_id
JOIN water_source ws
    ON v.source_id = ws.source_id
WHERE v.visit_count = 1
LIMIT 10;

SELECT 
    l.province_name,
    l.town_name,
    l.location_type,
    ws.type_of_water_source,
    v.time_in_queue,
    ws.number_of_people_served
FROM visits v
JOIN location l
    ON v.location_id = l.location_id
JOIN water_source ws
    ON v.source_id = ws.source_id
WHERE v.visit_count = 1
LIMIT 10;

SELECT 
    l.province_name,
    l.town_name,
    l.location_type,
    ws.type_of_water_source,
    v.time_in_queue,
    ws.number_of_people_served,
    wp.results
FROM visits v
LEFT JOIN well_pollution wp
    ON v.source_id = wp.source_id
JOIN location l
    ON v.location_id = l.location_id
JOIN water_source ws
    ON v.source_id = ws.source_id
WHERE v.visit_count = 1
LIMIT 10;


-- CREATE VIEW WITH COMBINED TABLE
DROP VIEW IF EXISTS Combined_Analysis;
CREATE VIEW Combined_Analysis AS 
SELECT 
    l.province_name,
    l.town_name,
    l.location_type,
    ws.type_of_water_source as source_type,
    v.time_in_queue,
    ws.number_of_people_served as people_served,
    wp.results
FROM visits v
LEFT JOIN well_pollution wp
    ON v.source_id = wp.source_id
JOIN location l
    ON v.location_id = l.location_id
JOIN water_source ws
    ON v.source_id = ws.source_id
WHERE v.visit_count = 1;


-- Aggregate Data by Province
WITH province_totals AS (-- This CTE calculates the population of each province
    SELECT
        province_name,
        SUM(people_served) AS total_ppl_serv
    FROM
        Combined_Analysis
    GROUP BY
        province_name
)
    SELECT
        ct.province_name,
        -- These case statements create columns for each type of source.
        -- The results are aggregated and percentages are calculated
        ROUND((SUM(CASE WHEN source_type = 'river'
            THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
        ROUND((SUM(CASE WHEN source_type = 'shared_tap'
            THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
        ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
            THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
        ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
            THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
        ROUND((SUM(CASE WHEN source_type = 'well'
            THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
    FROM
        Combined_Analysis ct
    JOIN
        province_totals pt ON ct.province_name = pt.province_name
    GROUP BY
        ct.province_name
    ORDER BY
        ct.province_name;


-- Aggregate Data By Town
WITH town_totals AS (
    SELECT 
        province_name, 
        town_name, 
        SUM(people_served) AS total_ppl_serv
    FROM 
        Combined_Analysis
    GROUP BY 
        province_name,
        town_name
)
    SELECT
        ct.province_name,
        ct.town_name,
    ROUND((SUM(CASE WHEN source_type = 'river' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
    ROUND((SUM(CASE WHEN source_type = 'shared_tap' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
    ROUND((SUM(CASE WHEN source_type = 'well' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
    Combined_Analysis ct
JOIN
    town_totals tt 
    ON ct.province_name = tt.province_name 
    AND ct.town_name = tt.town_name
GROUP BY
    ct.province_name,
    ct.town_name
ORDER BY
    ct.town_name;

CREATE TEMPORARY TABLE town_aggregated_water_access
WITH town_totals AS (
    SELECT 
        province_name, 
        town_name, 
        SUM(people_served) AS total_ppl_serv
    FROM 
        Combined_Analysis
    GROUP BY 
        province_name,
        town_name
)
    SELECT
        ct.province_name,
        ct.town_name,
    ROUND((SUM(CASE WHEN source_type = 'river' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
    ROUND((SUM(CASE WHEN source_type = 'shared_tap' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
    ROUND((SUM(CASE WHEN source_type = 'well' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
    Combined_Analysis ct
JOIN
    town_totals tt 
    ON ct.province_name = tt.province_name 
    AND ct.town_name = tt.town_name
GROUP BY
    ct.province_name,
    ct.town_name
ORDER BY
    ct.town_name;

WITH town_totals AS (
    SELECT 
        province_name, 
        town_name, 
        SUM(people_served) AS total_ppl_serv
    FROM 
        Combined_Analysis
    GROUP BY 
        province_name,
        town_name
)
    SELECT
        ct.province_name,
        ct.town_name,
    ROUND((SUM(CASE WHEN source_type = 'river' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
    ROUND((SUM(CASE WHEN source_type = 'shared_tap' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
    ROUND((SUM(CASE WHEN source_type = 'well' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
    Combined_Analysis ct
JOIN
    town_totals tt 
    ON ct.province_name = tt.province_name 
    AND ct.town_name = tt.town_name
GROUP BY
    ct.province_name,
    ct.town_name
ORDER BY
    province_name;

SELECT
    province_name,
    town_name,
ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) * 100,0) AS Pct_broken_taps
FROM
town_aggregated_water_access;


-- Practical Plan
CREATE TABLE Project_progress (
    Project_id SERIAL PRIMARY KEY,
    -- Project_id: Unique key for sources in case we visit the same source more than once in the future.

    source_id VARCHAR(20) NOT NULL,
    -- Each of the sources we want to improve should exist and should refer to the source table.
    -- This ensures data integrity.
    
    Address VARCHAR(50), -- Street address
    Town VARCHAR(30),
    Province VARCHAR(30),
    Source_type VARCHAR(50),
    Improvement VARCHAR(50), -- What the engineers should do at that place

    Source_status VARCHAR(50) DEFAULT 'Backlog' 
        CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
    -- We want to limit the type of information engineers can give us
    -- By DEFAULT all projects are in the "Backlog"
    -- CHECK() ensures only those three options will be accepted

    Date_of_completion DATE, -- Engineers will add this the day the source has been upgraded

    Comments TEXT, -- Engineers can leave comments. TEXT has no char limit

    FOREIGN KEY (source_id) REFERENCES water_source(source_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

DROP TABLE IF EXISTS Project_progress;
CREATE TABLE Project_progress (
    Project_id SERIAL PRIMARY KEY,
    source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
    Address VARCHAR(50),
    Town VARCHAR(30),
    Province VARCHAR(30),
    Source_type VARCHAR(50),
    Improvement VARCHAR(50),
    Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
    Date_of_completion DATE,
    Comments TEXT
);


-- High Level Imporvements
SELECT
    l.address,
    l.town_name,
    l.province_name,
    ws.source_id,
    ws.type_of_water_source,
    wp.results
FROM
    water_source ws
LEFT JOIN
    well_pollution wp
    ON ws.source_id = wp.source_id
INNER JOIN
    visits v
    ON ws.source_id = v.source_id
INNER JOIN
    location l
    ON l.location_id = v.location_id
LIMIT 10;


-- Records where visit count is 1
SELECT
    l.address,
    l.town_name,
    l.province_name,
    ws.source_id,
    ws.type_of_water_source,
    wp.results
FROM
    water_source ws
LEFT JOIN
    well_pollution wp
    ON ws.source_id = wp.source_id
INNER JOIN
    visits v
    ON ws.source_id = v.source_id
INNER JOIN
    location l
    ON l.location_id = v.location_id
WHERE 
    v.visit_count = 1

LIMIT 10;

SELECT
    l.address,
    l.town_name,
    l.province_name,
    ws.source_id,
    ws.type_of_water_source,
    wp.results
FROM
    water_source ws
LEFT JOIN
    well_pollution wp
    ON ws.source_id = wp.source_id
INNER JOIN
    visits v
    ON ws.source_id = v.source_id
INNER JOIN
    location l
    ON l.location_id = v.location_id
WHERE 
    v.visit_count = 1 
    AND (
        (ws.type_of_water_source = 'well' AND wp.results IS NOT NULL AND wp.results <> 'Clean')
        OR (ws.type_of_water_source = 'shared_tap' AND v.time_in_queue > 30)
        OR (ws.type_of_water_source IN ('river', 'tap_in_home_broken'))
        )

LIMIT 10;


-- Use some control flow logic to create Install UV filter or Install RO filter
SELECT
    l.address,
    l.town_name,
    l.province_name,
    ws.source_id,
    ws.type_of_water_source,
    wp.results,
CASE 
    WHEN wp.results = 'Contaminated: Biological' THEN 'Install UV filter'
    WHEN wp.results = 'Contaminated: Chemical' THEN 'Install RO filter'
    ELSE NULL
END AS Improvement 

FROM
    water_source ws
LEFT JOIN
    well_pollution wp
    ON ws.source_id = wp.source_id
INNER JOIN
    visits v
    ON ws.source_id = v.source_id
INNER JOIN
    location l
    ON l.location_id = v.location_id
WHERE 
    v.visit_count = 1 AND (
        (ws.type_of_water_source = 'well' AND wp.results IS NOT NULL AND wp.results != 'Clean')
        OR (ws.type_of_water_source IN ('river', 'tap_in_home_broken')
        OR ws.type_of_water_source = 'shared_tap' AND v.time_in_queue > 30)
        )
LIMIT 10;

SELECT
    l.address,
    l.town_name,
    l.province_name,
    ws.source_id,
    ws.type_of_water_source,
    wp.results,
CASE 
    WHEN wp.results = 'Contaminated: Biological' THEN 'Install UV filter'
    WHEN wp.results = 'Contaminated: Chemical' THEN 'Install RO filter'
    WHEN ws.type_of_water_source = 'river' THEN 'Drill Well'
    ELSE NULL
END AS Improvement 

FROM
    water_source ws
LEFT JOIN
    well_pollution wp
    ON ws.source_id = wp.source_id
INNER JOIN
    visits v
    ON ws.source_id = v.source_id
INNER JOIN
    location l
    ON l.location_id = v.location_id
WHERE 
    v.visit_count = 1 AND (
        (ws.type_of_water_source = 'well' AND wp.results IS NOT NULL AND wp.results != 'Clean')
        OR (ws.type_of_water_source IN ('river', 'tap_in_home_broken')
        OR ws.type_of_water_source = 'shared_tap' AND v.time_in_queue > 30)
        )
LIMIT 10;


-- Shared Taps
SELECT
    l.address,
    l.town_name,
    l.province_name,
    ws.source_id,
    ws.type_of_water_source,
    wp.results,
CASE 
    WHEN wp.results = 'Contaminated: Biological' THEN 'Install UV filter'
    WHEN wp.results = 'Contaminated: Chemical' THEN 'Install RO filter'
    WHEN ws.type_of_water_source = 'river' THEN 'Drill Well'
    WHEN ws.type_of_water_source = 'shared_tap' AND v.time_in_queue >= 30 THEN CONCAT('Install ', FLOOR(v.time_in_queue/30), ' taps nearby')
    ELSE NULL
END AS Improvement 

FROM
    water_source ws
LEFT JOIN
    well_pollution wp
    ON ws.source_id = wp.source_id
INNER JOIN
    visits v
    ON ws.source_id = v.source_id
INNER JOIN
    location l
    ON l.location_id = v.location_id
WHERE 
    v.visit_count = 1 AND (
        (ws.type_of_water_source = 'well' AND wp.results IS NOT NULL AND wp.results != 'Clean')
        OR (ws.type_of_water_source IN ('river', 'tap_in_home_broken')
        OR ws.type_of_water_source = 'shared_tap' AND v.time_in_queue > 30)
        )
LIMIT 10;


-- Step 3: In-home taps
SELECT
    l.address,
    l.town_name,
    l.province_name,
    ws.source_id,
    ws.type_of_water_source,
    wp.results,
CASE 
    WHEN wp.results = 'Contaminated: Biological' THEN 'Install UV filter'
    WHEN wp.results = 'Contaminated: Chemical' THEN 'Install RO filter'
    WHEN ws.type_of_water_source = 'river' THEN 'Drill Well'
    WHEN ws.type_of_water_source = 'shared_tap' AND v.time_in_queue >= 30 THEN CONCAT('Install ', FLOOR(v.time_in_queue/30), ' taps nearby')
    WHEN ws.type_of_water_source = 'tap_in_home_broken' THEN 'Diagnose local infrastructure'
    ELSE NULL
END AS Improvement 

FROM
    water_source ws
LEFT JOIN
    well_pollution wp
    ON ws.source_id = wp.source_id
INNER JOIN
    visits v
    ON ws.source_id = v.source_id
INNER JOIN
    location l
    ON l.location_id = v.location_id
WHERE 
    v.visit_count = 1 AND (
        (ws.type_of_water_source = 'well' AND wp.results IS NOT NULL AND wp.results != 'Clean')
        OR (ws.type_of_water_source IN ('river', 'tap_in_home_broken')
        OR ws.type_of_water_source = 'shared_tap' AND v.time_in_queue > 30)
        )
LIMIT 10;

