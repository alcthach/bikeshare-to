-- Initialize destination table for ridership data
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
