[[2023-01-10]]

--

12:56

---
[[2023-01-12]]

05:07

Going to clean some data today.

I'll have to whiteboard this problem... I know that I want to have a list of trip IDs to reference. This is where I'll start from

## Dropping Duplicate Rows
```sql
delete from trips_clean
using
    (SELECT trip_id
     from trips_clean
     group by trip_id
     having COUNT(*) > 1) as duplicates
where trips_clean.trip_id like duplicates.trip_id;
```

Finally cracked the pattern there! I had a feeling this was the pattern. The subquery returns the trip IDs that have duplicates.

I'll have to figure out what the `USING` clause does

I took some time to read the docs. Just as I suspected, there might have been a join that took place.

Another I could have approached was:

``` sql
delete from trips_clean
where trip_id in
(
SELECT trip_id
     from trips_clean
     group by trip_id
     having COUNT(*) > 1
)
```

https://www.postgresql.org/docs/current/sql-delete.html

---

## Cleaning Start/End Timestamps

``` sql
-- Clean year values  
select *  
from trips_clean  
where trip_start_time::text ~ '0017';  
  
-- I'll have to do either an update or alter table, reading up on that now
```

- `ALTER` is DDL, whereas `UPDATE` is DML
- To clean this field I'll use `UPDATE`

Going to do some research on the topic to see if there's an elegant solutions to the problem.

I also have some '0018' year entries in `trip_end_time` that I wasn't aware of...

 - ￼￼￼TODO  
￼￼￼￼￼ Collate ￼￼trip_id￼￼ and save as the new default state of the table￼￼￼￼￼ Drop duplicate ￼￼trip_id￼￼ rows￼￼￼￼￼ Investigate issue with ￼￼year￼￼ value in the ￼￼timestamp￼￼ fields; Re: Change ￼￼0017￼￼ to ￼￼2017￼￼  
￼￼￼￼￼ Drop rows with null trip duration, this accounts for about 0.07% of the data, doesn't seem to useful in gleaning insights of bike ridership￼￼￼￼￼ Impute correct station id values in 2017 data￼￼￼￼￼ Import correct station name for￼￼￼￼￼ Impute missing start and end station values in the data set￼￼￼￼￼ Note in the documentation that there is missing ￼￼bike_id￼￼ values for the years 2017 and 2018￼￼￼￼￼ In addition, it would be helpful to highlight what steps I took to clean the data and why￼￼￼￼￼ See bike share programs in other jurisdictions carry out their service￼￼￼￼￼ Consolidate ￼￼user_type￼￼ values to ￼￼annual￼￼ and ￼￼casual￼￼ (under the assumption that annual means that they are an annual member, and casual means that they used a daily or short-term pass for the trip)￼￼￼￼￼ Include this in the data dictionary

---

# On Zero-Value `trip_duration_seconds` Records
