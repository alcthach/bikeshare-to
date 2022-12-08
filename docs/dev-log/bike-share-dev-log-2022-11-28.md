[[2022-11-28]]

--- 

12:13

I think I might have pre-preprocessed 2017 and 2018 separately. The headings are different between the csv files.

``` Terminal
trip_id,trip_start_time,trip_stop_time,trip_duration_seconds,from_station_id,from_station_name,to_station_id,to_station_name,user_type
trip_id,trip_start_time,trip_stop_time,trip_duration_seconds,from_station_id,from_station_name,to_station_id,to_station_name,user_type
trip_id,trip_start_time,trip_stop_time,trip_duration_seconds,from_station_name,to_station_name,user_type
trip_id,trip_start_time,trip_stop_time,trip_duration_seconds,from_station_name,to_station_name,user_type
trip_id,trip_duration_seconds,from_station_id,trip_start_time,from_station_name,trip_stop_time,to_station_id,to_station_name,user_type
trip_id,trip_duration_seconds,from_station_id,trip_start_time,from_station_name,trip_stop_time,to_station_id,to_station_name,user_type
trip_id,trip_duration_seconds,from_station_id,trip_start_time,from_station_name,trip_stop_time,to_station_id,to_station_name,user_type
trip_id,trip_duration_seconds,from_station_id,trip_start_time,from_station_name,trip_stop_time,to_station_id,to_station_name,user_type
```

``` Bash
cd ~
for FILE in ~/work/projects/bikeshare-to/data/raw/*201[7,8]*.csv;
do
echo "$FILE"
head -1 "$FILE" 
echo " "
done
```

Used to to check the headers for all the files. 
- 2017 Q2 and Q3 are missing station ID data
- And 2018 data headers are in a different order

I will process the in two batches
- 2017
	- It's okay if 2017 data is missing station IDs, it will impute as a null value for now
- 2018

Next up, I'll figure out how to batch load the csv files without pgfutter

The script above points to the correct files. Just going to review my old dev log entries.

Yep, this is going to be my approach. Just work there the data in segments for now... KISS