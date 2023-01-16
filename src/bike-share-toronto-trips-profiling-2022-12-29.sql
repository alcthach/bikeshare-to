/*
 DATA PROFILING
 alcthach@gmail.com
 2022-12-29

 */

SELECT *
FROM trips
LIMIT 20;

-- 'trip_id'

-- Check for duplicates
SELECT trip_id, COUNT(*)
from trips
group by trip_id
having COUNT(*) > 1;

-- Check total duplicates
SELECT COUNT(*)
FROM (SELECT trip_id, COUNT(*)
      from trips
      group by trip_id
      having COUNT(*) > 1
) as t0;

-- List rows with duplicate trip_id
SELECT *
FROM trips as a
JOIN
(
    SELECT trip_id, count(*)
    from trips
        group by trip_id
        having count(*) > 1
    ) as b
ON a.trip_id = b.trip_id;

--

-- Check distribution of distinct 'trip_id' values
SELECT distinct length(trip_id) as trip_id_string_length, count(*)
from trips
group by trip_id_string_length;

-- Filter rows with 'trip_id' str length = 6 and not from year 2017
SELECT *
from trips
where length(trip_id) = 6 AND trip_start_time::text !~ '2017.';

SELECT trip_id, split_part(trip_start_time::text, '', 1)
from trips
where length(trip_id) = 6 AND trip_start_time::text !~ '2017.';

SELECT DISTINCT split_part(trip_start_time::text, '-', 1)
FROM
(
SELECT *
from trips
where length(trip_id) = 7
) as t0;

-- Filter rows with trip_id string length = 8
SELECT DISTINCT split_part(trip_start_time::text, '-', 1)
FROM
(
SELECT *
from trips
where length(trip_id) = 8
) as t0;
CREATE COLLATION numeric (provider = icu, locale = 'en@colNumeric=yes');
-- Check characters that 'trip_id' values start with
SELECT trip_id, LEFT(trip_id, 1) as trip_id_substring, count(*)
FROM trips
group by trip_id_substring
order by trip_id
collate "numeric";

-- To be honest, I'm not sure if the query seen above is absolutely necessary
-- Just need to ensure that there are only numeric characters found in 'trip_id'

-- Check if any rows in the data have alpha characters
SELECT *
FROM trips
where trip_id ~ '.[a-z].';

-- Check if any rows have `trip_id` starting with zero
SELECT *
FROM trips
where trip_id ~ '^0.';


-- PROFILING: 'trip_duration_seconds'

-- Check for negative values
SELECT *
FROM trips
where trip_duration_seconds < 0;

-- Check max 'trip_duration_seconds' value
SELECT max(trip_duration_seconds) as max_trip_duration
FROM trips;

SELECT count(*)
from trips;

-- Check mean trip duration value
SELECT avg(trip_duration_seconds)
FROM trips;

-- Check median trip duration value
SELECT percentile_cont(0.5) within group ( order by trip_duration_seconds )
FROM trips;

-- Check distribution of 'trip_duration_seconds'
select width_bucket(trip_duration_seconds, 0, 12403785, 10) as buckets,
       count(*)
from trips
group by buckets
order by buckets;

-- Histogram of 'trip_duration_seconds'
with trip_duration_stats as (
    select min(trip_duration_seconds) as min,
           max(trip_duration_seconds) as max
    from trips
),
    histogram as (select width_bucket(trip_duration_seconds, 0, 7200, 50) as bucket,
                         int4range(min(trip_duration_seconds), max(trip_duration_seconds), '[]') as range,
                         count(*) as freq
                  from trips, trip_duration_stats
                  group by bucket
                  order by bucket
)
select bucket, range, freq,
repeat('■',
               (   freq::float
                 / max(freq) over()
                 * 30
               )::int
        ) as bar
   from histogram;
-- https://tapoueh.org/blog/2014/02/postgresql-aggregates-and-histograms/

-- Check the zero value 'trip_duration_seconds'
SELECT count(*
    )
from trips
where trip_duration_seconds = 0;

-- Check for nulls in 'trip_duration_seconds'
SELECT *
from trips
where trip_duration_seconds is null and start_station_name != trips.end_station_name;

-- Check for trips that start and end in the same station
SELECT COUNT(*)
from trips
where start_station_name = end_station_name;


-- PROFILING: 'start_station_id' and 'end_station_id'

-- Check for string length of values in these fields
select length(start_station_id) as start_station_id_string_length
from trips
group by station_id_string_length;

select length(end_station_id) as end_station_id_string_length
from trips
group by end_station_id_string_length;

-- Check for null values in station id fields
select count(*) as start_station_id_nulls
from trips
where start_station_id is NULL
UNION ALL
select count(*) as end_station_id_nulls
from trips
where end_station_id is NULL;

-- Sanity check
select count(*)
from trips
where start_station_id is null and end_station_id is null;
    -- Checks out...
    -- Accounts for roughly 1/16th of the total data set

-- Check to see which partition of data (year/month) these missing values are from

select split_part(trip_start_time::text, '-', 1) as year,
       count(*)
    from
(
select trip_start_time,
       trip_end_time
    from trips
where start_station_id is null) as t0
group by year;

select split_part(trip_start_time::text, '-', 1) as year,
       count(*)
from trips
group by year;

-- Investigate behaviour between station id's and names in 2017
select *
    from (select start_station_id,
                 start_station_name,
                 end_station_id,
                 end_station_name
          from trips
          where split_part(trip_start_time::text, '-', 1) ~ '.17')
as t0
where start_station_id is null
;

select *
from trips
where start_station_name is null;

select *
from trips
where end_station_name is null;

-- PROFILING 'start_station_name' and 'end_station_name'
select count(*)
from
(
select distinct(start_station_name)
from trips
    ) as t0;

select count(*)
from
    (
        select distinct(end_station_name)
        from trips
    ) as t0;

-- Check distinct 'start_station_name' values
select distinct(start_station_name)
from trips;

-- Check for nulls using string literal 'NULL'
select *
from trips
where start_station_name like 'NULL';

-- Check for edge case scenarios
select *
from trips
where start_station_name like 'null';

select *
from trips
where start_station_name like ' ';

select *
from trips
where end_station_name like 'NULL';

select *
from trips
where start_station_name like 'NULL' and end_station_name like 'NULL';

-- Check different NULL cases in start and end station ends
select *
from trips
where start_station_name like 'NULL' and end_station_name not like 'NULL';

select *
from trips
where start_station_name not like 'NULL' and end_station_name like 'NULL';

select *
from trips
where start_station_name like 'NULL' and end_station_name like 'NULL';

-- TODO: Make a pivot table, summary table maybe?

select
    case when start_station_name like 'NULL' and end_station_name not like 'NULL' then 'start'
        when start_station_name not like 'NULL' and end_station_name like 'NULL' then 'end'
            when start_station_name like 'NULL' and end_station_name like 'NULL' then 'start and end'
        else 'no nulls'
end as yes_null_station_name,
    count(*)
                from trips
group by yes_null_station_name
order by count;

-- Investigating missing start and end station name rows
select *
from trips
where start_station_name like 'NULL' and end_station_name like 'NULL';
    -- Should probably make sure that I have station id info intact as well

select *
    from
(
select *
from trips
where start_station_name like 'NULL' and end_station_name like 'NULL'
    ) as t0
where start_station_id is NULL or end_station_id is NULL;
    -- Looks like I have complete data

-- Check which month/year the missing values rows belong to
select split_part(trip_start_time::text, '-', 1) as year,
       count(*)
    from
(select *
 from trips
 where start_station_name like 'NULL'
   and end_station_name like 'NULL'
) as t0
group by year;

-- Missing start_station
select split_part(trip_start_time::text, '-', 1) as year,
       count(*)
from
    (select *
     from trips
     where start_station_name like 'NULL'
       and end_station_name not like 'NULL'
    ) as t0
group by year;

-- Missing end station name
select split_part(trip_start_time::text, '-', 1) as year,
       count(*)
from
    (select *
     from trips
     where start_station_name not like 'NULL'
       and end_station_name like 'NULL'
    ) as t0
group by year;

select *
from trips
limit 1;

-- PROFILING: 'bike_id'
select distinct count(*), bike_id
from trips
group by bike_id;
    -- This is kind of helpful b/c it shows which bikes have been used the most

-- Check for total number of distinct bike IDs

select count(*) as total_distinct_bike_id
from
(
select distinct bike_id
from trips
    ) as t0;
    -- This tells me that there are 7123 distinct bike IDs in the fleet

-- Check for null or missing values in 'bike_id'
select *
from trips
where bike_id is NULL;

-- Check which years I am missing bike_id values from
select split_part(trip_start_time::text, '-', 1) as year
from
(select *
 from trips
 where bike_id is NULL
) as t0
group by year;

-- Checking for non-numeric values in the field
select *
from trips
where bike_id !~ '.[0-9].';
    -- This query needs to be edited

-- Check for the different string lengths in 'bike_id' field
select length(bike_id) as bike_id_string_length, count(*)
    from
(
select distinct bike_id
from trips
) as t0
group by bike_id_string_length;

-- Break down 'bike_id' string length by timestamp

-- Some pseudocode
-- Maybe a window function or partitions might be helpful in this instance
-- I.E. find string length partition by year
-- Will have to refresh myself on window functions, and if this is a use-case

-- Filter trips by 'bike_id' string length and year
with bike_id_str_len_year AS
         (select length(bike_id) as bike_id_string_length,
                 year
          from (select distinct bike_id,
                                split_part(trip_start_time::text, '-', 1) as year
                from trips) as t0)
select bike_id_string_length,
       count(bike_id_string_length) over (partition by year),
       year
from bike_id_str_len_year;
    -- This doesn't seem right...
    -- My output would look like this...
    -- |str length|str length count|year|
    -- |2|120|2019|
    -- |3|451|2020|
    -- The above query is close...
    -- I added `bike_id_string_length`
    -- There's something else missing...
    -- I shouldn't be seeing as many rows as I'm seeing right now

-- Filter trips by 'bike_id' string length and year, edit
with bike_id_str_len_year AS
         (select length(bike_id) as bike_id_string_length,
                 year
          from (select distinct bike_id,
                                split_part(trip_start_time::text, '-', 1) as year
                from trips) as t0)
select bike_id_string_length,
       count(bike_id_string_length) over (partition by year),
       year
from bike_id_str_len_year;
    -- The counting is a bit strange
    -- I need to count within each year, and within each sub-category of bike_id str length
    -- Also trying to remember why I got sent down this rabbit hole in the first place
    -- Trying to see if there's a pattern between bike_id string length and timestamp

with bike_id_str_len_year AS
         (select bike_id,
                 length(bike_id) as bike_id_string_length,
                 year
          from (select distinct bike_id,
                                split_part(trip_start_time::text, '-', 1) as year
                from trips) as t0)
select bike_id,
       bike_id_string_length,
       count(bike_id_string_length) over w2,
       year
from bike_id_str_len_year
window w1 as (partition by year), w2 as (partition by bike_id_string_length);



with bike_id_str_len_year AS
         (select bike_id,
                 length(bike_id) as bike_id_string_length,
                 year
          from (select distinct bike_id,
                                split_part(trip_start_time::text, '-', 1) as year
                from trips) as t0)
select
       bike_id_string_length,
        count(bike_id_string_length),
       year
from bike_id_str_len_year
group by year, bike_id_string_length
order by year, bike_id_string_length;
    -- Something is wrong with the math based on the total number of unique bike IDs seen below Re: 7123

select count(*)
from
    (
        select distinct bike_id
        from trips
    ) as t0;

select bike_id,
                 length(bike_id) as bike_id_string_length,
                 year
          from (select distinct bike_id,
                                split_part(trip_start_time::text, '-', 1) as year
                from trips) as t0;
    -- This is the based table that I'd be running my next query on
    -- I don't think I want too spend too much time on this
    -- However, I can count by bike_id string length or year, neither are what I'm looking for
    -- I want the count of string lengths partitioned by year
    -- FOR EACH YEAR COUNT THE TOTAL IDS FOR EACH STRING LENGTH

with summary_bike_id_str_len AS (
with bike_id_str_len_year AS
         (select bike_id,
                 length(bike_id) as bike_id_string_length,
                 year
          from (select distinct bike_id,
                                split_part(trip_start_time::text, '-', 1) as year
                from trips) as t0)
select
    bike_id_string_length,
    count(bike_id_string_length) over w,
    year
    from bike_id_str_len_year
window w as (partition by year, bike_id_string_length))
select distinct *
from summary_bike_id_str_len
order by year, bike_id_string_length;
    -- Why doesn't the math check out?
    -- Same bike IDs can be found in subsequent years
    -- This was a massive logic error on my part

select count(*)
from
    (
select distinct bike_id
from trips) as t0;

-- On my next pomodoros I'll need to ensure that trip_id values are indexed properly
-- Just need to ensure the str length of 'trip_id increases as function of time... TODO

-- Check for different lengths of 'trip_id' string
-- Break down by year
select distinct split_part(trip_start_time::text, '-', 1),
                length(trip_id)
from trips;

-- My final look will be with membership type or 'user_type'

-- Check values that 'user_type' field takes on
select user_type,
       split_part(trip_start_time::text, '-', 1) as year,
       count(*)
from trips
group by user_type, year;

--

-- REVISITING THE 'bike_id' string length summary
select distinct bike_id
from trips;

-- I wonder if I could check out the first instance of the bike_id appearing the the data set
-- And then seeing if there's a trend seen over time
-- There's a use for window function there

-- PSEUDOCODE
/*
 Something like...
 Select first occurrence of bike-id of the window of the entire data set
 but also show the year afterwards
 */

-- It's actually a bit simpler
select distinct on (bike_id) *
from
    (
select *
from trips
where bike_id is not null
order by trip_id
collate "numeric") as t0;

-- Try to optimize the query seen above

select *
from distinct_bike_id
order by trip_id
collate "numeric";
-- Not sure how the curators want to approach the labelling of bike_id values but I'm not sure it'll pose
-- Any issue down the road

/*
 NOTE:
 - This concludes the first cycle/round of data profiling
 - Many of the characteristics or issues in the data set have been logged in the data dictionary markdown document
 - The TODO list seen below was grabbed from this document
 - I'm going to make a separate SQL for the preliminary cleaning
 - And I'll also create a script for the load and cleaning, test of future data to be loaded to the warehouse
 - ￼￼￼TODO
￼￼￼￼￼ Collate ￼￼trip_id￼￼ and save as the new default state of the table
￼￼￼￼￼ Drop duplicate ￼￼trip_id￼￼ rows
￼￼￼￼￼ Investigate issue with ￼￼year￼￼ value in the ￼￼timestamp￼￼ fields; Re: Change ￼￼0017￼￼ to ￼￼2017￼￼
￼￼￼￼￼ Drop rows with null trip duration, this accounts for about 0.07% of the data, doesn't seem to useful in gleaning insights of bike ridership
￼￼￼￼￼ Impute correct station id values in 2017 data
￼￼￼￼￼ Import correct station name for
￼￼￼￼￼ Impute missing start and end station values in the data set
￼￼￼￼￼ Note in the documentation that there is missing ￼￼bike_id￼￼ values for the years 2017 and 2018
￼￼￼￼￼ In addition, it would be helpful to highlight what steps I took to clean the data and why
￼￼￼￼￼ See bike share programs in other jurisdictions carry out their service
￼￼￼￼￼ Consolidate ￼￼user_type￼￼ values to ￼￼annual￼￼ and ￼￼casual￼￼ (under the assumption that annual means that they are an annual member, and casual means that they used a daily or short-term pass for the trip)
￼￼￼￼￼ Include this in the data dictionary
 */

-- From what I remember, I think I wrote the sorted 'trip_id' to a new table

-- Sanity check

select *
from trips_clean
limit 5;
    -- Yes, looks good.

-- Drop duplicate rows

select *
from trips_clean
where trip_id like trips_clean.trip_id;