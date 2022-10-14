/*

Bikeshare Toronto Initialization Script
athach - alcthach@gmail.com
Created: 2022-09-11

 */

-- This is going to be the main table that I load all the trip table to
CREATE TABLE IF NOT EXISTS trips (
	trip_id			varchar,			
	trip_duration		int,
	start_station_id	varchar,
	trip_started_at		timestamp,
	start_station_name	varchar,
	end_station_id		varchar,
	trip_ended_at		timestamp,
	end_station_name	varchar,
	bike_id			varchar,
	user_type		varchar
);
	
-- CREATE TEMP TABLE IF NOT EXISTS temp_table(
-- );

-- Don't need this anymore thanks to pgfutter
-- \COPY temp_table FROM '/tmp/bikeshare_ridership_2017_Q1.csv' DELIMITER ',' HEADER CSV;	

-- TODO Write procedure or BASH script to load csv to a temporary table and to write the data to the appropriate columns in the main table
-- Re: Total number and order of columns vary across the different csv files
