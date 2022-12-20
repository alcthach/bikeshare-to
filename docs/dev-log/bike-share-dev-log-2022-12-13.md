[[2022-12-13]]

---

09:44

I think I'm going to take some time to scan through my code base to see what I've been working on so far. 

That way I don't have to repeat myself.

This will also give me some time to do some housekeeping as well!

I'll just go in alpha-numeric order for now!

## Summary of current files in `.../src/`

`2017-2018_preprocessing.sql`
- This script likely to be taken into prod
- However, it treats 2017-2018 data as an entire slice
- I currently have 2017 and 2018 in separate slices
- NOTE: It might make sense to see if the datetime format shifts between the slices
- This makes dealing with data a bit easier because we'd assume that schematically the shift takes place by the unit of time I.E. Month or quarter rather than randomly shift in the slice of data
--- 
`bike-share-batch-load.sh`
- Hacky bash script used to load csv files to the database
- #TODO This script can definitely use some refactoring later on...
---
`bike-share-cleaning-2017-2018`
- Converts trip start/stop time to timestamp using trip id 1253915 as a boundary, business logic
- #important to consider that there is data in the trip start/stop time fields
---
`bike-share-initialize-trips-table.sql`
- Initializes the destination table where all the data from the csv files will be loaded to
- Should keep this
- Would also be nice to convert this to bash script to run as an executable, rather than running it through 
- `sudo -iu postgres...`
---
`bike-share-profiling-2020-10`
- Appears that there was some issue with October 2020 dat
- Mis-indexed fields
- Plus data entry issue with the `trip_id` field, looks like it was holding some information about trip duration in there as well
- I think I also there was some missing trip duration data in 2019 as well?
- I had to impute this data it seems
- This wasn't just October 2020 that I was working with
- #important 
---
`bike-share-trips-profiling.sql`
- Pretty #important  script
- Finds some issues in the data, such as missing values, duplicates
- Though I'm not sure if it's because of some of the transformations that I might have completed previously
- Re: It looks like I'm writing queries against the transformed data, `trip_ended_at` field clues me into that
- This is a really good script to refer back to when profiling 2017 data!
---
`clean_filenames.sh`
- Super #important for keeping the filenames clean and standardized
---
`.../init-tables`
- Initializes respective tables for the slices of data
---
`init-trips`
- I think it's similar to `bike-share-initialize-trips-table.sql`
---
`load-csv/.`
- These are the older scripts used to load the csv files to the database
- Less elegant and a bit broken tbh
- Re: Counts on pgfutter tool, but pgfutter has little in the way of debugging
- Opted for the pattern used in `bike-share-batch-load.sh` instead
- #to_archive
---
`../load-to-trips/.`
- Contains scripts to load data onto destination table
- #important 
---
`load-transform_2017-2018.sql`
- Contains some interesting snippets, but nothing too important 
- Some of the patterns in this script I've internalized already
- Re: datetime transformations, data governance
- The raw data is in varchar, but to load into the destination they need to respect the business logic
---
`misc/transfer_load.sql`
- Nothing notable
---
`profile_cleaning_2017-2018.sql`
- Seems like a pretty important script
- I'll come back to this after lunch.
- This one is a doozy!
- CREATE COLLATE numeric is a pretty cool pattern
- Yeah it seems like there was a lot of data profiling going on at this time

---
# Brief Action Planning
- I think I'll archive lots of the scripts above and start anew 
- With my profiling scripts 
- And with some preprocessing scripts that I'll take into production

I was feeling a bit blocked with trying to convert the values to timestamp. However, it seems like I might be better keeping the raw data as is. Then just writing the transformed version of the data into the destination table

``` SQL
SELECT 
	to_timestamp(trip_start_time, 'dd/mm/yyyy hh24:mi:ss') AS trip_start_time,
	to_timestamp(trip_stop_time, 'dd/mm/yyyy hh24:mi:ss') AS trip_stop_time,
	trip_duration_seconds 
FROM raw_2017_q1q2 rqq
LIMIT 5;
```

