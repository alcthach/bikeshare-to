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

-- Imputing missing values for start/end station ids in 2017
update trips_clean
set start_station_id = bst_stations.station_id
from bst_stations
where trips_clean.start_station_id is null and trips_clean.start_station_name = bst_stations.name;

update trips_clean
set end_station_id = bst_stations.station_id
from bst_stations
where trips_clean.end_station_id is null and trips_clean.end_station_name = bst_stations.name;

-- I'm wondering if some of the station names don't match between the two tables
-- A bit of a logic error on my part, the filters in the where statement were in the reverse order
-- I'll have to take a look at the remaining rows with null id values

select *
from trips_clean
where start_station_id is null;

-- AKA have to see if there is a matching station name in bst_stations

select *
from bst_stations
join trips_clean on start_station_name = bst_stations.name
where start_station_id is null;

-- This tells me the remaining null values don't have a corresponding entry in bst_stations

select start_station_name, count(*)
from trips_clean
where start_station_id is null
group by start_station_name;

select *
from bst_stations
where name ~ 'Seaton.';

select count(*)/160000::float as percent_nulls
from trips_clean
where start_station_id is null;

-- What might be happening it that the join is trying to match character-by-character
-- And in 2017, the station names appear to be incomplete based on some of the single-case scenarios I've seen
-- For example, 'Seaton St / Dundas St E - SMART' and the 2017 version, 'Seaton St / Dundas St E'

select count(*)
from
    (
select start_station_name, count(*)
from trips_clean
where start_station_id is null
group by start_station_name) as t0;

-- 58 station names that are not in the bst_stations table
-- However, some of them might actually be a semantic match, so best to see if I can find the correct IDs
-- Not sure if it's going to involve some sort of percent match
-- Actually it's probably better to use some sort of semantic regex matching
-- In plain English, if the string found in `trips.clean` match is found in `bst_stations`, then impute the
-- matching ID
-- Probably best to try and print this out first...

select count(*)
    from
(select name,
        start_station_name
 from bst_stations
          join trips_clean on textcat('%', textcat(trips_clean.start_station_name, '%')) like
                              textcat('%', textcat(bst_stations.name, '%'))
 where trips_clean.start_station_id isnull) as t0;

-- I think there might be something going on with my join, I'm short 200000 rows

select *
from trips_clean
join bst_stations on textcat('%', textcat(start_station_name, '%')) like textcat('%', textcat(bst_stations.name, '%'))
where start_station_id isnull;

select count(*)
from trips_clean
where start_station_id isnull;


select count(*)
from trips_clean
join bst_stations on start_station_name like textcat(bst_stations.name, '%')
where start_station_id isnull;

-- Hold on, I think that might have worked, but I'm not sure why
-- It might be because the regex operator might be less restrictive than the `LIKE` operator
-- I'll see what the row count looks like before jumping to conclusions

select start_station_name,
       name
from trips_clean
join bst_stations on textcat('%', textcat(start_station_name, '%')) like textcat('%', textcat(bst_stations.name, '%'))
where start_station_id is null;

-- I'll take some time to understand the pattern that I'd want to employ
-- I think part of it is find the logic that I'll need to help the engine decide when a suitable match is found
-- For example, is it going to be 'if bst_station.name found in trips_clean.start_station_name?'
-- I.E. what is the difference between the fields, is there a pattern found between the fields that I can use?

select count(*)
from trips_clean
         join bst_stations on textcat('%', textcat(start_station_name, '%')) like textcat('%', textcat(bst_stations.name, '%'))
where start_station_id is null;

-- I mean, the join statement IS the pattern I'd want to employ...
-- It says find the rows that make with each value suffixed and prefixed with wildcards
-- My concern is that I don't know why I appear to be missing so many values

select count(*)
from trips_clean
where start_station_id is null;

-- I'll need to employ right join instead to see what might be happening here

select start_station_name,
       name
    from
        (
select start_station_name
from trips_clean
where start_station_id is null) as t0
join bst_stations on textcat('%', textcat(start_station_name, '%')) like textcat('%', textcat(bst_stations.name, '%'));

select *
from bst_stations
where name like '%Widmer%';

-- There is a `Widmer St / Adelaide St W` in `trips_clean`
-- But there not in `bst_stations`, only 'Widmer St / King St W' exists, which is nearly in the same location
-- The textcat pattern does well for matching the entire string, however, I'm running into issues with partial matches
-- This is a bit more complex
-- I guess I can take a look at the fundamental patterns and then slowly work through the data
-- One pattern at a time...
-- split_part() might be useful
-- Also naming the different patterns
-- So far I see exact string matches and partial, first substring delimiter ' ' match

-- Let's match by substring
select start_station_name,
       name
from
    (
        select start_station_name
        from trips_clean
        where start_station_id is null) as t0
    join bst_stations on split_part(start_station_name, ' ', 1) like split_part(bst_stations.name, ' ', 1);
-- Not restrictive enough

select distinct on (start_station_name) start_station_name, name, station_id
from
    (
        select start_station_name
        from trips_clean
        where start_station_id is null) as t0
        join bst_stations on textcat('%', textcat(start_station_name, '%')) like textcat('%', textcat(bst_stations.name, '%'));

-- Alright so this is something to #key in on, I have 4 stations that match a specific pattern using the query found about
select count(*)
from
    (
        select start_station_name
        from trips_clean
        where start_station_id is null) as t0
        join bst_stations on textcat('%', textcat(start_station_name, '%')) like textcat('%', textcat(bst_stations.name, '%'));

-- TODO refactor
update trips_clean
set start_station_id = bst_stations.station_id
from bst_stations
where trips_clean.start_station_id is null and textcat('%', textcat(start_station_name, '%')) like textcat('%', textcat(bst_stations.name, '%'));

-- TODO refactor
update trips_clean
set end_station_id = bst_stations.station_id
from bst_stations
where trips_clean.end_station_id is null and textcat('%', textcat(end_station_name, '%')) like textcat('%', textcat(bst_stations.name, '%'));

-- Getting another head coun
select start_station_name, count(*)
from trips_clean
where start_station_id is null
group by start_station_name;

-- Let's use '/' as a delimiter to see if anything is happening...

select start_station_name,
       name
from
    (
        select start_station_name
        from trips_clean
        where start_station_id is null) as t0
        join bst_stations on textcat('%', textcat(start_station_name, '%')) like split_part(bst_stations.name, '-', 1);

select start_station_name,
       name
from
    (
        select start_station_name
        from trips_clean
        where start_station_id is null) as t0
        join bst_stations on start_station_name like split_part(bst_stations.name, '-', 1);

select count(*)
    from
(select start_station_name
from trips_clean
where start_station_id is null
group by start_station_name) as t0


select count(*)
from bst_stations;

-- 54 start station names are not readily found in bst_stations

select count(*)
from
    (
        select start_station_name
        from trips_clean
        where start_station_id is null) as t0
        join bst_stations on split_part(start_station_name, ' ', 1) like split_part(bst_stations.name, ' ', 1) and
                             split_part(start_station_name, ' ', 2) like split_part(bst_stations.name, ' ', 2) and
                             split_part(start_station_name, ' ', 3) like split_part(bst_stations.name, ' ', 3) and
                             split_part(start_station_name, ' ', 4) like split_part(bst_stations.name, ' ', 4) and
                             split_part(start_station_name, ' ', 5) like split_part(bst_stations.name, ' ', 5);
-- 95886 rows
-- wrong pattern, needs to count from left, or include all...

select count(*)
from trips_clean
where start_station_id is null;

select distinct on (name)
       name,
       start_station_name,
       station_id
from
    (
        select start_station_name
        from trips_clean
        where start_station_id is null) as t0
        join bst_stations on split_part(start_station_name, ' ', 1) like split_part(bst_stations.name, ' ', 1) and
                             split_part(start_station_name, ' ', 2) like split_part(bst_stations.name, ' ', 2) and
                             split_part(start_station_name, ' ', 3) like split_part(bst_stations.name, ' ', 3) and
                             split_part(start_station_name, ' ', 4) like split_part(bst_stations.name, ' ', 4) and
                             split_part(start_station_name, ' ', 5) like split_part(bst_stations.name, ' ', 5)
                             where name like '%SMART%';


-- TODO refactor re: impute station ids
update trips_clean
set start_station_id = bst_stations.station_id
from bst_stations
where start_station_id is null and
    split_part(start_station_name, ' ', 1) like split_part(bst_stations.name, ' ', 1) and
    split_part(start_station_name, ' ', 2) like split_part(bst_stations.name, ' ', 2) and
    split_part(start_station_name, ' ', 3) like split_part(bst_stations.name, ' ', 3) and
    split_part(start_station_name, ' ', 4) like split_part(bst_stations.name, ' ', 4) and
    split_part(start_station_name, ' ', 5) like split_part(bst_stations.name, ' ', 5) and
    name like '%SMART%';


-- TODO refactor re: impute station ids
update trips_clean
set start_station_id = bst_stations.station_id
from bst_stations
where start_station_id is null and
        split_part(start_station_name, ' ', 1) like split_part(bst_stations.name, ' ', 1) and
        split_part(start_station_name, ' ', 2) like split_part(bst_stations.name, ' ', 2) and
        split_part(start_station_name, ' ', 3) like split_part(bst_stations.name, ' ', 3) and
        split_part(start_station_name, ' ', 4) like split_part(bst_stations.name, ' ', 4) and
        split_part(start_station_name, ' ', 5) like split_part(bst_stations.name, ' ', 5) and
        start_station_name like '%Capreol%';
-- 8773 rows

select *
from trips_clean
where start_station_name like '%Capreol%'
and start_station_id is null
and split_part(trip_start_time::varchar, '-', 1) like '2017';


select start_station_name,
       count(*)
from trips_clean
where start_station_id is null
group by start_station_name;

select start_station_name
from trips_clean
where start_station_id is null and
      start_station_name like '%SMART%'
group by start_station_name;

-- I have some other SMART stations that might need to be imputed as well...
select distinct on (start_station_name)
    start_station_name,
       name
from
    (
        select start_station_name
        from trips_clean
        where start_station_id is null and
              start_station_name like '%SMART%') as t0
        join bst_stations on split_part(start_station_name, ' ', 1) like split_part(bst_stations.name, ' ', 1) and
                             split_part(start_station_name, ' ', 2) like split_part(bst_stations.name, ' ', 2);
    split_part(start_station_name, ' ', 3) like split_part(bst_stations.name, ' ', 3) and
                             split_part(start_station_name, ' ', 4) like split_part(bst_stations.name, ' ', 4);
    split_part(start_station_name, ' ', 5) like split_part(bst_stations.name, ' ', 5)

select start_station_name,
       count(*)
from trips_clean
where trips_clean.start_station_id is null
group by start_station_name;

select count(*)
from trips
where trips.start_station_id is null;

select name
from bst_stations;


-- Manually Cross-Comparing start station name w/ Null Values station IDs with `bst_stations`

-- Adelaide and bay SMART
select name
from bst_stations
where name like 'Adelaide%';
    -- can't impute ids

-- base station
select name
from bst_stations
where name like '%base%';
    -- can't impute ids

-- bath and queens quay
select name
from bst_stations
where name like '%Bathurst%'
order by name asc;
    -- possibly imputable, also listed as Bathurst St/Queens Quay(Billy Bishop Airport) in `bst_stations`

-- bay and bloor
select name
from bst_stations
where name like '%Bay%'
order by name;
    -- not sure if imputable, Re: there are now two stations on the E/W corners of the intersection
    -- might have to leave this as is

-- Also, let me make a macro or stored procedure so I don't have to repeat myself moving forward!

create or replace function check_station_name(station_name varchar)
    returns table(
    name varchar
    )
language plpgsql
as
    $$
    begin
    return query(
    select bst_stations.name
    from bst_stations
    where bst_stations.name like station_name
    order by bst_stations.name
    );
    end;
    $$;

select * from check_station_name('%Beverley%');
    -- There are some typos in 2017 data
    -- Mis-spelled, 'beverly' instead of 'beverley'
    -- todo correct this and impute the correct IDs

select start_station_name,
       count(*)
from trips_clean
where start_station_name like '%Bever%'
group by start_station_name;
    -- Also, there is no 'Beverly St / College St W' in `bst_stations`

-- Bloor GO / UP Station \(West Toronto Railpath\)
select * from check_station_name('%Rail%');
    -- not imputable, looks like this station is situated north of the up station
    -- looking @ https://bikesharetoronto.com/system-map/
    -- there is no bike share station at bloor go up station...

-- bloor and brunswick ave
select * from check_station_name('%Bloor%');
    --  can't impute
    --  nearest station is Dalton Rd / Bloor St W but don't feel comfortable imputing the related stn ID

-- bloor and borden (near bloor and bathurst)
-- using query above, couldn't find a semantic match
-- can't impute

-- boston ave and queen st e, NO
select * from check_station_name('%Boston%');

-- bremner blvd and spadina ave, NO
select * from check_station_name('%Brem%');

-- castle frank station, NO
select * from check_station_name('%Castle%');

-- dockside dr and queens quay e, NO
select * from check_station_name('%Quay%');

-- east liberty st and pirandello st, NO
select * from check_station_name('%Liberty%');
select * from check_station_name('%Pirandello%');

-- fringe next stage, NO
select * from check_station_name('%Fringe%)');

select * from check_station_name();






-- todo write in pseudocode when I'm back from break
-- another time will also do
-- I'll try to pass any argument in next...
