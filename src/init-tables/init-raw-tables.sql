
-- ASCII
CREATE TABLE IF NOT EXISTS raw_2017_q1q2 (
	trip_id			text,
	trip_start_time 	text,
	trip_stop_time 		text,
	trip_duration_seconds 	text,
	from_station_id 	text,
	from_station_name	text,
	to_station_id		text,
	to_station_name		text,
	user_type		text
);

-- ASCII
CREATE TABLE IF NOT EXISTS raw_2017_q3q4 (
	trip_id			text,
	trip_start_time 	text,
	trip_stop_time 		text,
	trip_duration_seconds 	text,
	from_station_name	text,
	to_station_name		text,
	user_type		text
);

-- UTF-8
CREATE TABLE IF NOT EXISTS raw_2018 (
	trip_id			text,
	trip_duration_seconds	text,
	from_station_id		text,
	trip_start_time		text,
	from_station_name	text,
	trip_stop_time		text,
	to_station_id		text,
	to_station_name		text,
	user_type		text
);

-- UTF-8	
CREATE TABLE IF NOT EXISTS raw_2019_2020 (
	"Trip Id"		text,
	"Trip  Duration"	text,
	"Start Station Id"	text,
	"Start Time" 		text,
	"Start Station Name"	text,
	"End Station Id"	text,
	"End Time"		text,
	"End Station Name"	text,
	"Bike Id"		text,
	"User Type"		text
);

-- WINDOWS-1258
CREATE TABLE IF NOT EXISTS raw_jan_2021 (
	"Trip Id"		text,
	"Trip  Duration"	text,
	"Start Station Id"	text,
	"Start Time" 		text,
	"Start Station Name"	text,
	"End Station Id"	text,
	"End Time"		text,
	"End Station Name"	text,
	"Bike Id"		text,
	"User Type"		text
);

-- UTF-8
CREATE TABLE IF NOT EXISTS raw_feb_apr_2021 (
	"Trip Id"		text,
	"Trip  Duration"	text,
	"Start Station Id"	text,
	"Start Time" 		text,
	"Start Station Name"	text,
	"End Station Id"	text,
	"End Time"		text,
	"End Station Name"	text,
	"Bike Id"		text,
	"User Type"		text
);

-- EUC-TW
CREATE TABLE IF NOT EXISTS raw_may_2021 (
	"Trip Id"		text,
	"Trip  Duration"	text,
	"Start Station Id"	text,
	"Start Time" 		text,
	"Start Station Name"	text,
	"End Station Id"	text,
	"End Time"		text,
	"End Station Name"	text,
	"Bike Id"		text,
	"User Type"		text
);


-- UTF-8 
CREATE TABLE IF NOT EXISTS raw_jun_2021_present (
	"Trip Id"		text,
	"Trip  Duration"	text,
	"Start Station Id"	text,
	"Start Time" 		text,
	"Start Station Name"	text,
	"End Station Id"	text,
	"End Time"		text,
	"End Station Name"	text,
	"Bike Id"		text,
	"User Type"		text
);
