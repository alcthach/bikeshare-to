[[2023-03-06]]

---
10:05

		From what I remember, I think I was trying to see if I could create a `CASE WHEN` statements to change the start and end stations name to match up with the ones in `bst_stations` this way, I can join the tables and impute corresponding station IDs.
		
		Going to hop into Data Grip and take a look at what I have so far!
		
		https://towardsdatascience.com/data-documentation-best-practices-3e1a97cfeda6
		
---

Alright, I think I last left off with forming a query to match the start stations names. I'll have to take a look at the end station names now.

---
# Notes on Data Pre-Processing Script
I want to keep my eventual pre-processing script clean as it goes into production.

So I will annotate my link of thinking here.

#TODO: Also, I might have to make this section of my dev log a stand-alone file afterwards. But for now this will be okay.

So I'll need to document the steps that I took. I borked my data pretty hard because I didn't provide the `else start_station_name` statement, basically this says, if there is a null value in the `id` row, just replace the station name with itself. Instead I lost all the station name data because I didn't specify that to the SQL engine. In any case, this gives me a chance to clean up the code base, because it's a mess. But it's also okay because I needed to work this way so that I can actually push the project forward.

Anyways, I'll need to start from an entirely clean slate right now. So I'm going to drop all my tables and re-initialize the entire project. Wish me luck!

Actually, let me not delete everything lol I'll just initialize a new database instead. I like the `bst` acronym instead. Bit more brief than `bike_share_toronto` it saves more keystrokes.

Going to see if I already have that database initialized.

I don't.

```terminal
bike_share_toronto=# \l
                                      List of databases
        Name        |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges
--------------------+----------+----------+-------------+-------------+-----------------------
 bike_share_toronto | postgres | UTF8     | en_CA.UTF-8 | en_CA.UTF-8 |
 myDatabaseName     | postgres | UTF8     | en_CA.UTF-8 | en_CA.UTF-8 |
 personal_finance   | postgres | UTF8     | en_CA.UTF-8 | en_CA.UTF-8 |
 postgres           | postgres | UTF8     | en_CA.UTF-8 | en_CA.UTF-8 |
 template0          | postgres | UTF8     | en_CA.UTF-8 | en_CA.UTF-8 | =c/postgres          +
                    |          |          |             |             | postgres=CTc/postgres
 template1          | postgres | UTF8     | en_CA.UTF-8 | en_CA.UTF-8 | =c/postgres          +
                    |          |          |             |             | postgres=CTc/postgres
(6 rows)
```

Okay, so I'm going to build this project from the ground up in a new database.

- First step is initializing a new database
- `sudo -iu postgres`
- `createdb bst`
- `psql -d bst`
- `\c bst`

First things, first. Let's initialize the tables.

Running into a bit of an issue. I don't know if I dumped all my csv files into a single table. Or if had segmented tables. Probably helps for me to look at my batch load scripts.

Looks like I loaded each slice into it's own table. I might have down this because of the way the fields differed? 

Looks like there were some issues with encoding...
I also remember seeing some header issues as well.

Short break for now...

I have work today so it's hard to call if I want to keep pushing. I think what I'll end up doing is trying to build the project from the ground up tomorrow. All the scripts, documentation and everything exists so I'll just take some time to review and then put it together.

Yeah I'm done for todayyy.