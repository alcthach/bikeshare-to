[[2022-12-29]]

---
17:37

# Data Profiling

Not sure of the business rules that need to be in place. However, I'll just form an inbox of things that I'll need to explore:

- There shouldn't be any duplicate trips
- Business logic that I could employ is that there shouldn't be any duplicate `trip_id` in the data set
- Need to investigate the distribution of `trip_duration_seconds`
	- I know that I ran into some issues or rather saw some peculiar values in this field
	- Re: I don't expect trip durations to be around 0-10 seconds long, unless the customer had initialized a trip, but decided to cancel the trip
- Have to investigate the values each value takes on 
- Just thought of what my BrainStation instructor had mentioned about EDA, just getting to know the columns and their business meaning, logic, relationships, etc. 
- I'm wondering what the difference is between EDA and data profiling, cleaning, munging, etc. 

---

**Imported from [[bike-share-toronto-data-dictionary-2022-12-29]]**

# Data Documentation - Quality Report Notes

*Describes the changes made to improve data quality. Will be refactored into a final report.*

##  Duplicate `trip_id` rows

- There were a 26 rows (13 pairs) in the dataset with duplicate `trip_id` values
- They followed a similar pattern found below:

| trip\_id | trip\_duration\_seconds | start\_station\_id | trip\_start\_time | start\_station\_name | end\_station\_id | trip\_end\_time | end\_station\_name | bike\_id | user\_type | trip\_id | count |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 11224466 | 0 | 7649 | 2021-04-24 14:14:00.000000 | Greenwood Subway Station - SMART | NULL | 2021-04-24 14:14:00.000000 | NULL | 3436 | Annual Member | 11224466 | 2 |
| 11224466 | 0 | 7649 | 2021-04-24 14:14:00.000000 | Greenwood Subway Station - SMART | 7611 | 2021-04-24 14:14:00.000000 | Victoria Park Ave / Danforth Ave | 3436 | Annual Member | 11224466 | 2 |
| 12281090 | 0 | 7101 | 2021-06-30 17:24:00.000000 | Lower Sherbourne St / The Esplanade | NULL | 2021-06-30 17:24:00.000000 | NULL | 6428 | Casual Member | 12281090 | 2 |
| 12281090 | 0 | 7101 | 2021-06-30 17:24:00.000000 | Lower Sherbourne St / The Esplanade | 7014 | 2021-06-30 17:24:00.000000 | Sherbourne St / Carlton St \(Allan Gardens\) | 6428 | Casual Member | 12281090 | 2 |

- One half of the duplicate pair contained complete data, the other had missing values for `end_station_name` and `end_station_id`
- The rows with complete data don't make sense, Re: Trip duration is zero, which is consistent with the difference between trip start and end times, but the trip somehow started and ended at different stations
- Keeping in mind that I'm trying to glean insights on ridership behaviour, I'm not quite sure if this tells me anything useful, if anything, this might cause distortation in future analytical work
- Neither halves of the duplicate pairs appear to be useful

# `trip_id`
- Data-type constraint: varchar, was already introduced while migrating the raw data into `trips` destination table
- However, I'll did to profile the values in this column to ensure values match regex pattern of only numeric patterns
- And that they follow some uniformity or accuracy? I.E. That it has the correct data, and is not holding data that is not trip id... 
	- For example, `bike_id` or `start_station_id`

### Checking Distribution of String Length
- I've jumped ahead of myself here
- I think naturally I wouldn't have suspected any issues with `trip_id` accuracy, however, I think I had ran into this issue during an earlier run-in while I was working on this project
- I saw that the columns were mis-indexed for a specific subset of the data
- It made sense for the strings to be of length 7 or 8 based but rows with `trip_id` length 6 were indexed before length 7 I believe
- Actually, I'm not sure if there's an issue...
	- That might have been due to user error on my part when I had to migrate and transform the data?
	- Though I might need to take a look to see if `trip_id` string length = 6 rows below to 2017
	- The business logic is the string length of `trip_id` should increase in chronological order
	- From what I remember the strength lengths were much longer than 6-8, which checks out because the column was holding other information at the time
- From what I'm seeing so far,
	- `trip_id` values with string length `6` are exclusively from trips from `2017`
	- `trip_id` values with string length 7 are from `2017-2020`
		- However, based on the query output, I may have an issue with the timestamps that will need to be resolved later on
		- However, the `trip_id` values seem to be accurate so far...

|index| split\_part |
|:-| :--- |
|1| 0017 |
|2| 2017 |
|3| 2018 |
|4| 2019 |
|5| 2020 |

- I'll need to check `trip_id` string length `8` as well.
| | split\_part |
|:-| :--- |
| |2021 |
| |2022 |
- Looks good!
- I'm thinking there might need to be a range constraint for this field?
- However, because I'm working with historical data, I don't think this is as necessary
	- It's moreso for the data that's going to be ingested in the future
	- This means that I'm going to need to consider setting up these constraints for future data
	- New batches of data are available on a on monthly basis so I can consider setting constraints as this project continues to trudge along...
- I can also take a look at the characters that the `trip_id` values start with 

# Continued Profiling of `trip_id` field
- I think I'm almost done here
- No rows in the data set have `trip_id` with alpha characters in them
- No rows have a `trip_id` value starting with zero

---
# `trip_duration_seconds`
- What are some business rules here?
- No negative values, zero values might be okay
- Need to check for NULLS as well
- As well as distribution
- Because there is an integer constraint on the field I don't expect any values to start with zero
- No negative values
- Check min and max
- 206729 minutes was the longer trip duration
- I'll probably have to plot the distribution to get a feel for the data
- I'll have to be smart about this because I'm dealing with about 16.2 million trips
- Let me try to bin the data in SQL first
- What would be the most logical partitioning of data if I were to make a summary table of the trip-duration?
- I could check the median, and mean, measures of central tendency
- And what's logical in terms of trips
- Commute, leisure, etc.
## Measures of Central Tendency
- Mean trip duration (s): 1038
- Min: 0
- Max: 12403785
- Median: 730
``` sql
-- Check median trip duration value
SELECT percentile_cont(0.5) within group ( order by trip_duration_seconds )
FROM trips;
```
*Pretty cool pattern to check for the median in a list of values*
- Median is essentially the 50th percentile
- Calculate this over `trip_duration_seconds`
- Order it because we need to sort the values before finding the median value
- I'm wondering what unit of measurement would be best suited for this data
- Seconds doesn't seem quite useful but it might be important to consider the overall distribution in seconds before considering any transformations
- In addition, it would be interesting to see if the customer makes a decision to use Bike Share based on the estimated time 
- I guess it depends on if the bike is used for recreation or commuting purposes

## Investigating the Distribution of `trip_duration_seconds`
- I'm going to try different size bins to see how the data is distributed
- Alright so I tried the equidistant or equally-sized bucket/bin based on the min max values found in the data
- The issue is there are some clear outliers in the data
- And that max value is not giving me the best representation of the data right, this is because that max value is forcing the bin size to be very large
- The bin size is 1,232,766 seconds equating to 29546 mins or 342 hours
- Take a look below
| bucket | range | freq | bar |
| :--- | :--- | :--- | :--- |
| 1 | \[0,1232766\) | 16205243 | ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ |
| 2 | \[1241223,2466021\) | 62 |  |
| 3 | \[2531604,3563376\) | 12 |  |
| 4 | \[4450681,4954471\) | 4 |  |
| 5 | \[4981555,5624942\) | 3 |  |
| 6 | \[6382030,7301419\) | 2 |  |
| 7 | \[8436608,8436609\) | 1 |  |
| 9 | \[10507836,10507837\) | 1 |  |
| 10 | \[12016662,12016663\) | 1 |  |
| 11 | \[12403785,12403786\) | 1 |  |
| null | \(,\) | 16 |  |

- Also should take a look at the null values really quickly
- And also take a look at the trips with 
- I just thought of some business logic
- Really... it doesn't make sense for a trip to last longer than it needs to
- I.E. The best value for the customer is when the bike is actually being used.

Some Background Info
- *While bike share has similarities to traditional bike rental, bike share is perfect for short trips around town. Traditional bike rental is a better option for trips longer than a couple of hours.*
- *Bike share was created for quick trips and getting from Point A to Point B. Rides are limited to 30 minutes to ensure bike availability for all riders to “share.” This encourages riders to use bike share for quick trips and return the bike to any station within 30 minutes.*
- *The first 30 minutes of each ride is included in the base price of the Annual 30 membership and 45 minutes of each ride for the Annual 45 membership. After this, overage fees of $4 per additional 30 minutes of trip time applies.*

Based on the 30 minutes time limit, I would expect most trips to fall within the 30 minute range or the 1800 minute range

However, 45-min passes are available to membership holders so I'll keep an eye out for this segment/partition in the data as well. Specifically the "Annual 45 membership"

Some of this background info tells me that I might expect to see the data partition in a certain way. I.E. trips falling within 30 minutes and trips falling within 45 minutes
- It might also depend on when some of these policies were put in place as well

I mean at this point I think the `trips_duration_seconds` might be in pretty decent shape?

I just have to investigate why there are some null values and maybe look at the 0 trip duration rows.

I have about 11k rows of `trip_duration_seconds = 0` out of 16.2 million rows, accounting for about 0.07% of the data

Checking for nulls in `trip_duration_seconds`
- There are some rows that appear to be cancellation of trips, with null duration, starting and ending at the same location
- In addition, there are 5 trips that start and end with different stations, but have null trip duration as well

As an aside, there are roughly 710k trips that could be classified as "round trip", starting and ending in the same station

There's a chanced that I'm going to run into some issues downstream when performing some analytics work. The outliers are going to pose a bit of issue. This is something to keep in mind later on. However in terms of how valid the data is. Those outliers will require further investigation. 

Okay so it looks like all station ids are in 4 characters in length
There are some nulls that I have to investigate further
- About 1 million rows with missing start and end station ids
- Sizable amount I would say

## On the Null Values Found in `start_station_id` and `end_station_id`
- Sizeable chunk of missing values in the data, roughly 1 million rows
- Seems to only be happening in 2017 and no other years
- This is troublesome because this slice of data is 1/1.5 million rows
- I'm familiar with this issue
- I think the plan was to impute the values using a stations table that I'm also going to load to the database
- Also need to ensure that I have complete start/end station names, or one or the other
- If both are missing I'll be in trouble
	-  I'm okay here, no missing start or end station names

NTS: The data profiling is starting to become non-linear. Starting to jump around which is okay because this the end goal is to become less naive to the data. And to understand the semantics or meaning, usefullness behind the fields.

# Somethings to Keep in Mind
- `station_id` fields are 4-character numeric strings
- `trip_id` is a numeric string varying from 6-8 characters in length
- Need to ensure that the station IDs in ridership data is valid; I.E. There shouldn't be any station IDs that don't belong to the stations table that I'll be bringing in

# `start_station_name` and `end_station_name`
- No missing values in this field
- There are 815 distinct start station names
- And there are 816 distinct end station names
- A bit strange, however, this represents the different values that each observation takes on in these fields
- The truth table in terms of station names is going to be found in the station table that I'll be importing at a later time
- What business rules should be in place? 
- Maybe there's a specific format that these values must take on?
- It's quite okay if the value starts with a number, b/c the station might be name after an address rather than an intersection
- Ouff, I think there are some null values
	- Remember that in string-constrained fields I might need to highlight matching to a string literal...
	- I found this out using a visual scan, Re: About 800 distinct values so I don't mind a quick scroll-through to see what the data looks like
	- Ah okay, this is important to keep in mind, I used the pattern: `where field is NULL` for `trip_duration_seconds`, this is acceptable
	- However, for `start_station_name` it's not because I'm dealing with string types
		- That means `where start_station_name LIKE 'NULL'` is the correct pattern to employ

## Missing Values in `start_station_name` and `end_station_name`
- The way that I loaded this data in initial meant there would be no issue with me bring in these values
- I just straight up imported the values as varchar/text
- However, I'll probably need to consider the edge case values that this field could take on
- Like ' ', or null, or something else
- Okay there are some cases to consider here:
| start_station_name | end_station_name |    
| ------------------ | ---------------- |  
| NULL               |                  |          
|                    | NULL             |      
| NULL               |          NULL    |
- I'll construct some queries to look at this behaviour in the data
---

Quick and dirty summary table using `CASE WHEN` and `GROUP BY`, `COUNT(*)`

| yes\_null\_station\_name | count    |
|:------------------------ |:-------- |
| start and end            | 13276    |
| start                    | 162797   |
| end                      | 167493   |
| no nulls                 | 15861780 |

- This tells us there are some exclusive scenarios
- Also that the majority of rows have complete start and end station name information
- However, I'll have to investigate further to gain context on what's happening with some of the cases...

## Exploring missing start and end station name rows

Missing **start and end** station names
| year | count |
| :--- | :--- |
| 2021 | 138 |
| 2022 | 13138 |

Not too big of an issue, I'll just impute these later on

Missing **start** station names
| year | count |
| :--- | :--- |
| 2021 | 3542 |
| 2022 | 159255 |

Missing **end** station names
| year | count |
| :--- | :--- |
| 2019 | 454 |
| 2020 | 752 |
| 2021 | 5756 |
| 2022 | 160531 |

This last chart is a bit strange, wonder if the 2019 and 2020 data are similar to 2021 and 2022 data...

Something to explore on Monday perhaps.

[[2023-01-09]] 09:36

I'll need to figure out 

## Profiling `bike_id`
- There are about 7k distinct bike IDs in the fleet
- However, I'll need to make an assumption here about whether all bikes in the fleet have a bike ID
- Would make sense in terms of inventory, maintenance, operations, etc.
- So I might assume that this measure was introduced later on into the data set
- The issue is that I won't be able to glean any insights where bike ID information is not available
- Also it's a bit strange that I have `<null>` values in this field, but not in the start or end station it seems
	- I think it might be because of the way the raw data came in
	- When I was loading this data I had to impute the null values to match the dimensions of the destination table `trips`
	- However, I think the raw data that came in with missing start and end station values already had string literals 'NULL' in those rows
- Going back to which years are missing bike ID data, I don't have data for 2017 and 2018, this means that I won't be able to speak to the patterns in where some of these bikes are going to and from in the network

### Validity
- What makes a value in `bike_id` valid
- I guess it'll depend on the process that the data curators took
- But for now I can profile this field some more to look at formatting, values this field takes on, etc.

### Taking a look at the distribution of `bike_id` string length 

| bike\_id\_string\_length | count |
| :--- | :--- |
| 2 | 84 |
| 3 | 886 |
| 4 | 6152 |
| null | 1 |

- `null` make sense as I've grouped the `null` values all together
- However, I'm a bit wary of the smaller string lengths
- 4 seems acceptable but the small number of string length 2 and perhaps 3 makes me wonder if there was a data entry issue
- I think the paranoia stems from the mis-indexed columns I saw from my first run at this program
- I'll look to see if there is a particular pattern with the string length and time

Getting a bit blocked on multiple windows in a query
```sql
SELECT sum(salary) OVER w, avg(salary) OVER w
  FROM empsalary
  WINDOW w AS (PARTITION BY depname ORDER BY salary DESC);
```

Trying to make sense of this.
https://www.postgresql.org/docs/current/tutorial-window.html

- The author has initialized a window or a virtual table, each being `depname` ordered by `salary DESC`
- In the select statement found in the first line, there are two clauses that call the  window function...
- Calling the functions `sum` and `average` `OVER` the window, `w`

- Don't quite think I'm in the same pattern with my use case
- It seems like I have two windows, both the year and the bike_id string length
- The first window needs to be year, following that it'll need to be the bike_id string length
- I'll have to see if the postgres docs offers any insight into this

- Maybe `WINDOW w0 AS (PARTITION BY year)` and `WINDOW w1 AS (PARTITION BY bike_id_string_length)`?

Going to take a break and come back to this after

[[2023-01-10]]

10:07

Going to spend minimal time on this issue. 
- I also took a quick look at `trip_id` string length values across years just to make sure nothing strange is going on
- The string length increases throughout the years which I think convention would expect
- Re: As the number of trips increases the digits or number of characters needed to represent the `trip_id` would also increase

## Looking at membership type

| user\_type | count |
| :--- | :--- |
| Annual Member | 8705682 |
| Casual | 327584 |
| Casual Member | 6007296 |
| Member | 1164784 |

- I guess it might be okay to consolidate under 2 values? Annual and casual?
- I'll have to take a look at the data dictionary and the website for some background info
- So the website provides no mention of casual membership
- Wondering if casual membership means that they've only purchased a pass
- The casual member is likely using a short-term pass rather than an annual membership

### A Break-Down of Membership Types by Year

| user\_type | year | count |
| :--- | :--- | :--- |
| Annual Member | 2018 | 1572980 |
| Annual Member | 2019 | 1859391 |
| Annual Member | 2020 | 1448613 |
| Annual Member | 2021 | 2140730 |
| Annual Member | 2022 | 1683968 |
| Casual | 0017 | 41141 |
| Casual | 2017 | 286443 |
| Casual Member | 2018 | 349975 |
| Casual Member | 2019 | 580126 |
| Casual Member | 2020 | 886252 |
| Casual Member | 2021 | 1434452 |
| Casual Member | 2022 | 2756491 |
| Member | 0017 | 322263 |
| Member | 2017 | 842521 |

Nothing unusual here. It's nice to see that they have membership information in 2017 as well. I think it's pretty important information to have to ensure the we can glean insights from how casual and annual members use the service.


## Re-Visiting `bike_id` I'm not sure if there are any issues with this field
- I don't think there would be a relationship between `bike_id` and time
- Re: I don't see much value in a incremental index of `bike_id` as a function of time
- I.E. Grab a bike and give it a value that doesn't already exist
- Being careful to ensure that there are no duplicate bike IDs
- To ensure proper measurement, especially when bikes are not returned to the stations, on time, or at all
- But I'd imagine that because the bike trip is linked to credit card information, there is an incentive for the customer to return the bike on time
- Because of this I'm not going to explore the field any further

Just going to move forward an work on the tasks under the TODO heading seen below

---

# TODO
- [ ] Collate `trip_id` and save as the new default state of the table
- [ ] Drop duplicate `trip_id` rows
- [ ] Investigate issue with `year` value in the `timestamp` fields; Re: Change `0017` to `2017`
- [ ] Drop rows with null trip duration, this accounts for about 0.07% of the data, doesn't seem to useful in gleaning insights of bike ridership
- [ ] Impute correct station id values in 2017 data
- [ ] Import correct station name for 
- [ ] Impute missing start and end station values in the data set
- [ ] Note in the documentation that there is missing `bike_id` values for the years 2017 and 2018
- [ ] In addition, it would be helpful to highlight what steps I took to clean the data and why
- [ ] See bike share programs in other jurisdictions carry out their service
- [ ] Consolidate `user_type` values to `annual` and `casual` (under the assumption that annual means that they are an annual member, and casual means that they used a daily or short-term pass for the trip)
- [ ] Include this in the data dictionary

# INBOX
- Would be kind of fun to do a network graph of how the bikes travel throughout the network as well; using `bike_id` and station data, maybe timestamp as well, it would be fun to tell a story of the farther travelled bike
	- It's also good to keep in mind that the maintenance crew might also be moving bikes so if there are some gaps or discontinuities it might suggest that the operations team might moved the bike around for some reason or other
- Connecting TTC delay data would be fun as well
- Included overage fee schedule as well; this schedule disincentivizes longer overages by increasing overage fee as a function of time

https://www.dataversity.net/data-cleansing-why-its-important/

https://www.dataversity.net/nine-essential-steps-to-improving-data-quality/

https://www.dataversity.net/data-quality-dimensions/
https://chartio.com/learn/databases/how-to-find-duplicate-values-in-a-sql-table/