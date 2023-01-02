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