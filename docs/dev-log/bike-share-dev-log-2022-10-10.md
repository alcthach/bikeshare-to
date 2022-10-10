# Bike Share - Dev Log
[[2022-10-10]]

---

10:07

It seems like the 2017-18 data was loaded successfully. That means I could my attention to loading all data beyond 2017-18. Luckily, I think there was a reason that I profiled and loaded the data in this way. Referencing [[bike-share-dev-log-2022-09-13]], 
it seems like I ran a bash command to profile the headers for each of the files that I have. Starting from 2019, the headers all the files are homogeneous. I recycled the snippet from dev log entry mentioned above to find this out.

``` sql
for FILE in ./*.csv; do echo "$FILE"; head -n 1 $FILE; done
```

> 💡This means that I could move forward to batch load all data from 2019. 
		However, I will need to automate this process. Loading about 37 files.

Running into some logic issues here. Do I want to do something like:

```
for file in processed(dir)
if file has 2019, 2020, 2021 or 2022 in the name
then load to temp table
```

After trying to crack it for the past little while I settled on written two separate for loops for now. I'll try to optimized at a later time. For now it's important that I push towards the analytics part of the project. Remember that it's most important to drive value in this project. I can always re-visit this project and see if I can re-factor and optimize my code base. But for now I need to delve into the data as soon as I can.

Alright so it looks like I was able to run the script successfully. Didn't get the time function to work properly but I at least have progress bars and also print confirmation notes as well.

I have a stopwatch running alongside the terminal to keep try on how it's moving along. About 5-6 minutes to load all the data.

I just thought of something. How do I make sure that I all the files I intend to load are loaded? I think that I should have started out with a print statement first before loading...

I just printed everything. Looks okay. However, I'll need to add September 2022 data if available. 

Would be nice to write a script to pull the data and load it to the database automatically.

Data can also be accessed through an API

``` bash
./pgfutter -db bikeshare --schema public --table temp_table_2019_2022 csv ~/work/projects/bikeshare/data/processed/bikeshare_ridership_2022-09.csv
```

Loaded the outstanding data manually. 

> TODO ❌ Automate ETL for ridership data moving forward

During some initial data profiling, it seems like there are some issues with the load or perhaps data entry. I'm not quite sure but it seems like the NULL values are found in a particular slice of the data. Mainly October 2020 data. After looking at this data a bit closer, seems like the columns where not indexed properly. Re: `end_station_id ` contained `end_time` data. Column index is off by `-1` 

### Profiling Oct 2022
- Out of the ~200k rows of data belonging to this slice, there are about 249 rows that are appeared to be mis-indexed across their columns
- I suspect that the `trip_id` might also be holding some other data, the string length in this column looks a bit suspect here
- For example, one row contains `100026291085` in the `trip_id` column, seems a bit fishy
- Maybe I could compare the average string length in this slice vs. outside  of this slice

```bash
grep '10/23/2020' ~/work/projects/bikeshare/data/processed/bikeshare_ridership_2020-10.csv -h
```

I tried to use the logic above to try and see if there was any pattern I could identify
However, I think that I should be seeing one less delimiter or term 