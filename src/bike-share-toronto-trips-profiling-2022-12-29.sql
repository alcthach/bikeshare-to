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


select split_part(trip_start_time::text, '-', 1) as year,
       count(*)
from
    (select *
     from trips
     where start_station_name not like 'NULL'
       and end_station_name like 'NULL'
    ) as t0
group by year;




