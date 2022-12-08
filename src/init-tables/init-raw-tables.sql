
CREATE TABLE IF NOT EXISTS raw_2017_Q1Q2 (
	trip_id			varchar,
	trip_start_time 	varchar,
	trip_stop_time 		varchar,
	trip_duration_seconds 	varchar,
	from_station_id 	varchar,
	from_station_name	varchar,
	to_station_id		varchar,
	to_station_name		varchar,
	user_type		varchar
);


CREATE TABLE IF NOT EXISTS raw_2017_Q3Q4 (
	trip_id			varchar,
	trip_start_time 	varchar,
	trip_stop_time 		varchar,
	trip_duration_seconds 	varchar,
	from_station_name	varchar,
	to_station_name		varchar,
	user_type		varchar
);


CREATE TABLE IF NOT EXISTS raw_2018 (
	trip_id			varchar,
	trip_duration_seconds	varchar,
	from_station_id		varchar,
	trip_start_time		varchar,
	from_station_name	varchar,
	trip_stop_time		varchar,
	to_station_id		varchar,
	to_station_name		varchar,
	user_type		varchar
);


CREATE TABLE IF NOT EXISTS raw_2019_present (
	"Trip Id"		varchar,
	"Trip  Duration"	varchar,
	"Start Station Id"	varchar,
	"Start Time" 		varchar,
	"Start Station Name"	varchar,
	"End Station Id"	varchar,
	"End Time"		varchar,
	"End Station Name"	varchar,
	"Bike Id"		varchar,
	"User Type"		varchar
);
