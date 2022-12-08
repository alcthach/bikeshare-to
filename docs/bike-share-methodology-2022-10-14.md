# Bike Share Toronto - Methodology 

2022-10-14

---

Rationale:

This document will be used to highlight the methodology of the ETL portion of this project. It will highlight the data source and the measures taken to process and clean the data. 

---

The raw data was sourced from https://open.toronto.ca/dataset/bike-share-toronto-ridership-data/, existing as zip files containing either monthly or quarterly ridership information from 2014 up to and not including the current month that we're in. 

I downloaded the zip files manually. And unzipped them automatically using a bash command, something like for each file in the dir with suffix .zip unzip into the directory. 

However, I've realized that the filenames were not standardize. Not an absolute necessity, but I took the liberty of standardizing the file names using a bash script that can be found in one of the dev log entries. #TODO: Find the snippet that I used to standardize the file names.

From there I did some data profile by looking through the headers of all the csv files. Using another bash command, I just figured out that the data didn't contain the same number of headers. Which might have posed an issue. Specifically, the earlier data in 2017, and 2018 was missing a 'bike_id' column. However, I knew that I could add a column, and impute with NULL as bike_id values were not recorded during that time period. 

I tried to load the csv files programmatically, however, this posed to be quite the challenge. And there wasn't a clear cut solution to solving this issue. In addition, I figured that because this was my initial data load, I can afford to have the pattern be a bit more static. Especially for the purpose of moving the project forward. However, I think that at the very least some documentation will be important to ensure others are aware of the assumptions and measures taken to prepare the data. Just in case issues arise or are flagged.

Moving on, I discovered a tool call `pgfutter`, which can be used to load csv files to an SQL server. This saved me quite a bit of overhead, and moved the project along nicely. For my use-case, I.E. moderate amount of data in the several gigabytes at most, I found that the performance was okay. I used this to tool to load the data, save for some syntax and logic errors. I was able to automate the loading of the csv files by looping through the specific file names and call pgfutter. 

I should note that the difference in table dimensions meant that I load 2017-2018 on its own. And then added a column for 'bike_id' using the database engine. However, I ran into my first major issue here.

The date format was not standardized across entries in this data. The way I found this out was that I was trying to copy the data to a destination table where I wanted all my trip data to live. And I got thrown an 'out-of-range' error. This is because one slice of the data followed `dd-mm-yyyy` and the other followed `mm-dd-yyyy`. The db engine didn't know how to deal with this data because inevitably there would be month values greater than 12, which would break the script. 

So I need to figure out how to standardize the date values.

I got caught up for a number of weeks trying to find an elegant solution to standardizing the date values. Some of the profiling that I tried to do involved seeing if the 'trip_id' for each was ordered in ascending or chronological order. Which it was. 

I also took the liberty of exploding the date column into their respective substrings. This allowed me to visualize how these values changed over time. In addition, with the early assumption that I had made about the trip_id being in ascending order with the largest trip_id values been more current in time. I was able to see where the data format might have shifted. Note that I took distinct values for these substrings to ensure better performance while profiling the data. 

From there I tried by best to find a programmatic solution to standardizing all the date values. However, I ran into an issue with some of the date values being prefixed with '0', which introduced a bit more difficult to the problem.

After quite a bit of struggle. I realized t`hat it would be important to keep the project moving forward. If I have time in the future, I could revisit this problem and maybe fashion a more elegant solution. However, with this being an initial data load. And the rest of the data not have this issue. I went with a hybrid/programmatic solution where I truncated the datetime column to contain only the date portion, then selected distinct and ordered by trip_id. This allowed me to see where date format had shifted. I indexed on the exact trip_id where this changed happened and used that in logic to tell the db engine where the format of the date changed so that it was able to standardize the data to iso timestamp format. 

I think at this point. I might hope over to dbbeaver to delete and re-initialize all the data. I'll document all the assumptions, decisions, and actions taken to prepare the data here. 

Load csv files using bash scripts, all they do is loop through regex and pgfutter to the schema



### TODO:
- Impute missing station IDs in 2017-2018 data
- Add 'bike_id' column and impute with NULLs
- Change start/stop end times to timestamp format

Review all the scripts I have so far and see which ones are needed for data pre-processing.
