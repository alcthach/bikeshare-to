/*
 Bike Share Toronto Data Cleaning - `trips` table
 2023-01-10
 athach - alcthach@gmail.com
 */

-- It's probably best from me to make the changes on a 'clean' trips table rather than the original destination table

-- Initialize new `trips_clean` table with sorted 'trip_id' field ASC
CREATE TABLE trips_clean AS
    SELECT *
    from trips
    order by trip_id
    collate "numeric";

-- Sanity check
select *
from trips_clean
limit 5;
    -- 'trip_id' field is sorted in ASC order

-- Check for lossage b/w raw and clean table
select count(*)
from trips
UNION ALL
select count(*)
from trips_clean;
    -- No lost rows after sorting and copying to new table

/*
TODO
- [-] Collate ￼￼trip_id￼￼ and save as the new default state of the table DONE
- [-] Drop duplicate ￼￼trip_id￼￼ rows
- [-] Investigate issue with ￼￼year￼￼ value in the ￼￼timestamp￼￼ fields; Re: Change ￼￼0017￼￼ to ￼￼2017￼￼
- [-] Transform '0018' values
- [ ] Drop rows with null trip duration, this accounts for about 0.07% of the data, doesn't seem to useful in gleaning insights of bike ridership
- [ ] Impute correct station id values in 2017 data
- [ ] Import correct station name for
- [ ]- Impute missing start and end station values in the data set
- [ ] Note in the documentation that there is missing ￼￼bike_id￼￼ values for the years 2017 and 2018
- [ ] In addition, it would be helpful to highlight what steps I took to clean the data and why
- [ ]- See bike share programs in other jurisdictions carry out their service
- [ ] Consolidate ￼￼user_type￼￼ values to ￼￼annual￼￼ and ￼￼casual￼￼ (under the assumption that annual means that they are an annual member, and casual means that they used a daily or short-term pass for the trip)
- [ ] Include this in the data dictionary
 */

-- Check for duplicates
SELECT trip_id, COUNT(*)
from trips_clean
group by trip_id
having COUNT(*) > 1;

-- List rows with duplicate trip_id
SELECT *
FROM trips_clean as a
JOIN
(
    SELECT trip_id, count(*)
    from trips_clean
        group by trip_id
        having count(*) > 1
    ) as b
ON a.trip_id = b.trip_id;

-- Drop duplicate rows
-- Not going to lie, I'm stumped here. But I think I could turn the query above into a CTE
-- And use it as a filter to drop duplicates, I try that when I come back from break

SELECT trip_id
from trips_clean
group by trip_id
having COUNT(*) > 1;
    -- Great, this is my reference table

-- I think I just need to get this working for now

with duplicates as
         (SELECT trip_id
          from trips_clean
          group by trip_id
          having COUNT(*) > 1)
select *
from trips_clean
where trips_clean.trip_id like duplicates.trip_id;

-- I think I need a join...
-- I'll also need to consider understanding the pattern involved

delete from trips_clean
using
    (SELECT trip_id
     from trips_clean
     group by trip_id
     having COUNT(*) > 1) as duplicates
where trips_clean.trip_id like duplicates.trip_id;

-- Sanity check
SELECT trip_id
     from trips_clean
     group by trip_id
     having COUNT(*) > 1;
    -- Zero rows returned

-- Clean year values
select *
from trips_clean
where trip_start_time::text ~ '0017';

-- I'll have to do either an update or alter table, reading up on that now

-- Will require some special operations b/c, actually maybe I can use time operations
select trip_id,
       trip_start_time,
       trip_start_time + interval '2000 years'
from trips_clean
where trip_start_time::text ~ '0017';
    -- Looks like this did the trick

-- Sanity check to make everything was calculated properly
select *
    from
(
select trip_id,
       trip_start_time,
       trip_start_time + interval '2000 years' as transformed
from trips_clean
where trip_start_time::text ~ '0017') as t0
where trip_start_time != transformed;

-- Looks pretty good to me

-- I'll persist the change

-- I'll also check the trip stop timestamps as well
select *
from trips_clean
where trip_end_time::text ~ '0017';

-- I'll need to transform both timestamp fields
-- Updating tr
update trips_clean
set trip_start_time = trip_start_time + interval '2000 years'
where trip_start_time::text ~ '0017.';


update trips_clean
set trip_end_time = trip_end_time + interval '2000 years'
where trip_end_time::text ~ '0017.';

-- Sanity check
select split_part(trip_start_time::text, '-', 1) as year
from trips_clean
group by year;

select split_part(trip_end_time::text, '-', 1) as year,
       count(*)
from trips_clean
group by year;

-- Double-click on the one '0018' record
select *
from trips_clean
where trip_end_time::text ~ '0018.';
    -- Carried over into the new year

-- Transform record with '0018' year value
update trips_clean
set trip_end_time = trip_end_time + interval '2000 years'
where trip_end_time::text ~ '0018.';

-- NOTE: The regex expression should be more robust. Re: Use hat beginning of string

-- Sanity check
select split_part(trip_start_time::text, '-', 1) as year,
       count(*)
from trips_clean
group by year;

select split_part(trip_end_time::text, '-', 1) as year,
       count(*)
from trips_clean
group by year;