select *
from trips_clean
where start_station_name like 'NULL';

select *
from trips_clean
where trips_clean.end_station_name like 'NULL';

-- Imputing missing start_station_name
-- Going to start in with writing a query, then I'll use that query to update the table

update trips_clean
set start_station_name = bst_stations.name
from bst_stations
where trips_clean.start_station_id = bst_stations.station_id and
      trips_clean.start_station_name like 'NULL';

update trips_clean
set end_station_name = bst_stations.name
from bst_stations
where trips_clean.end_station_name like 'NULL' and trips_clean.end_station_id = bst_stations.station_id;

-- Some sanity checks
-- Just going to run the queries written above
-- I think I need to refresh the database...

select *
from bst_stations
where station_id like '7714';
    -- Doesn't look like this station, matches any found in bst_stations
    -- Though there were a bunch of records that were updated as well

select count(*)
from trips_clean
where start_station_name like 'NULL';
    -- There we go, 1542 rows

select start_station_id,
       count(*)
from trips_clean
where start_station_name like 'NULL'
group by start_station_id;

select end_station_id,
       count(*)
from trips_clean
where end_station_name like 'NULL'
group by end_station_id;

select count(*)
from trips_clean

where trips_clean.end_station_id like 'NULL';

select bike_id,
       count(*)
from trips_clean
where end_station_id like 'NULL'
group by bike_id;

select split_part(trip_start_time::text, '-', 1) as year,
       count(*)
from trips_clean
where end_station_id like 'NULL'
group by year;

select count(*)
from trips_clean;
