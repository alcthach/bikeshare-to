-- Transform and Load Script for 2017 (partial) and 2018 data
-- alcthach@gmail.com
-- 2022-09-19

-- Transform data to appropriate types
UPDATE temp_table
SET
	trip_start_time = to_timestamp(trip_start_time, 'DD/MM/YYYY hh24:mi')::timestamp,
	trip_stop_time = to_timestamp(trip_stop_time, 'DD/MM/YYYY hh24:mi')::timestamp,
	trip_duration_seconds = CAST(trip_duration_seconds AS int)
;

-- Transform trip_start_time
ALTER TABLE temp_table ADD COLUMN trip_start_time_holder TIMESTAMP WITHOUT time ZONE NULL;
UPDATE temp_table SET trip_start_time_holder = trip_start_time::TIMESTAMP;
ALTER TABLE temp_table ALTER COLUMN trip_start_time TYPE TIMESTAMP WITHOUT time ZONE USING trip_start_time_holder;
ALTER TABLE temp_table DROP COLUMN trip_start_time_holder;
	

-- Transform trip_stop_time
ALTER TABLE temp_table ADD COLUMN trip_stop_time_holder TIMESTAMP WITHOUT time ZONE NULL;
UPDATE temp_table SET trip_stop_time_holder = trip_stop_time::TIMESTAMP;
ALTER TABLE temp_table ALTER COLUMN trip_stop_time TYPE TIMESTAMP WITHOUT time ZONE USING trip_stop_time_holder;
ALTER TABLE temp_table DROP COLUMN trip_stop_time_holder;

-- Migrate temp_table data to `trips`
INSERT INTO trips
(
	trip_id,
	start_station_id,
	start_time,
	start_station_name,
	end_station_id,
	end_time,
	end_station_name,
	user_type
)
SELECT trip_id,
	from_station_id,
	trip_start_time,
	from_station_name,
	to_station_id,
	to_station_name,
	user_type
FROM temp_table;
