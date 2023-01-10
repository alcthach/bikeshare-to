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

-- TODO: Create new markdown note for data cleaning documentation