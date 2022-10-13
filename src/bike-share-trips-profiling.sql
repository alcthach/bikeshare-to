/*
 * `trips` Data Profiling
 * alcthach@gmail.com
 * 2022-10-13
 */

SELECT 
	DISTINCT ON (split_part(trip_started_at::text, '-', 1))
	split_part(trip_started_at::text, '-', 1) AS start_year,
	bike_id
	FROM trips
WHERE NOT (trips IS NOT NULL);

-- Alright so this checks out as 'bike_id' might become a field starting from 2019?

-- More of a concern is the mis-formatted start_year, '0017'...

-- Thought this could be remedied by just replacing '00' with '20' but keep in mind this is of type timestamp right now

SELECT *
FROM trips t 
LIMIT 5;

-- Check for duplicate 'trip_id'
SELECT trip_id, COUNT(*)
FROM trips t 
GROUP BY trip_id 
HAVING COUNT(*) > 1;

-- Pull duplicate rows
SELECT a.*
FROM trips a
JOIN 
	(
	SELECT trip_id, COUNT(*)
	FROM trips 
	GROUP BY trip_id 
	HAVING COUNT(*) > 1
	) AS b
ON a.trip_id = b.trip_id
ORDER BY a.trip_id
COLLATE "numeric";

-- I mean... these trips might not provide any value to the analytics work, but it's good to keep in the raw data table

SELECT count(*)
FROM trips t 
WHERE end_station_id IS NULL AND start_station_id IS null;

-- station IDs might have to be imputed afterwards if there is a station info table

SELECT count(*)
FROM trips t 
WHERE trip_ended_at IS NULL;
-- Oh, this doesn't look too good

SELECT count(*)
FROM trips t
WHERE trip_started_at IS NULL;
-- Strange how all trips have a start time, but I'm missing a bunch of end time values

SELECT count(*)
FROM trips t 
WHERE end_station_name IS NULL;

SELECT count(*)
FROM trips t 
WHERE user_type IS NULL;


--------------------------------------------------------------------------------


-- Important Queries

-- Missing 'trip_ended_at' values

SELECT count(*)
FROM trips t
WHERE trip_ended_at IS NULL;
-- Strange how all trips have a start time, but I'm missing a bunch of end time values

