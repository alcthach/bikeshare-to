-- Initialize RAW destination table for ridership data
CREATE TABLE IF NOT EXISTS trips_clean (
	trip_id			varchar,
	trip_duration_seconds	int,
	start_station_id	varchar,
	trip_start_time		timestamp,
	start_station_name	varchar,
	end_station_id		varchar,
	trip_end_time		timestamp,
	end_station_name	varchar,
	bike_id			varchar,
	user_type		varchar
);


-- Initialize CLEAN destination table for ridership data
CREATE TABLE IF NOT EXISTS trips_raw (
	trip_id			text,
	trip_duration_seconds	text,
	start_station_id	text,
	trip_start_time		text,
	start_station_name	text,
	end_station_id		text,
	trip_end_time		text,
	end_station_name	text,
	bike_id			text,
	user_type		text
);
