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
		trip__duration::int,	
		start_station_id,
		to_timestamp(start_time,'mm/dd/yyyy hh24:mi:ss')::timestamp,
		start_station_name,
		end_station_id,
		to_timestamp(end_time, 'mm/dd/yyyy hh24:mi:ss')::timestamp,
		end_station_name,
		bike_id,
		user_type
FROM clean_2019_2022;