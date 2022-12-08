[[2022-12-01]]

---

11:45

This document serves as a refresher and an outline of the what's been done and what the next steps for this project might be.

Re: It's been quite some time since I've touched this project. To ensure I don't repeat myself and to ensure the code base is still applicable to my source data, I'll have to review my current documentation and code base. Editing and refactoring where appropriate. 

One thing to note is that I'm not using `pgfutter` during this reboot of this project. Opting to use bash/psql commands instead. 

Example: Batch load of raw csv files
`cat csv files | stdin to psql command that loads csv file to postgres table without header`

### Initial Steps:

#### Sourcing and downloading the data
- Source the data from Toronto Open Data Portal
- Download zip files
- Use linux command to unzip all files to directory
- Flattened all subdirectories
- I already wrote a bash script to standardize the file names, just ran this to process the file names

#### Time to batch load data to postgres server
- `pgfutter` worked during the initial stages of the project, however with the reboot for some reason pgfutter doesn't work
- Spent 2-3 days blocked on this issue
- Opted for a somewhat manual methodology, automated using bash and pqsl commands, however, manual in terms of creating initial talbes where the batch loaded data will live
	- The benefit of this is that I get to do some initial data profiling
- This was accomplished by a short bash script
	- Looked something like:
	- `for FILE in dir; do; echo head -1 of csv file, also echo the file name as well`
	- The pattern above lets me see the columns of each file and whether or not the headers/columns different between quarters or months
- Just to double-back, the bash/psql pattern worked pretty well for batch loading the data
- From here I got blocked by some postgres server authentication or permission issues.
	- Appeared to be resolved by modifying `pg_hba.conf`
	- This lets dbeaver interfact with the postgres database
- Referring to [[bike-share-dev-log-2022-09-13]], I had a similiar idea of 3 different slices of data, this something that I'll continue to run with
- No pgfutter, just manually batch load into destination table

### Loading to Destination Table
- A bit ahead of myself here, but there this the question of how to load the data to the destiation table
- I think it's something as simple as `SELECT INTO` where I decide which columns from the input table are loaded into the target table
- Pretty straight-forward pattern; so I'm thinking that I could try to batch load the data or even try to `COPY table FROM CSV` using specific table mappings
	- This is something that I could look into just in case because this would mean that I make the columns directly into the destination table 
	- Everything is going to be varchar for now, but I'll need to figure out how this methodology will treat missing values. Because the dimensions for a particular set of files is going to be a bit different.
- I could also take a look at the number of headers or columns found in each file and see if they differ as well
- What might happen is that I batch load certain slices of data
- We'll play around with this here
- I'll go ahead and review the rest of the documentation and code base before going back to this!

#### Issue with non-standard datetime format across the data
- This issue was first flagged [[bike-share-dev-log-2022-09-20]]
- While trying to load the data into the destination table it threw me this error:
	- `SQL Error [22008]: ERROR: date/time field value out of range:`
	- Likely because I told SQL to expect a certain format
	- For example, yyyyddmm, but it might have saw yyyymmdd
	- This means that it will throw an error at entries that have mm greater than 12, because months greater than 12 don't exist
- This was a feature in the data that needed to be addressed
- So I spent some time trying to clean the data here; there's no way around this because the destination table has business logic that governed the timestamp format. It needed to be yyyy-mm-dd

Pulled from [[bike-share-dev-log-2022-10-06]]

	Some things to keep in mind about the behaviour of date format in the data:
	- From January 2017 to June 2017 format is `dd/mm/yyyy`
	- From the 13th day in each month up until June 2017, the day is written with a '0' prefix
	- In July 2017, the date format changes to `mm/dd/yyyy` for the rest of the dataset
	- In Jul-Sep 2017, '0' prefix isn't used 
	- In Oct-Dec 2017, '0' prefix is used entirely
	- No prefix used for the whole of 2018

This is one of the most important snippets for the project,

``` sql
SELECT
	trip_id,
	trip_start_time,
	CASE 
		WHEN trip_id::int < 1253915 THEN to_timestamp(trip_start_time, 'dd/mm/yyyy hh24:mi:ss')
		WHEN trip_id::int >= 1253915 THEN to_timestamp(trip_start_time, 'mm/dd/yyyy hh24:mi:ss')
	END AS start_ts
FROM raw_2017_2018
ORDER BY trip_id
COLLATE "numeric";
```

In other words, `draw a line in the sand based on trip_id, convert the timestamp appropriately`

The input datetime data is in a different format, however `to_timestamp` forces the data to standardize into a timestamp format

`COLLATE "numeric"` is something that I have to declare before taking this one

I did a whole bunch of data profiling prior to this that allowed me to make some assumptions about the data and understand which steps I was allowed to take
Re: id increments and assumes chronological order from oldest to most current

🚩 There are some null values in stop_time data that need to be dealt with as well...
See [[bike-share-dev-log-2022-10-07]] for details

🚩 Columns appear to be mis-indexed in October 2022 data (was first flagged here: [[bike-share-dev-log-2022-10-20]])
 - Appears to be a small number of rows (249), however, definitely important that I address this issue in the future
 - I believe that I did some data profile to figure out a solution to this issue...

🚩Technical issues with data entry, Re: Zero-values found for trip_duration, with some trips having different start and endpoints ([[bike-share-dev-log-2022-10-12]])

On [[bike-share-dev-log-2022-10-13]] it appears I've loaded the data but realized more data profiling and cleaning is likely required

As a very important aside, my mental health concern was highlighted here. This appears to be where I took my extended break as well. 

I start back up in [[bike-share-toronto-2022-11-20]]

Highlighting a possible pivot off the project, but recognize there's a lot of value for the project right now. Highlighting the importance of seeing bike share toronto as an infrastructure project, what is the impact if bike share didn't exist. Think about how many people use this for work or to get to places where they would like to spend money?

Alright, after reviewing all the documentation in the dev log, this is where I am now.

Just to highlight, this is a very important pattern/methodology that pushed my project forward:
``` BASH
cat /tmp/raw/bike-share-toronto-ridership-2018*.csv | psql -d bike_share_toronto -c '\copy raw_2018_trips FROM stdin CSV HEADER'
```

I got blocked so hard with pgfutter that I had to consider alternate patterns that would allow me to replicate my project. The issue I ran into was that when I upgraded my operating system, I lost the functionality that I previously had. This was a pretty big issue. But meant that I should consider out to build a more robust dev environment for the project. This also ensured stronger data profiling and somewhat governance.

My next step is going to be to look over the code base I have so far. This will also tell me the data profiling and cleaning that I've done so far. The goal is to produce a data model that will allow me to analyze and generate insights. We're almost back on track here. Going to take a short break for now. Then review the code base. 

I'll be here to take notes and annotate again.

---

[[2022-12-08]]

I might have to profile the data myself. It'll give me practice and also re-jog my memory. I know that it's the slower way of moving the project along. But there's a ton of value for replicating my work rather than starting off from where I last was.

Yep let's do that. There is no real rush to push the project. There's more value in practicing my data skills.

❓When did I load my data? And how?

``` BASH
cat /tmp/raw/bike-share-toronto-ridership-2018*.csv | psql -d bike_share_toronto -c '\copy raw_2018_trips FROM stdin CSV HEADER'
```

This was the script right here...

The pattern in plain English was output the csv file then take input it into the SQL command that writes to the target table stating that it's a CSV, don't include the header

Alright. I'm going to start profiling my data. See you in the next dev log entry dated for today.