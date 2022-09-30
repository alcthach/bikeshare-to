-- Eliminates the need to convert `trip_id` to type int; Re: Enables natural sorting for numbers in a string
CREATE COLLATION numeric (provider = icu, locale = 'en@colNumeric=yes');

-- Explode `trip_start_time` field

-- Create raw_start_time column
ALTER TABLE temp_table
	ADD COLUMN raw_start_time TEXT,
	ADD COLUMN raw_stop_time TEXT;

-- Write `trip_start_time` to `raw_start_time` with space character replaces with '/'
UPDATE temp_table
	SET raw_start_time = regexp_replace(trip_start_time, ' ', '/');
	
UPDATE temp_table	
	SET raw_stop_time = regexp_replace(trip_stop_time, ' ', '/');

CREATE TABLE IF NOT EXISTS raw_2017_2018 AS
	SELECT
		trip_id,
		raw_start_time,
		split_part(raw_start_time, '/', 1) AS start_time_substring1,
		split_part(raw_start_time, '/', 2) AS start_time_substring2,
		split_part(raw_start_time, '/', 3) AS start_time_year,
		split_part(raw_start_time, '/', 4) AS start_time_mmss,
		raw_stop_time,
		split_part(raw_stop_time, '/', 1) AS stop_time_substring1,
		split_part(raw_stop_time, '/', 2) AS stop_time_substring2,
		split_part(raw_stop_time, '/', 3) AS stop_time_year,
		split_part(raw_stop_time, '/', 4) AS stop_time_mmss,
		trip_duration_seconds,
		from_station_id,
		from_station_name,
		to_station_id,
		to_station_name,
		user_type
	FROM temp_table
	ORDER BY trip_id
	COLLATE "numeric";


-- Checks `start_time_year` 
SELECT start_time_year 
FROM raw_2017_2018
GROUP BY start_time_year;

-- Check `stop_time_year`
-- NOTE: Something strange is happening here, stranger than `start_time_year`
SELECT stop_time_year 
FROM raw_2017_2018 
GROUP BY stop_time_year;

-- Investigate further
SELECT *
FROM raw_2017_2018
WHERE stop_time_year LIKE '';

-- Count values
-- NOTE: Not sure why there is ride data from 2019...
SELECT stop_time_year, COUNT(stop_time_year)
FROM raw_2017_2018 
GROUP BY stop_time_year;


-- Choose to drop this record, Re: Not usable, however this is only one record out of millions
SELECT *
FROM temp_table tt 
WHERE trip_id LIKE '2302635';

-- Check for 2019 trips
-- NOTE: Makes sense that the trip started in 2018 and ended in 2019
SELECT *
FROM raw_start_stop_times_2017_2018 rsst 
WHERE stop_time_year LIKE '2019';

-- Create copy of `raw_start_stop_times_2017_2018`
CREATE clean_2017_2018
AS raw_


