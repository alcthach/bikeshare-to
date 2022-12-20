[[2022-12-19]]

--- 
09:58

## Continuing to profile encoding for the csv files
- Encodings include:
	- ASCII
	- UTF-8
	- WINDOWS-1258

# Summary of csv encodings:
|index|segment|encoding|
|--|------|--------|
|1|2017 Q1 to 2018 Q4|ASCII|
|2|2019 Q1 to 2019 Q4|UTF-8|
|3|2020|UTF-8|
|4|January 2021|WINDOWS-1258|
|5|Feb 2021 to Apr 2021|UTF-8|
|6|May 2021|EUC-TW|
|7|Jun 2021 to Present|UTF-8|

Need to download 2020 data! DONE.

I have to remember the headings also differ somewhere in the data.

The previous partitions reflect this. 
Re:
- 2017 Q1, Q2
- 2017 Q3, Q4
- 2018
- 2019 to Present

# What makes the most sense in terms of database partitioning?
- I'm thinking by headers, chronological order, then encodings
- For example:

# For example,
|index|segment|encoding|
|-|-------|--------|
|1|2017 Q1, Q2|ASCII|
|2|2017 Q3, Q4|ASCII|
|3|2018|UTF-8|
|4|2019-2020|UTF-8|
|5|January 2021|WINDOWS-1258|
|6|Feb 2021 to Apr 2021|UTF-8|
|7|May 2021|EUC-TW|
|8|Jun 2021 to Present|UTF-8|

```
So there are three slices of data
- 2017 Q1 and Q2, and 2018 
- 2017 Q3 and Q4
- 2019 to present

This means that I could profile, clean and load to the destination table by these three slices. 

- 4 slices could also work as well
- Giving 2018 their own slice
- So instead, 
	- 2017 Q1 Q2
	- 2017 Q3 Q4
	- 2018
	- 2019 - Present
```

Re: Preserves chronological order in case there are some issues that emerge between the 2017 and 2018 data. Don't want to get too mixy mixy

# Completed:
- Updated init tables script 
- Updated scripts, will need to run this afterwards to see if it all works!

---

18:23

Alright. So I ran the batch load script. And by segmenting the raw data I was able to see where the load is breaking. 


``` terminal 
Loading Jan 2021 data.
ERROR:  invalid byte sequence for encoding "UTF8": 0x96
CONTEXT:  COPY raw_jan_2021, line 303
1
```

AND

```
Loading May 2021 data.
ERROR:  invalid byte sequence for encoding "UTF8": 0xc7 0xf4
CONTEXT:  COPY raw_may_2021, line 852
1
```

- Both are encoded as WINDOW-1258 and EUC-TW, respectively.
- Based on the error messages, it couldn't coerce the data into UTF8
- I'll have to figure out how to work with these two slices of data...
- Extended UNIX Code-TW, Traditional Chinese, Taiwanese
- WIN1258 	Windows CP1258 	Vietnamese
- Why... what happened here?

``` psql
\l
```

```
                                      List of databases
        Name        |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
--------------------+----------+----------+-------------+-------------+-----------------------
 bike-share-toronto | postgres | UTF8     | en_CA.UTF-8 | en_CA.UTF-8 | 
 bike_share_toronto | postgres | UTF8     | en_CA.UTF-8 | en_CA.UTF-8 | 
 myDatabaseName     | postgres | UTF8     | en_CA.UTF-8 | en_CA.UTF-8 | 
 postgres           | postgres | UTF8     | en_CA.UTF-8 | en_CA.UTF-8 | 
 template0          | postgres | UTF8     | en_CA.UTF-8 | en_CA.UTF-8 | =c/postgres          +
                    |          |          |             |             | postgres=CTc/postgres
 template1          | postgres | UTF8     | en_CA.UTF-8 | en_CA.UTF-8 | =c/postgres          +
                    |          |          |             |             | postgres=CTc/postgres
```
 I'll have to take a look at the two slices of data to see if I can afford to lose some characters

``` bash
iconv -f WINDOWS-1258 -t UTF-8 bike-share-toronto-ridership-2021-01.csv bike-share-toronto-ridership-2021-01.csv
```

``` Shell
iconv -f EUC-TW -t UTF-8 bike-share-toronto-ridership-2021-05.csv bike-share-toronto-ridership-2021-05.csv --verbose
```

Ran both commands above to convert the respective csv files to the correct encoding

``` bash
[athach@fedora processed]$ cat bike-share-toronto-ridership-2021-05.csv | psql -d bike_share_toronto -c '\copy raw_may_2021 FROM stdin CSV HEADER ENCODING "EUC_TW"'
ERROR:  syntax error at or near ""EUC_TW""
LINE 1: COPY  raw_may_2021 FROM STDIN CSV HEADER ENCODING "EUC_TW"
```

Looks like it might have been an issue with having to escape a specific character. I wasn't able to pass `ENCODING "EUC_TW"` as an argument.

SOLUTION:
``` psql
bike_share_toronto=# \copy raw_may_2021 FROM /tmp/bike-share-toronto-ridership-2021-05.csv CSV HEADER ENCODING 'EUC_TW'
COPY 424023
```
I cp'ed the csv to /tmp/ then I loaded it manually while passing the encoding_name

I'll do this for Jan 2021 data as well and then we should be Gucci

``` psql
bike_share_toronto=# \copy raw_jan_2021 FROM /tmp/bike-share-toronto-ridership-2021-01.csv CSV 
HEADER ENCODING 'WINDOWS1258'
COPY 86371
```

Great. It works. Some time later I could consider refactoring this into the batch load script.

Summary: 
All the csv files have been successfully loaded to the database

Pretty solid day altogether. 

Wasn't sure why I went off on this tangent. But it was a pretty important one it seems.

I learned some pretty important patterns:
- `iconv` for converted file to different encoding 
- `uchardet` to detect the encoding type of a file
- `ENCODING 'encoding_name'` a psql parameter that's useful on the client-side for uploading a csv whose encoding does not match the server's
- 