[[2023-01-31]]

---
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

I'll need to be able to explain this in better terms, however, 0.025% of the data set is missing either start or end station names. At this point, I feel pretty comfortable with dropping these rows.

I could try to glean insights into what might have happened at a later data. But for now, for the sake of brevity, and common sense. Re: Rather large sample size, will allow me to maintain strength in the data. The larger the sample size, the more likely the sample is likely to represent the population.

Alright those roughly 4k rows were dropped from the data set
