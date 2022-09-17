-- PREPROCESSING ON temp_table
UPDATE temp_table 
SET
	trip_start_time = to_timestamp(trip_start_time, 'DD/MM/YYYY hh24:mi')::timestamp,
	trip_stop_time = to_timestamp(trip_stop_time, 'DD/MM/YYYY hh24:mi')::timestamp,
	trip_duration_seconds = CAST(trip_duration_seconds AS int)
;

@target_table = temp_table
@target_column = trip_start_time

CREATE PROCEDURE convert_columns
	AS
		ALTER @target_table ADD COLUMN column_name_holder timestamp WITHOUT time ZONE NULL; 
		UPDATE @target_table SET column_name_holder = @target_column::timestamp;
		ALTER TABLE @target_table ALTER COLUMN @target_column TYPE TIMESTAMP WITHOUT time ZONE USING column_name_holder;
		ALTER TABLE @target_table DROP COLUMN trip_start_time_holder;
		



-- Add temporary column for trip start time and setting type to timestamp without time zone
-- NOTE: I think that it should actually be EST for accuracy sake...
ALTER TABLE temp_table ADD COLUMN trip_start_time_holder TIMESTAMP WITHOUT time ZONE NULL;
-- ALTER TABLE temp_table ADD COLUMN trip_start_time_holder TIMESTAMP NULL;



-- Set the temporary column as trip start time, with the data type casted as TIMESTAMP
-- The statement below actually contains an expression; trip_start_time_holder = trip_start_time::TIMESTAMP;                   
-- This means the next statement below actually uses the expression I think...
-- Yup, the expression is actually `trip_start_time::TIMESTAMP`

UPDATE temp_table SET trip_start_time_holder = trip_start_time::TIMESTAMP;

-- Not sure what the `USING` keyword does here...
-- Let's rubber duck this
-- Change temp_table
-- By changing trip_start_time to type TIMESTAMP w/o timezone using trip_start_time_holder
-- Looks like I'm going from trip_start_time_holder with is the OG column casted as TIMESTAMP, then going to trip_start_time
ALTER TABLE temp_table ALTER COLUMN trip_start_time TYPE TIMESTAMP WITHOUT time ZONE USING trip_start_time_holder;

ALTER TABLE temp_table DROP COLUMN trip_start_time_holder;

-- TODO: Write a stored PROC and execute on start and end time columns



INSERT INTO trips (trip_id,
					trip_duration,
					start_station_id,
					start_time,
					start_station_name,
					end_station_id,
					-- end_time,
					end_station_name,
					-- bike_id, DOES NOT EXIST IN 2017 DATA
					user_type
)
SELECT trip_id,
		CAST(trip_duration_seconds AS int),	
		from_station_id,
		trip_start_time,
		-- to_timestamp(trip_start_time, 'DD/MM/YYYY hh24:mi:ss'),
		from_station_name,
		to_station_id,
		-- to_timestamp(trip_stop_time, 'DD/MM/YYYY hh24:mi:ss'),
		to_station_name,
		user_type
FROM temp_table;

