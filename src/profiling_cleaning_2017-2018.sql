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
CREATE TABLE clean_2017_2018
AS TABLE raw_start_stop_times_2017_2018;

/*
 THE REST OF THIS SCRIPT IS GOING TO WORK FROM THE clean_2017_2018, Re: will produce a data model ready to migrate to destination table
 */

-- Sanity check 
SELECT *
FROM clean_2017_2018;

-- TODO: Do a join to bring in the missing columns afterwards, I only have 

-- Count values for unique `year` column values 
SELECT start_time_year, COUNT(start_time_year) AS count
FROM clean_2017_2018 
GROUP BY start_time_year;

-- NOTES: Not too big of an issue here, just need to clean up rows with start_time_year LIKE '17'


SELECT stop_time_year, COUNT(stop_time_year) AS count
FROM clean_2017_2018
GROUP BY stop_time_year;

-- Looks like there's a lot more to take care of here

-- TODO: Deal with the single null value column after the JOIN, reason being that there will be an out of range issue 

-- Clean entries with stop_time_year='17'
SELECT *
FROM clean_2017_2018 
WHERE stop_time_year LIKE '17';

-- Test query TODO: re-factor into UPDATE ... SET statement
SELECT regexp_replace(stop_time_year, '17','2017') 
FROM clean_2017_2018 
WHERE stop_time_year LIKE '17';

-- Cleaning start and stop year columns
-- Just a note here, seems like regexp_replace() takes a POSIX expression whereas LIKE doesn't 

UPDATE clean_2017_2018 
	SET start_time_year = regexp_replace(start_time_year, '^17', '2017')
	WHERE start_time_year LIKE '17';
	
UPDATE clean_2017_2018 
	SET stop_time_year = regexp_replace(stop_time_year, '^17', '2017')
	WHERE stop_time_year LIKE '17';

UPDATE clean_2017_2018 
	SET stop_time_year = regexp_replace(stop_time_year, '^18', '2018')
	WHERE stop_time_year LIKE '18';

-- NOTE: There might be an issue with leading zeroes in the date strings, Re: 05 for 5th day of the month, I'll deal with it if it becomes an issue

-- CHECKPOINT: Year substrings have been standardized to YYYY, expect for one NULL case

-- TODO: After 2017 and 2018 data is cleaned, refactor this script to contain only necessary snippets

-- SANITY CHECK 
SELECT *
FROM clean_2017_2018 
LIMIT 5;

-- I'm pretty sure that I didn't deal with the change in date format across this data set...
-- Is there some sort of logic that I could employ to check for when the date format changes rather than eye-balling it?

SELECT *
FROM
	(SELECT *
	FROM 
		(
		SELECT  
		   DISTINCT ON (start_time_substring1, start_time_substring2) trip_id, start_time_substring1, start_time_substring2, trip_start_time
		FROM start_time_exploded ste
		) AS temp_4
	WHERE trip_id >= 1253914
	ORDER BY trip_id ASC) AS t2;


SELECT trip_id,
		raw_start_time,
		start_time_substring1,
		start_time_substring2
		FROM
	(SELECT
		DISTINCT ON (start_time_substring1, start_time_substring2) start_time_substring1, start_time_substring2, trip_id, raw_start_time
	FROM clean_2017_2018) AS t1
ORDER BY trip_id
COLLATE "numeric";

/*

NOTES:

- `start_time_substring1` appears to represent month data in 2018 data and maybe part of 2017 data, from month=7 (July and onwards)
- before July 2017 
- Seems like there might be a pattern to investigate, mainly the substrings starting with '0'

*/

SELECT *
FROM clean_2017_2018 
WHERE start_time_substring1 ~ '^0';

-- No news is good news here

SELECT * 
FROM clean_2017_2018
WHERE start_time_substring2 ~ '^0' AND start_time_year LIKE '2018';

-- Appears that there are no data from year 2018 that follow the `start_time_substring2` starting with '0' pattern

SELECT *
FROM clean_2017_2018
WHERE start_time_substring2 ~ '^0';

-- LIGHTBULB!

-- The logic that I'm going to execute on is as so,
-- If `start_time_substring2` starts with a '0' then this value represents a MONTH 
-- The issue is that I don't think the month column in this slice of the data is formatted as such?

SELECT start_time_substring2
FROM clean_2017_2018
WHERE start_time_substring2 ~ '^0'
GROUP BY start_time_substring2;

-- This goes to September?

SELECT start_time_substring2
FROM clean_2017_2018
GROUP BY start_time_substring2
ORDER BY start_time_substring2
COLLATE "numeric";

-- Alright the new logic might be something like
-- IF year is 2017 and substring2 <= 6 then set substring2 to start_time_month and set substring1 to start_time_day
-- Can be accomplished using a CASE WHEN STATEMENT 
-- In the other scenario if year is 2017 and month is greater than 6 then set substring1 to start_time_month and set substring2 to start_time_day
-- I made the assumption that there are two slices of data; the first slice before july 2017 follows dd/mm/yyyy format
-- July 2017 onwards follow mm/dd/yyyy format

-- There is an issue here because I cannot perform the logic mentioned above on strings

-- NOTE syntax might not be correct
-- KEEP
CREATE TABLE clean_month_day AS 
	SELECT trip_id, raw_start_time, start_time_substring1, start_time_substring2, start_time_year,
	CASE 
		WHEN (start_time_year LIKE '2017') AND (start_time_substring2 IN ('1', '01', '2', '02', '3', '03', '4', '04', '5', '05', '6', '06')) THEN start_time_substring2
		WHEN (start_time_year LIKE '2017') AND (start_time_substring2 IN ('1', '01', '2', '02', '3', '03', '4', '04', '5', '05', '6', '06')) AND 
		ELSE start_time_substring1
	END AS start_time_month, -- This catches everything ELSE, NO need TO overcomplicate things,
	CASE
		WHEN (start_time_year LIKE '2017') AND (start_time_substring2 IN ('1', '01', '2', '02', '3', '03', '4', '04', '5', '05', '6', '06')) THEN start_time_substring1
		ELSE start_time_substring2
	END AS start_time_day -- This catches everything ELSE, NO need TO overcomplicate things,
	FROM clean_2017_2018
	ORDER BY trip_id
	COLLATE "numeric";


-- Sanity check
SELECT start_time_substring2
FROM clean_2017_2018
WHERE start_time_substring2 IN ('1', '01', '2', '02', '3', '03', '4', '04', '5', '05', '6', '06')
GROUP BY start_time_substring2;


-- KEEP
SELECT trip_id, raw_start_time, start_time_year, start_time_month, start_time_day
FROM
(SELECT DISTINCT ON(start_time_month, start_time_day) start_time_month, start_time_day, trip_id, start_time_year, raw_start_time
FROM clean_month_day) AS t0
ORDER BY trip_id
COLLATE "numeric";

-- August 2017 looks broken; 01, 02, 03, 04 ,05, 06 get written to start_time_month for every new month
-- There seems to be an edge that I'm missing here
-- It looks like the pattern is for each month from August in 2017 the first 6 days are misrepresented, likely to my case when statement
-- It doesn what I want it to do which is look at substring2 and write to month if the value is within my list of strings I.E. (1,2,3,4,5,6,01,02,03,04,05,06)
-- I can limita the scope to (1-6) and (01,06)

--SANITY CHECK
SELECT trip_id, raw_start_time, start_time_year, start_time_month, start_time_day
FROM
(SELECT DISTINCT ON(start_time_month, start_time_day) start_time_month, start_time_day, trip_id, start_time_year, raw_start_time
FROM clean_month_day) AS t0
WHERE start_time_month LIKE '13'
ORDER BY trip_id
COLLATE "numeric";

