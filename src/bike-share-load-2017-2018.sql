INSERT INTO trips 
(
					trip_id,
					trip_duration,
					start_station_id,
					trip_started_at,
					start_station_name,
					end_station_id,
					trip_ended_at,
					end_station_name,
					bike_id,
					user_type
)
SELECT	trip_id,
		trip_duration_seconds::int,	
		from_station_id,
		trip_started_at,
		from_station_name,
		to_station_id,
		trip_ended_at,
		to_station_name,
		bike_id,
		user_type
FROM clean_2017_2018;