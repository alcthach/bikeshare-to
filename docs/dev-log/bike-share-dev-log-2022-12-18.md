[[2022-12-18]]

---
08:16

I'll need to take a look at my load scripts. It's bringing one of the headers into one of the rows. I might be missing the HEADER argument somewhere in `bike-share-batch.sh`

``` sql
SELECT * FROM raw_2017_q1q2 WHERE trip_id LIKE 'trip_id';
```

Output: 
``` text
bike_share_toronto=# SELECT * FROM raw_2017_q1q2 WHERE trip_id LIKE 'trip_id';
 trip_id | trip_start_time | trip_stop_time | trip_duration_seconds | from_station_id | from_st
ation_name | to_station_id | to_station_name | user_type 
---------+-----------------+----------------+-----------------------+-----------------+--------
-----------+---------------+-----------------+-----------
 trip_id | trip_start_time | trip_stop_time | trip_duration_seconds | from_station_id | from_st
ation_name | to_station_id | to_station_name | user_type
```

Looking at the batch load script, I'm not sure where that extra row is coming from because `HEADER` is included in the argument. Unless the raw file itself has a duplicate row...

Not the case either...

Maybe I could re-initialize everything as see if this is still the case?

Hmm...

``` text
Loading 2020 to present data.
ERROR:  invalid byte sequence for encoding "UTF8": 0x96
CONTEXT:  COPY raw_2019_present, line 303
```

``` bash
for FILE in ~/work/projects/bikeshare-to/data/raw/*; do echo "$FILE" && uchardet "$FILE"; done
```

# Output
``` text
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-batch-load.sh
ASCII
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2017_Q1.csv
ASCII
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2017_Q2.csv
ASCII
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2017_Q3.csv
ASCII
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2017_Q4.csv
ASCII
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2018_Q1.csv
ASCII
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2018_Q2.csv
ASCII
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2018_Q3.csv
ASCII
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2018_Q4.csv
ASCII
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2019_Q1.csv
UTF-8
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2019_Q2.csv
UTF-8
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2019_Q3.csv
UTF-8
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2019_Q4.csv
UTF-8
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2021-01.csv
WINDOWS-1258
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2021-02.csv
UTF-8
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2021-03.csv
UTF-8
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2021-04.csv
UTF-8
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2021-05.csv
EUC-TW
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2021-06.csv
UTF-8
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2021-07.csv
UTF-8
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2021-08.csv
UTF-8
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2021-09.csv
UTF-8
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2021-10.csv
UTF-8
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2021-11.csv
UTF-8
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2021-12.csv
UTF-8
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2022-01.csv
UTF-8
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2022-02.csv
UTF-8
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2022-03.csv
UTF-8
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2022-04.csv
UTF-8
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2022-05.csv
UTF-8
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2022-06.csv
UTF-8
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2022-07.csv
UTF-8
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2022-08.csv
UTF-8
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2022-09.csv
UTF-8
/home/athach/work/projects/bikeshare-to/data/raw/bike-share-toronto-ridership-2022-10.csv
UTF-8
/home/athach/work/projects/bikeshare-to/data/raw/clean_filenames.sh
ASCII
```

---

- The files are in different encodings... If I coerce then I'm going to be missing some characters
- I'm probably better served looking into the different files to see what's going on
- Also, I'm missing 2020 data for some reason...

## TODO: 
- [ ] Load 2020 data
- [ ] Create different DB's for the different encodings 
	- Seems like it wasn't ready to handle UTF-8

# I think I know what happened here
``` bash
# Load 2019 
echo 'Loading 2019 data.'
cat bike-share-toronto-ridership-2019*.csv | psql -d bike_share_toronto -c '\copy raw_2019_present FROM stdin CSV HEADER'
echo $?


# Load 2020 to present
echo 'Loading 2020 to present data.' 
cat bike-share-toronto-ridership-202*.csv | psql -d bike_share_toronto -c '\copy raw_2019_present FROM stdin CSV HEADER'
echo $?
```
- I'm loading different encodings into the same database
- I think out of convenience, I wanted to load all the csv files to one database because they all had the same column headers
- However, this doesn't work because the csv files are encoded differently
- **A possible solution is to initialize separate databases or tables based on their encodings and time**

---
# Summary