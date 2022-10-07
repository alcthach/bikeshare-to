# Bike Share - Dev Log
[[2022-10-07]]

---

11:30

The focus for today is seeing if I could complete the modeling for 2017-18 data. Seems doable!

Ii was thrown an error because there was a trip that didn't have a stop time. I tried to cast the column as `timestamp` here, however, because there was a null value in this column the computer couldn't proceed. 

``` sql
SELECT * 
FROM temp_table 
WHERE trip_stop_time LIKE '%NU%'; -- '%' CHARACTER used AS a wildcard

```

```
trip_id,trip_start_time,trip_stop_time,trip_duration_seconds,from_station_id,from_station_name,to_station_id,to_station_name,user_type,raw_start_time,raw_stop_time
2302635,11/29/17 05:53:54,NULLNULL,0,[NULL],Seaton St / Dundas St E,[NULL],NULL,Casual
,11/29/17/05:53:54,NULLNULL
```

I mentioned in the SQL script that this data is not likely usable. Or it might have to live somewhere else. For now, I think I'll exclude it from the model. I'm going to have to make sure that my destination table is able to receive the data properly. I.E. Do the formats match properly?

I always forget it I should be using `ALTER TABLE` or `UPDATE TABLE`
