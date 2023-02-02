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

-- add to readme work on data documentation in spare time i do alot as a kin thats a strength

select *
from trips_clean
where start_station_name like 'NULL'
order by trip_start_time ASC;

select count(*) as start_station_nulls
from trips_clean
where start_station_name like 'NULL';

select count(*)/160000::float as pct_station_name_nulls
from trips_clean
where end_station_name like 'NULL' or start_station_name like 'NULL';

-- delete script for missing nulls, note this can only be run after I've imputed the missing stn names
-- TODO: Include condition where the engine checks to see if the idea is found in `bst_stations`
-- if no, feel free to drop the row, if yes please impute the w/ the corresponding name

delete from trips_clean
where end_station_name like 'NULL' or start_station_name like 'NULL';

-- sanity check
select *
from trips_clean
where start_station_name like 'NULL' or
      end_station_name like 'NULL';

-- ALL DONE!

-- Going to check my todo list from a while back to see if there's anything outstanding
-- this is likely the first stage of profiling, cleaning, transforming data, but it's an important milestone

-- consolidate member values
select user_type,
       count(*)
from trips_clean
group by user_type;

-- for next session:
-- initialize a new column or use case when
-- call the new field `is_annual_member` is boolean
-- true when customer is an annual member, if false, the cx is assumed to be a casual member

-- todo add to final script
alter table trips_clean
add column if not exists is_annual_member boolean;

select is_annual_member
from trips_clean;

select
    user_type,
    case when user_type ~ '^Casual.*' then FALSE
        else true
    end is_annual_member
from trips_clean
where user_type like 'Casual';
    -- Wait, what's going on here?
    -- It might be the regex expression actually
    -- What '^Casual.' means is that there is a character that precedes the character 'l'
    -- Either I find a way to have an optional character or revise the regexp expression to be 'Casua.'
    -- It's a bit hacky but effective
    -- Needed that * as a modifier Re: 0 or more characters, covers both 'Casual' and 'Casual Member'

-- try to persist the changes

update trips_clean
set is_annual_member =
    case when user_type ~ '^Casual.*' then FALSE
         else true
    end
where trip_id = trip_id;

select count(*)
from trips_clean;

