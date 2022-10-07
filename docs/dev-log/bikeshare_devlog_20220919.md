# Bikeshare - Dev Log 
[[2022-09-19]]

---

12:18

Continuing with the loading and transforming the csv files. Just learned that stored procedured actually compile first, then execute after. And from what I understand, I can't operate on database objects like columns and tables. I'm going to have to unblock myself here. 

https://www.postgresql.org/docs/current/ecpg-dynamic.html

Code Review for similar situation (https://stackoverflow.com/questions/72094726/stored-procedure-to-update-table-with-a-variable-column-name)

```sql
CREATE OR REPLACE PROCEDURE spup_conditions
(
    _col VARCHAR,
    _parcel INT,
    _factor INT,
    _value INT
)
AS $$
DECLARE
    _colval text := _col;
BEGIN
    EXECUTE
        format('UPDATE conditions SET %I = $1 WHERE parcel_id = $2 AND
        factor_id = $3', _colval)
    USING _value, _parcel, _factor;
    COMMIT;
END;
$$ LANGUAGE plpgsql;
```
 - This person instantiates a procedure call `spup_conditions` 
 - Then proceeds to declare the variables and their type in here
 - I'll have to take care in initializing these varibles with the correct type, in my case, it'll likely be text/varchar for the objects
 - `AS $$` tells the compiler that the code below is what we'd like to execute
 - I'm struggling to understand what `DECLARE _colval text:= _col;` is...
 - Seems like this is a variable scoped in the body of the procedure that is assigned the same value as `_col`, which is declared in the procedure
 - BEGIN EXECUTE format() USING COMMIT END is the pattern I need to focus on
	 - This is where I'm going to place all my column transformation queries
 - For me, this would be something like:
``` SQL
BEGIN
	EXECUTE
		FORMAT('')
	USING target_table, target_column, target_column_holder;
	COMMIT;
END;
$$ LANGUAGE plpgsql;
```

The user reported an issue with the procedure being accepted, howver, there were no changes to the table when the procedure was called.

Example call for the bikeshare data:
``` SQL
CALL transform_columns('temp_table', 
					   'trip_start_time', 
					   'trip_start_time_holder')
```

💡I totally forgot that I should be passing the arguments in string format, DOH.

NGL I'm pretty blocked right now. I'm not sure what is going wrong. But I think I'm just going to do this pythonically perhaps. Or even manually. I won't have to repeat myself that often. Just once for start time and one for end time. Then call it a day.

Then use python or bash to loop through the directory and ./pgfutter each csv into temp table. Then perform the transformations there.

Done is better than perfect. I could figure out how to do this another day. 

Maybe I'm making it a bit too complicated on myself...

I also think that the mainstay of SQL is it's ability to query and model data. In terms of the dynamic capability, that doesn't come easily.

Tomorrow I'll worry about the transformation. Actually I'll do it quickly now.