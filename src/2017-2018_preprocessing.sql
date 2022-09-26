/*
Bikeshare Toronto - Preprocessing Script
alcthach@gmail.com
2022-09-22
*/

SELECT COUNT(*)
FROM temp_table tt;

-- Exploding `trip_start_time` column, create as a view
-- TODO might want to save as a view to cut on costs of ordering by `trip_id`
CREATE TABLE start_time_exploded AS
SELECT trip_id,
	trip_start_time,
	split_part(trip_start_time, '/', 1) AS start_time_substring1, 
	split_part(trip_start_time, '/', 2) AS start_time_substring2,
	split_part(trip_start_time, '/', 3) AS start_time_year_time
FROM temp_table tt
ORDER BY trip_id ASC;

-- A USING clause must be provided if there is no implicit or assignment cast from old to new type
-- I think I understand what's going on here
-- There is no datatype to reference so I have to feed it the explicit assignment by showing it `column::int`
ALTER TABLE start_time_exploded 
	ALTER COLUMN start_time_substring1 TYPE int USING (start_time_substring1::int),
	ALTER COLUMN start_time_substring2 TYPE int USING (start_time_substring2::int),
	ALTER COLUMN trip_id TYPE int USING (trip_id::int);

-- Sanity check
SELECT *
FROM start_time_exploded ste; 


-- NOTE: Doesn't save the first entry in the partition but that's okay


-- This is where the date format changes to DD/MM/YYYY, from MM/DD/YYYY
SELECT *
FROM 
	(
	SELECT  
	   DISTINCT ON (start_time_substring1, start_time_substring2) trip_id, start_time_substring1, start_time_substring2, trip_start_time
	FROM start_time_exploded ste
	) AS temp1
WHERE start_time_substring1 >= 7 AND start_time_substring2 >= 2
ORDER BY trip_id ASC;


-- Checking to ensure this partition does not violate the DD/MM/YYYY format
SELECT *
FROM
	(SELECT *
	FROM 
		(
		SELECT  
		   DISTINCT ON (start_time_substring1, start_time_substring2) trip_id, start_time_substring1, start_time_substring2, trip_start_time
		FROM start_time_exploded ste
		) AS temp1
	WHERE start_time_substring1 >= 7 AND start_time_substring2 >= 2
	ORDER BY trip_id ASC) AS t2
WHERE start_time_substring1 > 12; 

SELECT COUNT(*)
FROM start_time_exploded ste;


SELECT *
FROM start_time_exploded ste 
WHERE trip_id > 1252111;

-- Count total 
SELECT COUNT(*)
FROM
(
SELECT *
FROM start_time_exploded ste 
WHERE trip_id > 1253914 
ORDER BY trip_id ASC) AS t3;

-- Checking to ensure this partition does not violate the DD/MM/YYYY format
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

-- Makes a bit more sense now, with March 13 being a reasonable time for customers to start using Bikeshare again
-- In that case, with `trip_id` being ordered by ascending, I feel comfortable with making the assumption that the trips are in the correct ORDER 
-- Meaning that the first slice in the `trip_start_time` string is likely day, following DD/MM/YYYY format for now
-- I'll have to see how this changes over time, perhaps I could visualize this data to see where it changes
-- Maybe build a quick model taking distinct records and plotting it in a notebook or something
-- As I plot this I would expect to a trend towards 12 and then a drop-off which would indicator that I'm in a new year, if not then maybe the column has switched formats
-- On casting in postgresql
-- https://stackoverflow.com/questions/21045909/generate-series-of-dates-using-date-type-as-input/21051215#21051215 

-- TODO: Append these notes to a new devlog entry for today 

-- NOTE: Some trip_start_time possibly formatted with year as YY rather YYYY
-- I know that this data will have either 17 or 18 or 2011, 2018 so I could play around with that
-- I should also consider that `trip_id` would hopefully be incremented in ascending ORDER 
-- I was a bit confused about why I wasn't see any trips in January
-- Silly me hadn't realized that it wouldn't make too much sense to see trips being completed in the Winter
-- The website mentions that there is an annual pass that covers all days of the year 
-- It'll be interesting to see if trends in Winter riding changes across the year
-- Another important thing to note is that when I order `trip_id` by ASC, it's doing so as a string rather than a numeric value
-- I'm running into some issues here because this isn't actually in the correct order
-- Question to figure out is what is the pattern that postgres uses when ordering a column that has numeric characters? 

-- 20220926

-- I might be able to employ a case when statement to ensure that I map the start_time_substrings to the correct day or month COLUMNS 

-- Employing a pattern like case when trip id is greater 1253914, substring1 = day, substring2 = MONTH 
-- else substring1 = month, substring2 = day
-- It's a very manual way of doing it; Re: I had figured out the trip_id where the assumed change in date format had happened
-- Although, this is only an assumption, however when I go on to perform my transforms, I expect that I won't have an out of range error

-- Actually, since the the substrings live in their own columns as type integer
-- I might be able to just go through each row, see if... actually never mind that would be a disaster
-- I could assume that there wouldn't be such a random switch in date formats, and I could expect to see a phase shift in date format as seen in the notebook

CREATE TABLE trips_2017_2018_transformed AS
	SELECT trip_id,
			trip_start_time,
			start_time_substring1,
			start_time_substring2,
			regexp_replace(trip_start_time, ' ', '/') AS regex_replaced_trip_start_time,
			CASE
				WHEN trip_id < 1253914 THEN start_time_substring1
				ELSE start_time_substring2
			END start_time_day,
			CASE 
				WHEN trip_id < 1253914 THEN start_time_substring2
				ELSE start_time_substring1
			END start_time_month,
			split_part(trip_start_time, ' ', 2) AS start_time_mmss
	FROM start_time_exploded ste 
	ORDER BY trip_id;

ALTER TABLE trips_2017_2018_transformed 
	ADD trip_start_time_year text; 

UPDATE trips_2017_2018_transformed 
	SET trip_start_time_year = split_part(regex_replaced_trip_start_time, '/', 3);

-- Sanity check!
SELECT *
FROM
	(SELECT *
	FROM 
		(
		SELECT  
		   DISTINCT ON (start_time_day, start_time_month) trip_id, start_time_day, start_time_month, trip_start_time
		FROM trips_2017_2018_transformed tt 
		) AS t5
	ORDER BY trip_id ASC) AS t6;
	
-- Another sanity check to ensure I'm not missing any data
SELECT COUNT(*) AS total_rows_transformed_table
FROM trips_2017_2018_transformed tt;

SELECT COUNT(*) AS total_rows_temp_table
FROM temp_table tt;

-- Looks good :)

SELECT *
FROM trips_2017_2018_transformed tt 
LIMIT 20;

SELECT regexp_replace(trip_start_time, ' ', '/') AS YEAR
FROM trips_2017_2018_transformed tt 
LIMIT 5;

-- Just a quick sanity check; TODO: replace '17' with '2017' and then reduce to datetime format as text, then resume the transformations from a while back...
SELECT trip_start_time_year
FROM trips_2017_2018_transformed tt 
GROUP BY trip_start_time_year;

SELECT * 
FROM trips_2017_2018_transformed tt;