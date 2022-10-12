/*
 * Profiling 2019-2022 Bike Share Toronto Ridership
 * Alex Thach - alcthach@gmail.com
 * 2022-10-10
 */

SELECT count(*)
FROM temp_table_2019_2022 tt ;

-- Check for nulls, Re: 249 rows have null values in them
SELECT count(*)
FROM temp_table_2019_2022 tt 
WHERE NOT (tt IS NOT NULL);

-- Pull rows with NULL values
SELECT * 
FROM temp_table_2019_2022 tt 
WHERE NOT (tt IS NOT null);

-- NOTE: Seems like `user_type` field contains nulls 

-- Just a simple counting query to make sure the count matches what I have above with the global NULL check
SELECT count(*) 
FROM temp_table_2019_2022 tt 
WHERE user_type IS NULL;

-- Pull rows with NULL values; `end_station_id`
SELECT DISTINCT(split_part(end_station_id, ' ', 1))  
FROM temp_table_2019_2022 tt 
WHERE NOT (tt IS NOT null);
-- NOTE: Only appears to happen in October 2020; I might have to load this data myself, or at the very least take a look at what's going on here
-- Might have to drop these rows


SELECT *
FROM temp_table_2019_2022 tt;

-- Just loaded Oct 2020 data

-- Sanity check 
SELECT * 
FROM temp_table_2020_10 tt;
-- NOTE: Looks okay with this query

-- Check row count
SELECT COUNT(*)
FROM temp_table_2020_10 tt;

-- Check for nulls
SELECT COUNT(*)
FROM temp_table_2020_10 tt 
WHERE NOT (tt IS NOT NULL);

-- Pull rows with null in them
SELECT *
FROM temp_table_2020_10 tt 
WHERE NOT (tt IS NOT null);

-- TODO: Figure out what's going on here. Am I missing data that I might be able to impute?

/*
 * `trip_duration` looks like `start_station_id`
 * `start_station_id` is `start_time` and `end_station_id` is `end_time`
 * `start_time` is `start_station_name` 
 * `end_time` is `end_station_name`
 * `end_station_name` is `bike_id`
 * `bike_id` is `user_type`
 * `trip_id` might be holding on to some `trip_id` and `trip_duration` data
 * `end_station_name` might be `bike_id`
 */ 

-- Check string length in `trip_id`
SELECT length(trip_id) AS trip_id_str_length, count(*)
FROM temp_table_2020_10 tt
GROUP BY trip_id_str_length;

-- Does any combination of this add up to 249; the number of rows in question?
-- YES
-- `trip_id` with str lengths 10, 11, 12 added up to 249
-- What that tells me is that the expect str length for `trip_id` is 7 or 8; helpful but still 

-- Maybe I could query the other tables too

-- 2017 and 2018 data; makes sense that there might be short strings with data that's earlier on 
SELECT length(trip_id) AS trip_id_str_length, count(*)
FROM temp_table
GROUP BY trip_id_str_length;

SELECT length(trip_id) AS trip_id_str_length, count(*)
FROM temp_table_2019_2022 tt
GROUP BY trip_id_str_length;

-- Split the strings that are greater than 8 characters in length

-- Just a quite check to make sure I'm not going crazy
SELECT *
FROM temp_table_2020_10 tt
WHERE length(trip_id) > 8 AND user_type IS NOT NULL;


-- Employing best practice here; filter data first as subquery, then performing my operations on that slice
-- I.E. substrings

SELECT trip_id, regexp_split_to_array(trip_id, '[1-9]')
FROM
(
	SELECT * FROM temp_table_2020_10 tt 
	WHERE length(trip_id) > 8
) AS t0;

SELECT trip_id, substring(trip_id FROM 8) AS trip_id_suffix
FROM temp_table_2020_10 tt 
WHERE length(trip_id) > 8;

-- I think I'm working off the assumption that string lengths at maximum should be 8 characters long
-- However, the issue might be if 7-character long trip_id only occurs earlier in time
-- Because what I'm doing right now is arbitrarily slicing 'trip_id' strings
-- I'll need to see what the behaviour of 7 and 8 character length 'trip_id' values are like 


-- Seems like the switch from 7 to 8 characters would make sense as the volume of trips complete increases over time
SELECT DISTINCT ON (split_part(start_time, ' ', 1)) trip_id, length(trip_id), split_part(start_time, ' ', 1) AS start_date
FROM temp_table_2020_10 tt 
WHERE length(trip_id) < 9;

-- Check trips from pre-2020; note that the 'trip_id' length is smaller and the values are also smaller as well
SELECT *
FROM temp_table tt;

-- Not the most efficient query to run but it look like 'trip_id' values are 8 characters long starting in October 2020
-- Keeping this in mind the decision to split the string from index 9 would make the most sense
SELECT *
FROM
(SELECT DISTINCT ON (split_part(start_time, ' ', 1)) trip_id, length(trip_id), split_part(start_time, ' ', 1) AS start_date
FROM temp_table_2019_2022 tt) AS t0
ORDER BY trip_id
COLLATE "numeric";

-- Explode 'trip_id_raw' into 'trip_id' and 'trip_duration'
-- If I find the time different between the trip start and end times I should have the same values 'trip_duration' COLUMN 
SELECT trip_id AS trip_id_raw, 
	LEFT(trip_id, 8) AS trip_id_clean, 
	substring(trip_id FROM 9) AS trip_duration
FROM temp_table_2020_10 tt;


-- Check split 'trip_id_suffix' against calculated trip duration
-- NOTE: This checks out; safe to clean the 'trip_id' columns with the logic mentioned above
SELECT trip_id_clean,
		start_time,
		end_time,
		start_time - end_time trip_duration_minutes ,
		trip_id_suffix_to_minutes
FROM
	(
	SELECT trip_id AS trip_id_raw,
		split_part(start_station_id, ' ', 2)::time start_time,
		split_part(end_station_id, ' ', 2)::time end_time,
		LEFT(trip_id, 8) AS trip_id_clean, 
		substring(trip_id FROM 9)::int/60 AS trip_id_suffix_to_minutes
	FROM temp_table_2020_10 tt
	WHERE length(trip_id) > 8
	) AS t0
ORDER BY trip_id_clean
COLLATE "numeric";

-- TYPO in 'trip_duration' header, Re: Two underscores instead of one
SELECT *
FROM temp_table_2019_2022 tt
LIMIT 5;

SELECT *
FROM october_2020_raw;

-- Clean 249 rows with 'user_type' is NULL
-- NOTE: These rows will not be able to join to the raw october data Re: No key to join on
-- Instead it might be better to drop the NULL ROWS 

CREATE TABLE IF NOT EXISTS clean_partial_oct_2020 AS
SELECT 
		LEFT(trip_id, 8) AS trip_id, 
		substring(trip_id FROM 9) AS trip__duration,
		trip__duration AS start_station_id,
		start_station_id AS start_time,
		start_time AS start_station_name,
		start_station_name AS end_station_id,
		end_station_id AS end_time,
		end_time AS end_station_name, 
		end_station_name AS bike_id,
		bike_id AS user_type
		FROM october_2020_raw
WHERE user_type IS NULL;

-- Drop null values from temp_table_2020_10 tt 

DELETE FROM october_2020_raw
WHERE user_type IS NULL;

-- Insert clean rows from clean_partial_oct_2020
-- 249 rows, perfect
INSERT INTO october_2020_raw 
SELECT * FROM clean_partial_oct_2020;

-- Actually I could insert directly into temp_table_2019_2022 ...

-- Let's do that instead

CREATE TABLE IF NOT EXISTS
raw_2019_2022
AS TABLE temp_table_2019_2022;

SELECT count(*)
FROM raw_2019_2022
WHERE user_type IS NULL;

CREATE TABLE IF NOT EXISTS clean_2019_2022
AS TABLE raw_2019_2022;

DELETE FROM clean_2019_2022
WHERE user_type IS NULL;

INSERT INTO clean_2019_2022
SELECT * FROM clean_partial_oct_2020;

-- Looks good!
SELECT *
FROM clean_2019_2022
WHERE NOT (clean_2019_2022 IS NOT null);

-- Clean missing 'trip__duration' values, create as table to replace missing values

CREATE TABLE clean_missing_trip_duration_2019 AS
	SELECT 
		trip_id,
		split_part( (end_time_mmss - start_time_mmss)::TEXT , ':', 2) AS trip__duration,
		start_station_id,
		start_time,
		start_station_name,
		end_station_id,
		end_time,
		end_station_name,
		bike_id,
		user_type
	FROM
		(
		SELECT
			*,
			split_part(start_time, ' ', 2)::time AS start_time_mmss,
			split_part(end_time, ' ', 2)::time AS end_time_mmss
		FROM clean_2019_2022 c 
		WHERE trip__duration LIKE ''
		) AS t0;
	
-- Delete rows with missing 'trip__duration' values
DELETE FROM clean_2019_2022 
WHERE trip__duration LIKE '';

-- Replace deleted rows from above query
INSERT INTO clean_2019_2022 
SELECT *
FROM clean_missing_trip_duration_2019;

