## Data Dictionary
alcthach@gmail.com
[[2022-12-29]]

---

## `Ridership`

| field                   | description | type    |
| ----------------------- | ----------- | ------- |
| `trip_id`               | unique      | varchar |
| `trip_duration_seconds` |             |         |
| `start_station_id`      |             |         |
| `trip_start_time`       |             |         |
| `start_station_name`    |             |         |
| `end_station_id`        |             |         |
| `trip_end_time`         |             |         |
| `end_station_name`      |             |         |
| `bike_id`               |             |         |
| `user_type`             |             |         |
|                         |             |         |

---
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




---
# TODO:
- [ ] Drop duplicate `trip_id` rows
- [ ] Investigate issue with `year` value in the `timestamp` fields
- [ ] 

https://www.dataversity.net/data-cleansing-why-its-important/

https://www.dataversity.net/nine-essential-steps-to-improving-data-quality/

https://www.dataversity.net/data-quality-dimensions/
https://chartio.com/learn/databases/how-to-find-duplicate-values-in-a-sql-table/