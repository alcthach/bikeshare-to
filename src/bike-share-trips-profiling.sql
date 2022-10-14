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

SELECT trip_id, COUNT(*)
FROM trips t
GROUP BY trip_id 
HAVING COUNT(*) > 1;

-- I'm not sure if I did something here I might have to retrace my steps to see if I errantly inserted this dupe rows...
-- After reviewing the code, I don't suspect that I did

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

-- To be honest I don't think that this data is useful in anyway in terms of observing trends in the ridership
-- I can only speculate that there might have been bugs in the production system because of the trip durations and start and end stations
-- Reason being is I can understand if a trip started and ended at the same station
-- However,I don't think it would be meaningful and it would cost a lot to storage these DATA
-- I'm just thinking about all the instances that a trip was initiated and then cancelled
-- Would make sense to not have it live in this dataset or else this would make reporting, Re: cleaning the data more tedious and less efficient
-- I.E. this would cost more


-- For that reason, I think I will drop these rows from the data set

SELECT count(*)
FROM trips t 
WHERE trip_duration = 0;

-- I mean this is a whole lot of data here...

SELECT *
FROM trips 
WHERE trip_duration = 0;

-- Hmm looks like we're running into issues with the way that the trip duration is calculated
-- I failed to check if there were zeroes in the other data before loading it to the destination table

-- Exploring trip_duration = 0
-- I suspect that a bunch of these trip durations might have been miscalculated, this is just from an eye test

-- Just making sure there are no trips in here at are over an hour long
SELECT *
FROM 
(
SELECT 
	trip_id,
	trip_duration,
	split_part( (trip_ended_at - trip_started_at)::TEXT, ':', 1) AS calculated_trip_duration
FROM trips t
WHERE trip_duration = 0
) AS t0
WHERE calculated_trip_duration NOT LIKE '00'
;
-- I can't imagine trying to double-check if each row has the correct trip duration, just too many rows
-- However, I think at the minimum I'll try to ensure some of the obvious miscalculations are addressed

-- I think I ran into a bit of a logic error, I might have imputed trip_durations as minutes rather than seconds...

-- Yep, I definitely did
-- Not too big of an issue though; I could just reinitialize the tables