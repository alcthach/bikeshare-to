[[2022-12-15]]

---

09:35

I think the focus today will be to load 2017 q1 q2 data
I'll have to profile this data to see what's going on here

``` text
SQL Error [22007]: ERROR: invalid value ":0" for "hh"
  Detail: Value must be an integer.
```

This was the error message that I was being thrown. 

``` SQL
SELECT to_timestamp(trip_start_time, 'dd/mm/yyyy 24hh:mi') 
FROM raw_2017_q1q2 rqq;

SELECT split_part(time_substring, ':', 1) AS hour
FROM
(
SELECT split_part(trip_start_time, ' ', 2) AS time_substring
FROM raw_2017_q1q2 rqq 
) AS t0
GROUP BY HOUR;
```

Output:
- I'm seeing missing values for the hh substring
- Also might be missing some zero prefix on the hour values

Maybe I could try to filter as see if it's willing to convert to timestamp

``` sql
SELECT trip_start_time 
FROM raw_2017_q1q2 rqq
LIMIT 5;
```

This works because the input data doesn't break the query

According to the docs, it seems like there needs to be strict data governance while trying to convert to timestamp. Which makes sense in terms of ensure data governance...

``` sql
-- Testing to_timestamp() command
SELECT to_timestamp('12/12/2012 14:12', 'dd/mm/yyyy24hh:mi');
```

- Note that there isn't a space between the date substring and the time substring...
- I should try this on my dataset
- Nope, this doesn't worry

---

``` text
SQL Error [22P02]: ERROR: invalid input syntax for type integer: "trip_duration_seconds"
```

- Likely warrants me checking the values in `trip_duration_seconds`. Re: There likely are some values in this field that are not integer
- Hence, invalid input syntax for type integer
- Alright, so I'm not so sure what's going on here
- I think I might need to 

I might need to govern the raw data as text rather than varchar this is something that I'll try after my long break...

I think I'll go grab some lunch soon...

Go back and re-intialize my tables then load the data in...

Alright so I re-initialized all the tables with text rather than varchar

neat vim command

``` vim
:%s/target_string/replace_with
```
Search all lines for the target string, and replace with...


``` sql
SELECT COUNT(*)
FROM raw_2017_q1q2 rqq;

-- Sanity check to ensure that this command works
SELECT COUNT(*)
FROM
(
SELECT trip_duration_seconds::int
FROM raw_2017_q1q2 rqq
) AS t0;
```

- Same count of records...
- Not quite sure why it's raising an issue when trying to change to type `int`...

---

# Paradigm Shift, Re: Just save as a new table rather than trying to update the table. Reason is because it's probably better to preserve the source data.

Action: Save the query as a new table.


``` terminal
bike_share_toronto=# SELECT trip_duration_seconds FROM proc_2017_q1q2 WHERE trip_duration_seconds ~ '^[0-9].' LIMIT 5;
 trip_duration_seconds 
-----------------------
 288
 1108
 307
 339
 117
(5 rows)

bike_share_toronto=# SELECT trip_duration_seconds FROM proc_2017_q1q2 WHERE NOT trip_duration_seconds ~ '^[0-9].' LIMIT 5;
 trip_duration_seconds 
-----------------------
 trip_duration_seconds
(1 row)

bike_share_toronto=# SELECT * FROM proc_2017_q1q2 WHERE trip_duration_seconds LIKE 'trip_duration_seconds';
 trip_id | trip_start_time | trip_stop_time | trip_duration_seconds | from_station_id | from_station_name | to_station_id | to_station_name | user_type 
---------+-----------------+----------------+-----------------------+-----------------+-------------------+---------------+-----------------+-----------
 trip_id | trip_start_time | trip_stop_time | trip_duration_seconds | from_station_id | from_station_name | to_station_id | to_station_name | user_type
(1 row)

bike_share_toronto=# 
```

I can't believe this is what it came down too... Actually, I can and I can't 
- Reproduce the errors with the to_timestamp and `::int`
- See what errors it throws
- It's like related this this row...
- I'll take care of this tomorrow... or Sunday

Wow...

Of course LOL