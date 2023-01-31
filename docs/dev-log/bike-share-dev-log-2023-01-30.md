[[2023-01-30]]

---
09:14

Looks like the first for today is to learn how to impute missing data. I'm probably going to start with some reading on the problem first.

``` sql
UPDATE Table2 T2
  JOIN Table1 T1 ON T2.opt = T1.opt
    OR T2.val = T1.val
SET T2.val = T1.val
  , T2.opt = T1.opt
WHERE T2.VAL IS NULL
  OR T2.OPT IS NULL;
```

Source: https://stackoverflow.com/questions/31587707/sql-to-copy-missing-data-from-one-table-to-another

Makes sense that the pattern involves an update, join and also seem to make sense as well.

I'll try to write something in pseudocode...

``` pseudocode
update trips 
	join stations on trips.station_id = station.station_id
		or trips.station_name = station.station_name
	set trips.stationd = station.station_name
	where trips.station_name like 'NULL';
```

Not sure why there is a second clause in the join statement. I'll take a quick look to see what's going on here.

On, second thought, I don't think I'll need to explore this pattern just yet. Just need to ensure I can impute my missing values. And I'm fairly certain I won't need the `OR` clause to do so.

The skeleton of this pattern appears to be. 

update target table
		join reference table on target table key = reference table key
		set target table value = reference value
		where target table is this condition (ie filter)

I'll give it a try in the SQL.

Okay, so what I'm seeing is that the pattern is a bit different for postgres.

The table joins look like they're being joined implicitly using the `FROM` clause. Which is pretty cool, but you'd need to be aware that this is what happens when you run this pattern.

It looks like this.

update table a
set a.col = b.col
from table b
	where a.col = b.col;

I understand what's happening in the example on postgresqltutorial. However, I'll need go figure out a way for me to extend the the example. I need to figure out how to add a filter to update only the rows with missing values. Or else I'd be needlessly updating correct rows. Which is somewhere around 16 milllion rows.

``` sql
select count(*)  
from trips_clean  
where start_station_name like 'NULL';  
    -- There we go, 1542 rows  
```



``` sql
select start_station_id,  
       count(*)  
from trips_clean  
where start_station_name like 'NULL'  
group by start_station_id;  
```

| start\_station\_id | count |
| :--- | :--- |
| 7697 | 916 |
| 7714 | 479 |
| 7722 | 147 |

``` sql
select end_station_id,  
       count(*)  
from trips_clean  
where end_station_name like 'NULL'  
group by end_station_id;
```

| end\_station\_id | count |
|:---------------- |:----- |
| 7690             | 17    |
| 7697             | 892   |
| 7714             | 484   |
| 7722             | 161   |
| NULL             | 1012  |

Alright, there are some strange things going on with the data. But I'm at a better spot with a bunch of the station names imputed. 

I'll need to look up these station IDs in the raw table just to see if there was anything strange going on in my original data set.

I might look into the api to see it there was any issue...

I'll do this when I come back from break.

Alright, so I didn't get around to this. But I understand how I might address this issue. I don't suspect that anything strange happened while I was loading the data in.

I'll jump into the python repl to see it these station IDs exist. When I went on a walk, I also wondered why I was getting some null in `station_id`. My guess is that the trips either glitched out, or the bike was never returned.

I'll take a look to see what might be happening.

There are about 1k rows with missing end station name and end station id. I won't be able to impute the missing values for these rows.

I tried my best to preserve the data, but 1k out of 16 mil should be okay to discard.

| year | count |
| :--- | :--- |
| 2019 | 441 |
| 2020 | 468 |
| 2021 | 63 |
| 2022 | 40 |

A breakdown of this slice of data by year.


``` python
>>> station_id_list = [ (station['station_id']) for station in stations ]
>>> missing_station_id = ['7690', '7697', '7714', '7722'] 
>>> for station_id in missing_station_id:
...     print(station_id, station_id in station_id_list)
...
7690 False
7697 False
7714 False
7722 False
```

I thought it would be a bit more difficult but my the logic and patterns that I have under my belt have served me quite well. In my first pomodoro, I've found out that these station IDs don't belong to the stations data API. Not going to delve into the reason. But I'm going to look into whether I could or should include these rows in the data set.