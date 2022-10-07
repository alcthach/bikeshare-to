# Bike Share - Dev Log
[[2022-10-06]]

---

08:49

From what I can remember, I'm running into some logic errors when trying cleaning the month and day columns. There isn't enough constraint when trying to clean data prior to July 2017. It also appears to that it will include data from subsequent months which I don't want it to. 

#### Some things to keep in mind about the behaviour of date format in the data:
- From January 2017 to June 2017 format is `dd/mm/yyyy`
- From the 13th day in each month up until June 2017, the day is written with a '0' prefix
- In July 2017, the date format changes to `mm/dd/yyyy` for the rest of the dataset
- In Jul-Sep 2017, '0' prefix isn't used 
- In Oct-Dec 2017, '0' prefix is used entirely
- No prefix used for the whole of 2018

---

### Thinking Out Loud

I tried to use the logic of casting the assumed month column to int and then saying if this value is less than 7 then set to month. However, this isn't restrictive enough and will also consider rows that have a switched format, but will then pull the day rather than the month. Meaning each month after June 2017 might miss some of the days before the 7th, because of the logic. 

What this means is that I need to figure out a way to restrict it so that I don't pull the first week off of those subsequent months.

I'm going to play around with some queries to figure this out

An important query to keep around to check date format behaviour

``` SQL
SELECT trip_id, raw_start_time, start_time_substring2, start_time_substring1
FROM
	(SELECT DISTINCT ON (start_time_substring2, start_time_substring1) start_time_substring1, start_time_substring2, trip_id, raw_start_time
	FROM clean_2017_2018) AS t0
ORDER BY trip_id
COLLATE "numeric";
```

Would casting to date work in this scenario? I mean I know when the date format switches so perhaps it would make sense to draw a line in the sand. 

Up until June 2017 the date format is one way, and beyond June 2017 it's another way. Can't I just tell the computer to check if the row is before July 2017 and then transform the date format to the correct one? 

It seems like I miss the mark on this one. But this is an important thing to come across. Is there a convert date format function??

Hard coding is fine, get it working then finesse it after.

From what I can remember, the reason that I'm doing all of this is that there are 2 date formats in the date, I can't write the data to the destination table because of this. I need to make sure the date format is homogeneous. The issue is that I can't really cast by date and then work from there. This is because the computer will not know when the format changes. 

Although, if I govern the raw data column differently. I.E. expect it to see only one format then what would happen? A thought exercise that might provide a solution

The majority of the data is in mm/dd/yyyy format, which would make sense for me to cast as mm/dd/yyyy. How would data prior to July 2017 be treated then?

I realize that I've had a blindspot this whole time. The logic error is in that this is not the most effective use of my time. This is historical data. I won't have to worry about taking an elegant or dynamic approach to cleaning this data. If this was a real-world scenario nobody would appreciate the effort and time I'm putting in to figuring out a fancy way to solve the problem. 

If the business user is looking to extract insight from the data. The data needs to be modelled in a timely manner. In this case the end goal is to model the data. Doesn't really matter how it gets done. The data just needs to be modelled with a standard of quality and that's it.

There's no sunk cost fallacy here. Really grateful to learn all these stuff, especially the problem-solving bits. That experience is irreplaceable. In addition the data profiling itself has allowed me to figure out where the date format changes. All it took was a query to find the exact point where the pattern changed. From there it's just a matter of employed my logic using trip_id instead

``` sql
SELECT
	trip_id,
	trip_start_time,
	CASE 
		WHEN trip_id::int < 1253915 THEN to_timestamp(trip_start_time, 'dd/mm/yyyy hh24:mi:ss')
		WHEN trip_id::int >= 1253915 THEN to_timestamp(trip_start_time, 'mm/dd/yyyy hh24:mi:ss')
	END AS start_ts
FROM raw_2017_2018
ORDER BY trip_id
COLLATE "numeric";
```

- This was really all took 😅
- I would say it's a pretty elegant solution, a bit static, but doesn't require too much code
- It's good to keep in mind that without exploding the datetime column and profiling it, I wouldn't have been able to figure out the exact point in the data where the date format had switched over
- Applie the same pattern for `trip_stop_time` but was thrown an error. Re: From what I remember, there is a null value in this subset of the data