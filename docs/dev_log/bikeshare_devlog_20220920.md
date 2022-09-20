# Bikeshare - Dev Log
[[2022-09-20]]

---

08:32

I prototyped some of the transformations and loading scripts for 2017 and 2018 data. 

I was convinced that I might need to have a different load for 2017 Q3 and Q4 data, however, I think it would just be null if I tried to load it?

In that case I might do something like: 

```
if csv filename has '2017' or '2018' in it:
then ./pgfutter that file to public schema in bikeshare
```

Requirements:
grep regex filename
pg futter it

09:51

Update: 

``` bash
DBNAME=bikeshare
TABLENAME=temp_table
SCHEMA=public

cd ~
for FILE in ~/work/projects/bikeshare/data/raw/*201[7,8]*.csv;                  
do        
./pgfutter --db $DBNAME --schema $SCHEMA --table $TABLENAME csv "$FILE";
done
```

This is part of the loading script I use, not the use of regex and absolute pathing to get all the appropiate files loaded to the database

### Trying to transform start/end time columns
Was thrown this error while trying to transform my columns
```
SQL Error [22008]: ERROR: date/time field value out of range:
```
- Just as expected, the date formats are not consistent between the different csv files
- I'll need to investigate further
- Data cleaning is definitely 80% of the work, I'm feeling that right now

``` sql
-- Checking for the first element in the string
SELECT * 
FROM temp_table tt 
WHERE trip_start_time LIKE '14%'
LIMIT 5;

-- Checking for the second element in the string
SELECT * 
FROM temp_table tt 
WHERE trip_start_time LIKE '%/14%'
LIMIT 5;
```

- I'm not even sure how to address this
- Maybe I can sort by `trip_id` this assumes that trip ids are generated incrementally...
- I could try to sort by `trip_id` and see the behaviour of the `trip_start_time` column
- The issue with data/time field balue out of range was that I likely had two different format in one column, I.E. `dd/mm/yyyy` and `mm/dd/yyyy`
- Which means I'll have to check for a slices of the string and if they are greater than 12, that will tell me if it's month or day
- I'll slice the start column by strings and then convert to integer and perform some operations to identify  which rows need some string manipulation
- I'll then go ahead and perform the transformations I need to in the beginning prior to the error being thrown
