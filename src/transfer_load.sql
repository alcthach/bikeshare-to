-- Some preprocessing on the temp_table
ALTER TABLE temp_table ADD COLUMN trip_start_time_holder TIMESTAMP WITHOUT time ZONE NULL;

UPDATE temp_table SET trip_start_time_holder = trip_start_time::TIMESTAMP;

ALTER TABLE temp_table ALTER COLUMN trip_start_time TYPE TIMESTAMP WITHOUT time ZONE USING trip_start_time_holder;

ALTER TABLE temp_table DROP COLUMN trip_start_time_holder;

-- TODO: Write a stored PROC and execute on start and end time columns

UPDATE temp_table 
SET
	trip_start_time = to_timestamp(trip_start_time, 'DD/MM/YYYY hh24:mi'),
	trip_stop_time = to_timestamp(trip_stop_time, 'DD/MM/YYYY hh24:mi'),
	trip_duration_seconds = CAST(trip_duration_seconds AS int)
;

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

