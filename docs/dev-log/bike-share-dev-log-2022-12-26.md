[[2022-12-26]]

---
10:27

- Experiencing some issues trying to load 2019-2020 data
- I think it was it was the issue with the `Trip Duration` having values like `001`
- It's the prefix that's throwing things off
- I encountered this issue before so I'm going to take a look at the previous documentation for the solution

I'm not even sure if I was working with 2020 data from before

---
``` sql
select "Trip  Duration", count(*)
from raw_2019_2020
where "Trip  Duration" like '0%'
group by "Trip  Duration";
```

- There seems to be a data consistency/validity issue with the trip duration field
- trip duration should be in seconds, I don't like the start and stop trip times calculate properly
- I'm suspecting there might be some issues trip_id column

---
# Taking a Look at `"Trip  Duration"`

``` sql
select "Trip Id",
       "Trip  Duration",
       "Start Time",
       "End Time"
from raw_2019_2020
where "Trip  Duration" ~ '^0[0-9].';
```
Using regexp to filter the suspect rows

## Checking to see rows that don't match integer pattern
``` sql
select "Trip Id",
       "Trip  Duration",
       "Start Time",
       "End Time"
from raw_2019_2020
where "Trip  Duration" !~ '^[0-9].';
```

``` sql
-- Using regexp to explore this pattern in the data
-- This might be why I'm not able to load this 
select *
from raw_2019_2020
where "Trip  Duration" ~ 'Trip  Duration';
```
- Much better
- But I think I'll have to consider plotting the trip durations and timestamp calculations
- Maybe consider imputing my own values

Also, I don't like I was immune to the duplicate column headers found in the data. It just was encoded different it seems...

--- 
TODO:
 - Add check encoding feature, write to database