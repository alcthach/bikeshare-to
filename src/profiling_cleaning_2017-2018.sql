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
		trip_start_time,
		raw_start_time,
		split_part(raw_start_time, '/', 1) AS start_time_substring1,
		split_part(raw_start_time, '/', 2) AS start_time_substring2,
		split_part(raw_start_time, '/', 3) AS start_time_year,
		split_part(raw_start_time, '/', 4) AS start_time_mmss,
		trip_stop_time,
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

-- Doing some thinking out loud here...
-- It seems like my logic would hold that substring2 values that are greater or equal to 6 would be considered month DATA
-- This was under the assumption that the date format flipped beginning from July 20217
-- The issue with my CASE WHEN statement was that yes I filtered for 2017 which was important, and I grabbed substring2 and wrote to MONTH 
-- I might be best served trying to understand when the data uses '0' as a prefix in the substring COLUMN 

-- SANITY CHECK, KEEP THIS ONE!!!
-- I'm going to have to take a closer look at this tomorrow
SELECT trip_id, raw_start_time, start_time_substring1, start_time_substring2
FROM
	(SELECT DISTINCT ON (start_time_substring2, start_time_substring1) start_time_substring1, start_time_substring2, trip_id, raw_start_time
	FROM clean_2017_2018) AS t0
ORDER BY trip_id
COLLATE "numeric";


-- NOTE: `clean_2017-2018` is the table that I want to work from; Re: `start_time_year` and `stop_time_year` are clean 
-- But month and day columns are still outstanding
-- I'll get a chance to understand the pattern in month and day data much better with this TABLE 
SELECT * 
FROM clean_2017_2018;


-- Group by split_part(raw_start_time) getting rid of the hh:mi slice
-- A bit messy here but just needed to understand what's going on with the assume prefix '0' in front of the month VALUES
-- I.E. Is there a particular pattern or can I employ some sort of logic to clean this data to match the format I need; yyyy/mm/dd
SELECT trip_id, start_date 
FROM
(SELECT DISTINCT ON (start_date) start_date, trip_id
FROM
	(SELECT trip_id, split_part(trip_start_time, ' ', 1) AS start_date
	FROM temp_table tt) AS t0) AS t1
ORDER BY trip_id
COLLATE "numeric";

-- I'll need to take notes on what I'm seeing as I profile the data here...
-- Alright so in this query I've transformed the original `trip_start_time` string to contain only the date portion
-- I'm not too concerned with the formatting here, moreso with what's going on with the prefix '0' situation
-- Starting from January 2017, it seems like `start_date` follows the format of dd/mm/yyyy
-- However, on the 13th day in January, the month value becomes '01' instead of '1'
-- Not quite sure why it changes like this, there doesn't seem to be a pattern within the month itself
-- It seems to follow this pattern up until the end of January 
-- It follows this pattern all the way up to the June, I.E. switches to using '0' on day 13 in the month
-- However, in July 2017, the date format switches to mm/dd/yyyy
-- In July, Aug, and Sep 2017, neither the day nor the month contain a '0' prefix
-- However, in Oct, the day value contains '0' prefix from the first day, this continues to Nov and Dec
-- In 2018, there is no use of '0' prefix in either day or month VALUES 

-- What implications does this have in terms of how I clean the month and day values
-- I.E: What logic do I apply to ensure I have the correct values in both the day and months COLUMNS 
-- What happens with how I manage the stop_time data? Same pattern? Worry about that later!

-- Some ideas surrounding logic; pseudocode

/*
Some assumptions:
Up until June 2017, substring1 likely represents the day, and substring2 represents the month that the bike trip started in

PSEUDOCODE:
if year is 2017 and cast(substring1) < 14 then set start_month to substring2
elid year is 2017 and cast(substring1) > 13 then set start_month to 

actually this might not be needed...

the prefix pattern on the 13th day is consistent until the 7th month, the date format consistent switches up to that point, which means
I could employ logic like:


if year is 2017 and substring1::int <7 then set start_month to substring2 
	this assumes that substring1 values are bound between when year is 2017
	are there any situations where this is not the case? no b/c in July 2017 the date from changes to mm/dd/yyyy
	not possible unless the trip_id is not index incremently for some reason

alright so it seems like that logic works well

*/

-- WIP
SELECT trip_id, start_date, start_month, start_time_substring1, start_time_substring2
FROM
(
SELECT DISTINCT ON (start_date) start_date, start_time_substring1, start_time_substring2, trip_id, start_month -- better TO use slice OF date string
FROM
(
SELECT trip_id, regexp_matches(raw_start_time, '.+/.+/.+/') AS start_date, start_time_substring1, start_time_substring2,
	CASE 
		WHEN start_time_year LIKE '2017' AND start_time_substring2::int < 7 THEN start_time_substring2 -- substring2 changes AT july 2017 something TO watch OUT for
		--WHEN start_time_year LIKE '2017' AND start_time_substring1::int >= 7 THEN start_time_substring2
		WHEN start_time_year LIKE '2018' THEN start_time_substring1
	END AS start_month
	FROM clean_2017_2018
) AS t1
) AS t2
ORDER BY trip_id 
COLLATE "numeric";

-- testing regex for clean_2017_2018
SELECT *
FROM clean_2017_2018 c 
WHERE raw_start_time ~'.+/.+/.+/.+';

SELECT regexp_matches(raw_start_time, '.+/.+/.+/') AS start_date
FROM clean_2017_2018 c;

---

-- Continuing from 2022-10-06
-- Just re-jogging my memory
-- From what I remember I was running into some issues with the logic, I need to think about whether I want to use the exploded columns or the raw start dates, or something ELSE 

-- Let's just slice it manually for all intents and purposees

SELECT *
FROM clean_2017_2018 c 
WHERE start_time_substring2 LIKE '1' AND start_time_substring1 LIKE '7'
ORDER BY trip_id 
COLLATE "numeric";

-- USE trip_id LIKE '719626' as the boundary between the data format changes

SELECT trip_id, raw_start_time, start_time_substring1
​	FROM
	(SELECT DISTINCT ON (start_time_substring1) start_time_substring1, trip_id, raw_start_time
	FROM clean_2017_2018
	WHERE trip_id::int < 719626) AS t0;


-- LOGIC ERROR IDENTIFIED start_time_substring1 and start_time_substring2; seems like I might have mixed them up here based on the query below
SELECT *
FROM clean_2017_2018 c 
WHERE trip_id::int < 719626;

-- Yep, I think this is better; dd/mm/yyyy
SELECT DISTINCT ON (start_time_substring1) start_time_substring1, start_time_substring2, trip_id, raw_start_time 
FROM clean_2017_2018 c 
WHERE trip_id::int < 719626;

-- I'm going to go ahead build the date string back up again, but before that I'll have to fix the way `clean_2017_2018` is modelled. Re: Switch the substring columns
SELECT DISTINCT start_time_substring2
FROM clean_2017_2018 c
WHERE trip_id::int > 719626;

-- Initialized raw_2017_2018 from up above

-- Assumes dd/mm/yyyy format 
-- Something is really weird here, if substring1 represents day then the range should be much larger, not 1-6
SELECT *
FROM raw_2017_2018
WHERE trip_id::int < 719626
ORDER BY trip_id
COLLATE "numeric";


--- This query let's me select distinct on the the raw timestamp to see whats going on 
SELECT	trip_id, 
		trip_start_time,
		start_time_substring1,
		start_time_substring2
FROM
	(
	SELECT DISTINCT ON	(split_part(trip_start_time, ' ', 1)) trip_start_time, 
						trip_id, 
						start_time_substring1, 
						start_time_substring2
	FROM raw_2017_2018
	-- WHERE trip_id::int < 719626 -- Added FILTER here, NOT quite sure what's going ON here still...
	WHERE trip_id::int >= 1253914 -- correct filter
	) AS t0
ORDER BY trip_id
COLLATE "numeric";

-- Actually! I think my filter logic might be a bit faulty actually... Yep my logic was broken...
-- The trip_id I should be indexing at is 12365571 or something around that neighbourhood
-- I'm a bit worried because it looking like I'm missing some data in July 2017 but that's okay
-- Source of truth is trip_id, so long as it assumes each subsequent trip is indexed incrementally 

-- This is where the data format shifts; I.E. trip_id:: >= 1_253_914
SELECT *
FROM raw_2017_2018
WHERE trip_id::int > 1253140 AND trip_id::int < 1253915;

-- My logic is as follows
-- if trip_id:: >= 1_253_914 then month = start_time_substring1 and  day = start_time_substring2
-- else month = start_time_substring2 and day = start_time_substring1
-- TODO: Take a look at the load to destination table script to see how it functions, work backwards from there to figure out how to model `raw_2017_2018` table

SELECT
	trip_id,
	trip_start_time,
	CASE 
		WHEN trip_id::int < 1253915 THEN start_time_substring1
		WHEN trip_id::int >= 1253915 THEN start_time_substring2
	END AS start_time_day,
	CASE 
		WHEN trip_id::int < 1253915 THEN start_time_substring2
		WHEN trip_id::int >= 1253915 THEN start_time_substring1
	END AS start_time_month
FROM raw_2017_2018
ORDER BY trip_id
COLLATE "numeric";





-- casting as timestamp based on trip_id
-- LOOKING NICE, except for the stop time data
SELECT
	trip_id,
	trip_start_time,
	CASE 
		WHEN trip_id::int < 1253915 THEN to_timestamp(trip_start_time, 'dd/mm/yyyy hh24:mi:ss')  -- dd/mm/yyyy
		WHEN trip_id::int >= 1253915 THEN to_timestamp(trip_start_time, 'mm/dd/yyyy hh24:mi:ss') -- mm/dd/yyyy
	END AS start_ts,
	CASE -- TODO: THERE'S A NULL THAT NEEDS TO BE REMOVED!
		WHEN trip_id::int < 1253915 THEN  to_timestamp(trip_stop_time, 'dd/mm/yyyy hh24:mi:ss')  -- dd/mm/yyyy
		WHEN trip_id::int >= 1253915 THEN to_timestamp(trip_stop_time, 'mm/dd/yyyy hh24:mi:ss') -- mm/dd/yyyy
	END AS stop_ts
FROM raw_2017_2018
ORDER BY trip_id
COLLATE "numeric";

-- The error that I'm being thrown here seems to suggest that the computer is not getting minute values for a row or ROWS 
-- I might be best served trying to parse for minutes data `trip_stop_time` that is LIKE 'NU'

SELECT * 
FROM temp_table 
WHERE trip_stop_time LIKE '%NU%'; -- '%' CHARACTER used AS a wildcard

-- Seems like the query above just returns one element in the dataset; which is good
-- I don't think this row is going to be usable for the dataset 
-- Appears that the trip started somewhere, but there is no end point for the trip, hence no stop time/duration
-- I don't want to speculate but either there was a glitch, or the bike was never returned by this customer

-- KEY DECISION: Dropping this ROW in order to move forward with the date cleaning
-- NOTE: I'll be doing this on the processed table, not the raw table pulled using pgfutter

SELECT *
FROM raw_2017_2018 r 
WHERE trip_stop_time LIKE '%NULL%';

-- Deleteing the null value
DELETE FROM raw_2017_2018 
WHERE trip_stop_time LIKE '%NULL%';







-- Checking out the stop times to make sure nothing strange is happening...
-- I mean, I don't the trips have indexed properly
-- A bit concerned here...
SELECT	trip_id,
		trip_start_time, -- This would EXPLAIN why...
		trip_stop_time,
		stop_time_substring1,
		stop_time_substring2		
FROM
	(
	SELECT	
		DISTINCT ON (split_part(trip_stop_time, ' ', 1))
		trip_stop_time,
		trip_start_time,
		trip_id,
		stop_time_substring1,
		stop_time_substring2
	FROM raw_2017_2018 r
	) AS t0
ORDER BY trip_id
COLLATE "numeric"; 

