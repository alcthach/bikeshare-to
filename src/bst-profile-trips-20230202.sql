/*
 Profiling `clean_trips`
 alcthach@gmail.com
 2023-02-02

 Purpose: Another round of profiling following some notable data cleaning
 To help inform subsequent data modelling
 */

select *
from trips_clean
order by trip_id
limit 25;


