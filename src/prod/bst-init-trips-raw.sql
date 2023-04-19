-- Initialize destination table for ridership data
CREATE TABLE IF NOT EXISTS trips_raw (
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
