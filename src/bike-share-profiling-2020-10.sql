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