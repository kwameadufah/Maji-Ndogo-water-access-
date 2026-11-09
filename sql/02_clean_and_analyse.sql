-- Maji Ndogo water access, part 2
-- Database: md_water_services (MySQL). Load data/md_water_services.sql first.


-- Cleaning our data
SELECT
   *
FROM
   employee

LIMIT 10;


-- Remove the Space between First and Last Names using REPLACE ()
SELECT
  REPLACE(employee_name, ' ','.') 
FROM
   employee

LIMIT 10;


-- Make Name Lowercase with LOWER()
SELECT
  LOWER(REPLACE(employee_name, ' ','.')) 
FROM
   employee

LIMIT 10;


-- Add the Rest of Email
SELECT
  CONCAT(LOWER(REPLACE(employee_name, ' ','.')), '@ndogowater.gov') AS new_email
FROM
   employee

LIMIT 10;


-- UPDATE Email column
UPDATE employee
SET email = CONCAT(LOWER(REPLACE(employee_name, ' ','.')), '@ndogowater.gov');

SELECT
   *
FROM
   employee

LIMIT 5;


-- Check Length of Phone Number Column
Select
    Length(phone_number)
From 
    employee
Limit 3;

Select RTRIM(phone_number)
From employee
limit 5;

Select LENGTH(RTRIM(phone_number))
From employee
limit 3;


-- UPDATE Phone Number Column
UPDATE employee
SET phone_number = RTRIM(phone_number);

Select
    Length(phone_number)
From 
    employee
Limit 10;


-- Number of Employees in Each Town
Select 
    town_name,
    COUNT(*) AS number_of_employees

From employee
GROUP BY town_name
ORDER BY number_of_employees desc;


-- Number of Locations Visited by Employees
SELECT assigned_employee_id,
COUNT(Distinct record_id) as number_of_visits
FROM visits
Group By assigned_employee_id;


-- Top 3 Field Surveyors
Select 
    e.assigned_employee_id,
    e.employee_name,
    e.email,
    e.phone_number,
    Count(Distinct v.record_id) as number_of_visits
From 
    visits v
Join 
    employee e on v.assigned_employee_id = e.assigned_employee_id
Where 
    e.position = 'field surveyor'
Group by 
    e.assigned_employee_id, e.employee_name, e.email, e.phone_number
Order by 
    number_of_visits desc
Limit 3;


-- Number of Records per town
select 
    town_name,
COUNT(*) as records_per_town
from location
Group by town_name
Order by records_per_town desc;


-- Records per province
select
    province_name,
Count(*) as records_per_province 
from location
Group by province_name
order by records_per_province desc;


-- Province and Town Total Town Records
select 
    province_name,
    town_name,
    
COUNT(*) as records_per_town

from location

Group by 
    province_name, town_name

Order by 
    province_name,
    town_name desc;


-- Number of Records Per Location (60% of water resources are in Rural Areas)
select 
    location_type,
Count(*) as num_sources

From location

Group by location_type
Order by num_sources;


-- Water Source
select * from water_source
limit 10;


-- Total Number of People Surveyed
select
SUM(number_of_people_served) as TotalServed
from water_source;

select
COUNT(source_id) as TotalSurveyed
from water_source;


-- Number of Water Sources
select
    type_of_water_source,
Count(*) as num_sources
from water_source
Group by type_of_water_source
Order by num_sources desc;

select
    type_of_water_source,
    Round(AVG(number_of_people_served),0) AS avg_people_served
from 
    water_source
Group by 
    type_of_water_source
Order by 
    avg_people_served desc;


-- Number of People per Water Source
select
    type_of_water_source,
    Round(SUM(number_of_people_served),0) AS total_people_served
from 
    water_source
Group by 
    type_of_water_source
Order by 
    total_people_served desc;


-- Percentage of People Per Water Source
Select
    type_of_water_source,
    SUM(number_of_people_served) AS total_people_served,
        ROUND(SUM(number_of_people_served) * 100.0 /
              (Select SUM(number_of_people_served) FROM water_source),0) AS pct_people_per_source

From water_source
Group by type_of_water_source
Order by pct_people_per_source desc;


-- Rank Water Source by Total Served
SELECT 
    type_of_water_source,
    SUM(number_of_people_served) AS total_people_served
FROM 
    water_source

GROUP BY
    type_of_water_source

ORDER BY 
    total_people_served DESC;

SELECT
    type_of_water_source,
    total_people_served,
    RANK() OVER (ORDER BY total_people_served DESC) AS rank_by_population
FROM (
    SELECT
        type_of_water_source,
        SUM(number_of_people_served) AS total_people_served
    FROM
        water_source
    GROUP BY
        type_of_water_source
) AS aggregated_data;


-- RANK Improvable sources
SELECT
  source_id,
  type_of_water_source,
  number_of_people_served,
  RANK() OVER (PARTITION BY type_of_water_source
    ORDER BY number_of_people_served DESC) AS priority_rank
FROM
  water_source
WHERE
  type_of_water_source != 'tap_in_home'
ORDER BY
  type_of_water_source ASC,
  priority_rank DESC

LIMIT 10;

SELECT
  source_id,
  type_of_water_source,
  number_of_people_served,
  DENSE_RANK() OVER (PARTITION BY type_of_water_source
    ORDER BY number_of_people_served DESC) AS priority_rank
FROM
  water_source
WHERE
  type_of_water_source != 'tap_in_home'
ORDER BY
  type_of_water_source ASC,
  priority_rank DESC

LIMIT 10;

SELECT
  source_id,
  type_of_water_source,
  number_of_people_served,
  ROW_NUMBER() OVER (PARTITION BY type_of_water_source
    ORDER BY number_of_people_served DESC) AS priority_rank
FROM
  water_source
WHERE
  type_of_water_source != 'tap_in_home'
ORDER BY
  type_of_water_source ASC,
  priority_rank DESC

LIMIT 10;


-- How long the survey took
SELECT
    MIN(time_of_record) AS Start_date,
    MAX(time_of_record) AS End_date,
    DATEDIFF(MAX(time_of_record), MIN(time_of_record)) AS TotalDays

FROM
    visits;


-- Time in Queue
SELECT
    ROUND(AVG(NULLIF(time_in_queue, 0)),1) AS avg_queue_time

FROM
    visits;


-- Queue Time on Different Days of the Week
SELECT
    DAYNAME(time_of_record) AS day_of_week,
    ROUND(AVG(NULLIF(time_in_queue, 0)),0) AS avg_queue_time

FROM
    visits

GROUP BY
    day_of_week

ORDER BY
    FIELD(day_of_week, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');


-- Queue Time During Hours of the Day
SELECT
    TIME(time_of_record) AS full_time,
    HOUR(time_of_record) AS hour_of_day

FROM
    visits

LIMIT 10;

SELECT
    HOUR(time_of_record) AS hour_of_day,
    COUNT(*) AS Visit_count

FROM
    visits

GROUP BY 
    hour_of_day

ORDER BY
    hour_of_day

LIMIT 10;

SELECT
    HOUR(time_of_record) AS hour_of_day,
    ROUND(AVG(NULLIF(time_in_queue, 0)),0) AS avg_queue_time

FROM
    visits

GROUP BY 
    hour_of_day

ORDER BY
    hour_of_day

LIMIT 10;

SELECT
    TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
    ROUND(AVG(NULLIF(time_in_queue, 0)),0) AS avg_queue_time

FROM
    visits

WHERE
    time_in_queue != 0

GROUP BY 
    hour_of_day

ORDER BY
    hour_of_day;

SELECT
    TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
    DAYNAME(time_of_record) AS day_of_week,
    CASE
        WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
    ELSE NULL
    END AS Sunday
FROM
    visits
WHERE
    time_in_queue != 0
    
LIMIT 20;

SELECT
  TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,

  -- Sunday
  ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue ELSE NULL END), 0) AS Sunday,

  -- Monday
  ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue ELSE NULL END), 0) AS Monday,

  -- Tuesday
  ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue ELSE NULL END), 0) AS Tuesday,

  -- Wednesday
  ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue ELSE NULL END), 0) AS Wednesday,

  -- Thursday
  ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue ELSE NULL END), 0) AS Thursday,

  -- Friday
  ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue ELSE NULL END), 0) AS Friday,

  -- Saturday
  ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue ELSE NULL END), 0) AS Saturday

FROM
  visits
WHERE
  time_in_queue != 0

GROUP BY
  hour_of_day

ORDER BY
  hour_of_day;

