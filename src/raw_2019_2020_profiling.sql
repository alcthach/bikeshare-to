select *
from raw_2019_2020;

select "Trip  Duration", count(*)
from raw_2019_2020
where "Trip  Duration" like '0%'
group by "Trip  Duration";

select "Trip Id",
       "Trip  Duration",
       "Start Time",
       "End Time"
from raw_2019_2020
where "Trip  Duration" ~ '^0[0-9].';

select
       "Trip  Duration",
       count(*)
from raw_2019_2020
where "Trip  Duration" !~ '^[0-9].'
group  by "Trip  Duration";
    -- This poses a bit of an issue...

-- Using regexp to explore this pattern in the data
-- This might be why I'm not able to load this
select *
from raw_2019_2020
where "Trip  Duration" ~ 'Trip  Duration';

-- Delete column header rows found in raw_2029_2020 data
DELETE