/home/athach/home/athach/home/athach-------------- LOAD 2017 Q1, Q2 ------------------------------


-- Delete repeat headers found in table
DELETE
FROM raw_2017_q1q2
WHERE trip_start_time LIKE 'trip_start_time';

-- Sanity check to see if row was dropped
SELECT *
FROM raw_2017_q1q2
WHERE trip_start_time LIKE 'trip_start_time';
-- Good

-- Load `raw_2017_q1q2` to `trips`
INSERT INTO trips
(trip_id, trip_duration_seconds, start_station_id, trip_start_time, start_station_name, end_station_id, trip_end_time,
 end_station_name, bike_id, user_type)
SELECT trip_id,
       trip_duration_seconds::int,
       from_station_id,
       TO_TIMESTAMP(trip_start_time, 'dd/mm/yyyy hh24:mi'),
       from_station_name,
       to_station_id,
       TO_TIMESTAMP(trip_stop_time, 'dd/mm/yyyy hh24:mi'),
       to_station_name,
       NULL,
       user_type
FROM raw_2017_q1q2;

-- Sanity Check
SELECT *
FROM trips;

----------------- LOAD 2017 Q3, Q4 DATA ---------------------

SELECT *
FROM raw_2017_q3q4;


SELECT *
FROM raw_2017_q3q4
WHERE trip_id LIKE 'trip_id';

-- Delete repeat headers found in table
DELETE
FROM raw_2017_q3q4
WHERE trip_start_time LIKE 'trip_start_time';

-- Sanity check to see if row was dropped
SELECT *
FROM raw_2017_q1q2
WHERE trip_start_time LIKE 'trip_start_time';
-- Good


-- Filter for rows with trip_start_time like "%NU%"
SELECT *
FROM raw_2017_q3q4
WHERE trip_start_time LIKE '%NU%';
-- Tells me that the issue isn't in 'trip_start_time'

-- Filter for rows with 'trip_stop_time' like "%NU%"
SELECT *
FROM raw_2017_q3q4
WHERE trip_stop_time LIKE '%NU%';
-- Looks like the trip never ended...
-- I don't know if there's a way to impute a value that would satisfy the business rule of having a timestamp
-- But it's only one row the 2 quarters in 2017

-- Delete rows with 'trip_stop_time' like "%NU%"
DELETE
FROM raw_2017_q3q4
WHERE trip_stop_time LIKE '%NU%';

-- Load `raw_2017_q3q4` to `trips`
INSERT INTO trips
(trip_id, trip_duration_seconds, start_station_id, trip_start_time, start_station_name, end_station_id, trip_end_time,
 end_station_name, bike_id, user_type)
SELECT trip_id,
       trip_duration_seconds::int,
       NULL,
       TO_TIMESTAMP(trip_start_time, 'mm/dd/yyyy hh24:mi'),
       from_station_name,
       NULL,
       TO_TIMESTAMP(trip_stop_time, 'mm/dd/yyyy hh24:mi'),
       to_station_name,
       NULL,
       user_type
FROM raw_2017_q3q4;

-- Check for duplicate rows
SELECT trip_id
FROM trips
GROUP BY trip_id
HAVING COUNT(*) > 1;
-- No dupes

------------------------- LOAD 2018 DATA --------------------------------

-- Check for column headers found in rows
SELECT *
FROM raw_2018
WHERE trip_id LIKE 'trip_id';
-- 3 instances of this happening

-- Delete these rows
DELETE
FROM raw_2018
WHERE trip_id LIKE 'trip_id'

-- Load 2018 data to 'trips'
INSERT INTO trips
(trip_id, trip_duration_seconds, start_station_id, trip_start_time, start_station_name, end_station_id, trip_end_time,
 end_station_name, bike_id, user_type)
SELECT trip_id,
       trip_duration_seconds::int,
       from_station_id,
       TO_TIMESTAMP(trip_start_time, 'mm/dd/yyyy hh24:mi'),
       from_station_name,
       to_station_id,
       TO_TIMESTAMP(trip_stop_time, 'mm/dd/yyyy hh24:mi'),
       to_station_name,
       NULL,
       user_type
FROM raw_2018;

-- LOAD 2019, 2020 DATA

-- Check for column header issue
SELECT *
FROM raw_2019_2020
WHERE "Trip Id" LIKE 'Trip Id';
-- Doesn't look like I have that issue here

SELECT "Trip  Duration"
FROM raw_2019_2020
WHERE "Trip  Duration" NOT LIKE '%[^0-9]%';


SELECT "Trip  Duration"
FROM raw_2019_2020
GROUP BY "Trip  Duration";

-- Check for rows trip duration values prefixed with '0'
select *
from raw_2019_2020
where "Trip  Duration" like '0%'

-- Counting total number of rows that match this pattern
select count(*)
from raw_2019_2020
where "Trip  Duration" like '0%'
    -- That's quite a number of rows

-- Delete duplicate column header rows found in data set
delete
from raw_2019_2020
where "Trip  Duration" ~ 'Trip  Duration';

-- Load 2019 and 2020 data to 'trips'
INSERT INTO trips
(trip_id, trip_duration_seconds, start_station_id, trip_start_time, start_station_name, end_station_id, trip_end_time,
 end_station_name, bike_id, user_type)
SELECT "Trip Id",
       "Trip  Duration"::int,
       "Start Station Id",
       TO_TIMESTAMP("Start Time", 'mm/dd/yyyy hh24:mi'),
       "Start Station Name",
       "End Station Id",
       TO_TIMESTAMP("End Time", 'mm/dd/yyyy hh24:mi'),
       "End Station Name",
       "Bike Id",
       "User Type"
FROM raw_2019_2020;

-- Feb-Apr 2021
DELETE
from raw_feb_apr_2021
where "Trip  Duration" ~ 'Trip  Duration';

INSERT INTO trips
(trip_id, trip_duration_seconds, start_station_id, trip_start_time, start_station_name, end_station_id, trip_end_time,
 end_station_name, bike_id, user_type)
SELECT "Trip Id",
       "Trip  Duration"::int,
       "Start Station Id",
       TO_TIMESTAMP("Start Time", 'mm/dd/yyyy hh24:mi'),
       "Start Station Name",
       "End Station Id",
       TO_TIMESTAMP("End Time", 'mm/dd/yyyy hh24:mi'),
       "End Station Name",
       "Bike Id",
       "User Type"
FROM raw_feb_apr_2021;

-- Jan 2021
DELETE
from raw_jan_2021
where "Trip  Duration" ~ 'Trip  Duration';

INSERT INTO trips
(trip_id, trip_duration_seconds, start_station_id, trip_start_time, start_station_name, end_station_id, trip_end_time,
 end_station_name, bike_id, user_type)
SELECT "Trip Id",
       "Trip  Duration"::int,
       "Start Station Id",
       TO_TIMESTAMP("Start Time", 'mm/dd/yyyy hh24:mi'),
       "Start Station Name",
       "End Station Id",
       TO_TIMESTAMP("End Time", 'mm/dd/yyyy hh24:mi'),
       "End Station Name",
       "Bike Id",
       "User Type"
FROM raw_jan_2021;

-- Jun 2021 to Present
DELETE
from raw_jun_2021_present
where "Trip  Duration" ~ 'Trip  Duration';

INSERT INTO trips
(trip_id, trip_duration_seconds, start_station_id, trip_start_time, start_station_name, end_station_id, trip_end_time,
 end_station_name, bike_id, user_type)
SELECT "Trip Id",
       "Trip  Duration"::int,
       "Start Station Id",
       TO_TIMESTAMP("Start Time", 'mm/dd/yyyy hh24:mi'),
       "Start Station Name",
       "End Station Id",
       TO_TIMESTAMP("End Time", 'mm/dd/yyyy hh24:mi'),
       "End Station Name",
       "Bike Id",
       "User Type"
FROM raw_jun_2021_present;

-- May 2021
DELETE
from raw_may_2021
where "Trip  Duration" ~ 'Trip  Duration';

INSERT INTO trips
(trip_id, trip_duration_seconds, start_station_id, trip_start_time, start_station_name, end_station_id, trip_end_time,
 end_station_name, bike_id, user_type)
SELECT "Trip Id",
       "Trip  Duration"::int,
       "Start Station Id",
       TO_TIMESTAMP("Start Time", 'mm/dd/yyyy hh24:mi'),
       "Start Station Name",
       "End Station Id",
       TO_TIMESTAMP("End Time", 'mm/dd/yyyy hh24:mi'),
       "End Station Name",
       "Bike Id",
       "User Type"
FROM raw_may_2021;

