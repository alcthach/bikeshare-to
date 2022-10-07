/*
 * Bike Share Toronto 2017-2018 Data Cleaning
 * 2020-10-07
 * alcthach@gmail.com
 */

-- NOTE: `bike-share-2017-2018-data-profiling.sql` informs many of the decisions taken to process the data in this script

-- Create copy of raw 2017-18 data; not sure what the naming convention should be here, but I'll go with 'clean'
CREATE TABLE IF NOT EXISTS raw_2017_2018 AS 
(
SELECT * 
FROM temp_table tt 
);

-- Create `bike_id`, impute with nulls
ALTER TABLE clean_2017_2018 
	ADD COLUMN bike_id TEXT;

-- Deleting `trip_stop_time` rows with nulls
DELETE FROM raw_2017_2018 
WHERE trip_stop_time LIKE '%NULL%';

CREATE TABLE IF NOT EXISTS clean_2017_2018 AS
	SELECT	trip_id,
			CASE 
				WHEN trip_id::int < 1253915 THEN to_timestamp(trip_start_time, 'dd/mm/yyyy hh24:mi:ss')  -- dd/mm/yyyy
				WHEN trip_id::int >= 1253915 THEN to_timestamp(trip_start_time, 'mm/dd/yyyy hh24:mi:ss') -- mm/dd/yyyy
			END AS trip_started_at,
			CASE -- TODO: THERE'S A NULL THAT NEEDS TO BE REMOVED!
				WHEN trip_id::int < 1253915 THEN  to_timestamp(trip_stop_time, 'dd/mm/yyyy hh24:mi:ss')  -- dd/mm/yyyy
				WHEN trip_id::int >= 1253915 THEN to_timestamp(trip_stop_time, 'mm/dd/yyyy hh24:mi:ss') -- mm/dd/yyyy
			END AS trip_ended_at,
			trip_duration_seconds,
			from_station_id,
			from_station_name,
			to_station_id,
			to_station_name,
			user_type
	FROM raw_2017_2018 r  
	ORDER BY trip_id
	COLLATE "numeric";
	


SELECT *
FROM clean_2017_2018 c;