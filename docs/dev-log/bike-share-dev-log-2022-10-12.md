# Bike Share Toronto - Dev Log

[[2022-10-12]]

---

11:30

The project is progressing pretty well at this point. The goal for today is to see if I can move all the data to the staging layer I.E. destination table. I think the data is pretty clean at this point. Not really concerned with any issues. But after my data has been loaded to the destination table, I'll do a bit of data profiling to see if I run into any issues. 

I'll need to check out the data types in the columns. I think right now their all of type `text`, they'll need to be casted to the correct types as they're loaded into the destination table.

I could probably just use the other script that I had written to load 2019-2022 data. 

Was thrown `SQL Error [22P02]: ERROR: invalid input syntax for type integer: ""` when trying to load the data into the destination table. Seems like I have some values that can't be converted to integer because they don't contain numeric characters...

``` sql
bikeshare=# select count(*) from clean_2019_2022 where trip__duration like '';
 count 
-------
    16
(1 row)
```
16 rows... Not too bad

I could impute the `trip__duration` manually. Luckily I figured out the pattern from yesterday. So I'll just employ it here.

``` sql
SELECT 
	start_time_mmss,
	end_time_mmss,
	end_time_mmss - start_time_mmss AS calculated_trip_duration
FROM
	(
	SELECT
		split_part(start_time, ' ', 2)::time AS start_time_mmss,
		split_part(end_time, ' ', 2)::time AS end_time_mmss
	FROM clean_2019_2022 c 
	WHERE trip__duration LIKE ''
	) AS t0;
```

Looks like there might be some rounding issues here. I don't have seconds granularity but it seems like customers during these trips realized they might not have wanted to use the bike service and checked the bike back in?

This query is a bit strange...
``` sql
SELECT *
FROM clean_2019_2022 c 
WHERE trip__duration LIKE '' AND start_station_name NOT LIKE end_station_name; 
```

Shows that trips(5) that started and ended at different stations. But the start and end times are the same. Might they have made it to the next station in less than a minute? I'll do a quick Google maps search. To see how close these stations might be.

Doesn't seem at all that likely that the trips could be completed in less than a minute. 
