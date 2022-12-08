---
Tags: #contentcreationidea
---

# Bikeshare - Devlog
[[2022-09-12]]

---

Alright so I guess my options with the importing the csv files are to either bulk insert and process the information there. 

Or to process the data through some sort of column mapping. 

The logic that I might have seen is to load the csv to a temp table, then feed it into the main table using a column mapping.

Meaning that I might have to look a some similarities between the columns on the csv table and my main table that I've initialized.

This would be a great article and maybe YouTube video to do as it seems like it's not readily available on a Google search!

- It seems like a majority of the files are formatted with the headers that require
- The main table has the headers for changes to the data in 2020, meaning that there is monthly data in there
- It doesn't matter too much that the files are divided into quarterly or monthly partitions, their rows are going to be inserted into the main table eventually
- The main issue is mapping the columns and writing the rows properly 

Maybe some logic like with temp column name is similar to main column, then write the column contents to the main column

If this column doesn't exist then populate the main column with NULL 

Control Flow: 
Load csv to temp table
Copy temp column column to its corresponding column on the main table

15:06

For me to use,
``` SQL
\COPY temp_table FROM '/tmp/bikeshare_ridership_2017_Q1.csv' DELIMITER ',' HEADER CSV;
```

I need to have the structure of the csv match the `temp_table`, the issue is the the table doesn't have any columns...

It might be a better idea to use some tools to get the job done. Maybe pgfutter might be it. I just need import the csv into a table and then perform some operations from there.

I was a bit blocked in terms of figuring out which tool to use. I'll try both. Starting with `pgfutter` and then `csvkit`

15:45

Silly me trying to find the data that `pgfutter` outputted 😅

``` Terminal
[athach@fedora ~]$ ./pgfutter --db bikeshare --table trips csv /tmp/bikeshare_ridership_2017_Q1.csv
9 columns
[trip_id trip_start_time trip_stop_time trip_duration_seconds from_station_id from_station_name to_station]id to_station_name user_type
 14.40 MiB / 14.40 MiB [======================================================================] 100.00% 3s
132123 rows imported into import.trips
```

It actually lives in a database called `imports`. Thank goodness I remember some of my SQL syntax!

``` bash
sudosd
```

``` terminal
athach@fedora ~]$ ./pgfutter --host "localhost" --port "5432" --db "bikeshare" --schema "public" --table 
"tips" --user "postgres" --pw "admin" csv /tmp/bikeshare_ridership_2017_Q1.csv
9 columns
[trip_id trip_start_time trip_stop_time trip_duration_seconds from_station_id from_station_name to_station]id to_station_name user_type
 14.40 MiB / 14.40 MiB [======================================================================] 100.00% 3s
132123 rows imported into public.tips
```
Mind the typo...
- Learned that `pgfutter` won't throw an error at you if anything looks sketchy (Source: https://www.anycodings.com/1questions/5065141/importing-csv-using-pgfutter-to-postgresql)
- I realized that the processing time was suspiciously fast on the other attempts 
- A bit slower on this one when I passed all the arguments that I need to...

``` terminal
bikeshare=# \dt
        List of relations
 Schema | Name | Type  |  Owner   
--------+------+-------+----------
 public | tips | table | postgres
(1 row)
```

- I'm not entirely sure why the import schema doesn't show up when I run this command...
- Thinking back to BTSN days, maybe I need to switch to that schema
- By default, it seems like `public` is a schema that is initialized by default?

``` terminal
bikeshare=# SET search_path TO import;
SET
bikeshare=# SHOW search_path;
 search_path 
-------------
 import
(1 row)
```

This allows me to look into the `import` schema

``` terminal
bikeshare=# \dt
                    List of relations
 Schema |            Name             | Type  |  Owner   
--------+-----------------------------+-------+----------
 import | bikeshare_ridership_2017_q1 | table | postgres
 import | trips                       | table | postgres
(2 rows)
```

- And... this was where my imported tables from pgfutter were hiding!
- So my parameters turned out to be correct, it appeared to work the first time because I pointed to `public` schema, that was the only issue

#question

- What is a schema then? It's a collection of all the tables that are related to each other. 
- In this case it would make sense for me to write the data from pgfutter to a temporary table
- Or at least has the table tear itself down after it's finished processing to the main table
- In this regard I think I've unblocked myself, at least related to the load of a csv to the database

From here, 
- I could consider my control flow 
- Compare the columns from the imported table to the main table
- And write the data from the imported table to the main table appropriately...
- Also ensure that the csv is written to a table names `temp_table` or something of that effect in order to write a procedure or a function that will move the data over to the main table
- Some solutions to consider: https://stackoverflow.com/questions/21018256/can-i-automatically-create-a-table-in-postgresql-from-a-csv-file-with-headers

Alright so it looks like I got my script to load csv to the database correctly. From there I need to initialize a main table where all the rows will live after they've been processed.

- What's interesting is that `pgfutter` did not identify what the data types were that were going in
- I'll take a moment to look into this b/c I'll need to initialize the main table here

