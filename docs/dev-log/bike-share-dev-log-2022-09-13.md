---
Tags: #contentcreationidea
---

# Bikeshare - Devlog
[[2022-09-13]]

---

The goal for today is to load all the csvs onto the database.

1. Initialize a `trips` table in the public schema of bikeshare; should include all the columns
2. Load a csv onto a temp table using pgfutter
3. Copy the data from the temp table to  `trips`
4. If this works successfully, write a script that will loop through all the csvs and add them to `bikeshare.trips`

Always refresh your database client 😅

``` bash
./pgfutter --db bikeshare --table temp_table csv file.csv
```

17:39

https://stackoverflow.com/questions/13722724/how-to-use-select-into-to-different-table-with-different-column-names

Alright, so coming back to thing problem again. I just realized that I could maybe batch load each year into the temp table, then `SELECT INTO trips` perhaps. 

Just doing a bit of thinking in my head. 

So I might batch import the csv files from a specific year just as along as they continue the correct number of rows and they're in the correct order. Or else the whole operation is going to be messy. 

Okay, so I'm going to put together a bash script to do all of the loading onto the database temp table then into the destination table. `trips`

The order of the sequence is as follows:

Note:
``` bash
[athach@fedora raw]$ for FILE in ./*.csv; do echo "$FILE"; head -n 1 $FILE; done
```
I ran this command to look at the headers for each of the files in the directory
2017 Q3 and Q4 are both missing the start and end station IDs. They have to live in their own container. 

So maybe we can have 3 containers to loop through and add to a temp table:
1. 2017 Q1, Q2, and all of 2018
2. 2017 Q3 and Q4 b/c of the missing start/end station IDs
	1. TODO: I'll need to impute these values based on the station names...
3. 2019 Q1 and onwards

Control flow:

for file in directory
	if file is from 2017-Q1 or 2017-Q1 or contains 2018
		then pgfutter to temp table
		select temp table into trips table
		drop temp table
	else if file is from 2017-Q3 or 2017-Q4
		then pgfutter to temp table
		select temp table into trips table
		drop temp table
	else if file is from 2019 onwards
		then pgfutter to temp table
		select temp table into trips table
		drop temp table

I think there's a logic error here. Instead of a batch operation per container, I'm processing the file one-by-one. I'm not sure what it would be like in terms of performance. However, I'm inclined to think the batch by container might be faster?

Maybe the first move is to get 3 lists to represent the three batches

then do something like for file in batch one pgfutter to temp table

after than finishes looping, and loading to temp table, then select that temp table into trips

then drop the temp table 

for batch in batches
	for file in batch
		pgfetter csv csv file
	select temp table into trips table
	drop temp table

I'm thinking that I should implement this through sqlalchemy perhaps... this is starting to get quite messy now. And the thought of implementing in bash is making me 😵

I think bash is quite helpful in automate shell tasks, in addition, looking into files and peeking

The file renaming script that I wrote was pretty nifty. However, I think I might need to leverage python for this as it seems a bit more robust. Especially with the control flows that I brainstormed above...