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


-- NOTE: Doesn't save the first entry in the partition but that's okay``367
SELECT *
FROM 
	(
	SELECT  
	   DISTINCT ON (start_time_substring1, start_time_substring2) trip_id, start_time_substring1, start_time_substring2, trip_start_time
	FROM start_time_exploded ste
	) AS temp1
ORDER BY trip_id ASC;


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



