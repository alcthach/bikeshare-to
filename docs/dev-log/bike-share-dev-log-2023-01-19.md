[[2023-01-19]]

---

10:32

The plan for today is explore and profile the API end point for station data. Keeping in mind that I'm doing this so that I could impute some missing station data in my data set, if possible. 

A good chance to brush up on my python, and requests library skills as well. I'll probably look into using JSON in postgresql workflows as well.

---
## On Working with Bike Share Toronto Station Data API

This is the endpoint that  I'm hitting
https://tor.publicbikesystem.net/ube/gbfs/v1/en/station_information
- #TODO Discuss this in the documentation
- I'll want to ship this out for others so they can iterate and continue where I left off
- Without having to do all the prior data cleaning or not much of it moving forward

### Sample Record of Stations Endpoint

``` python
>>> station_data[0]
{'station_id': '7000', 'name': 'Fort York  Blvd / Capreol Ct', 'physical_configuration': 'REGULAR', 'lat': 43.639832, 'lon': -79.395954, 'altitude': 0.0, 'address': 'Fort York  Blvd / Capreol Ct', 'capacity': 35, 'is_charging_station': False, 'rental_methods': ['KEY', 'TRANSITCARD', 'CREDITCARD', 'PHONE'], 'groups': [], 'obcn': '647-643-9607', 'nearby_distance': 500.0, '_ride_code_support': True}
```

More human-readable version:
``` python
>>> pp.pprint(station_data[0])
{ 'station_id': '7000',
  'name': 'Fort York  Blvd / Capreol Ct',
  'physical_configuration': 'REGULAR',
  'lat': 43.639832,
  'lon': -79.395954,
  'altitude': 0.0,
  'address': 'Fort York  Blvd / Capreol Ct',
  'capacity': 35,
  'is_charging_station': False,
  'rental_methods': ['KEY', 'TRANSITCARD', 'CREDITCARD', 'PHONE'],
  'groups': [],
  'obcn': '647-643-9607',
  'nearby_distance': 500.0,
  '_ride_code_support': True}
```

It's probably best practice for me to load the entire record and transform later. Rather than trying to hand-pick the fields that I want to put in the database.

Next task is going to be to load it to the database. I might have to consider updating these tables later on however, for the sake of what I need to accomplish. Re: Imputing missing values in the data, I just need the `address` and the `station_id`  values.

Though the other fields are worth explore at a later time. For now I think I'll use the python `file` library to save as a json file.

I'll initialize a table in my pg database to receive the data...

All done.

Just going to review the link below to see if it's feasible for me to load a JSON file using `psql` `\copy` function

https://konbert.com/blog/import-json-into-postgres-using-copy

The web page above mentions have to convert the json file to a newline delineated JSON file `NDJSON` 

Going to do some more reading on this issue. According to the postgres docs, I could also pass `text` as an argument, for the batch loading for trip data, I passed `csv` as an argument. I could also think about seeing if there's a tool that will help me transform the list of dicts to a csv or appropriate format...

https://www.postgresql.org/docs/current/sql-copy.html

`text` is the default. But there are some constraints present to ensure the sql engine is able to figure out where each record begins and ends, and key-value pair for the matter as well...

It seems like the sql engine is not readily equipped to digest json formats... Re: Does not have the correct delimiters found in `text` or `csv` formats

Coming back from my break. Going to take a look at some python operations to help me transform the object to a digestable format. Python feels like the natural solution to the problem. Re: quick and eas y script, not requiring a performant solution, just easy to implement. I.E. let's not use bash for this.

---

### Converting `json` to `csv`

https://www.geeksforgeeks.org/convert-json-to-csv-in-python/

Code example from link can be found directly below:
``` python
# Python program to convert
# JSON file to CSV


import json
import csv


# Opening JSON file and loading the data
# into the variable data
with open('data.json') as json_file:
	data = json.load(json_file)

employee_data = data['emp_details']

# now we will open a file for writing
data_file = open('data_file.csv', 'w')

# create the csv writer object
csv_writer = csv.writer(data_file)

# Counter variable used for writing
# headers to the CSV file
count = 0

for emp in employee_data:
	if count == 0:

		# Writing headers of CSV file
		header = emp.keys()
		csv_writer.writerow(header)
		count += 1

	# Writing data of CSV file
	csv_writer.writerow(emp.values())

data_file.close()
```

Going to see if I could break this down or translate into psuedo-code...

``` text
import the required libraries/packages

open the file
save the object to variable called 'data'

instantiate object adjective_data to pull the json object, list of dicts

open a new empty file with type csv, I'll use this to jump the data from the json file afterwards

I guess the csv library has a built-in method call writer()

instantiate csv_writer object, pass the csv object as an argument in the csv.writer() method

instantiate a counter

loop through each record in the json object, forgot this was instantiated already

	if count == 0: <- need this as an incrementer 

		header = json_object.keys()
		csv_writer.writerow(header)
		count += 1
	csv_writer.writerow(json_object.values())

close file after done writing all the rows to csv
```

Pretty straight forward. I'm going to interactive with the object bit in the REPL for now. And read some of the documentation for the `csv` library.

In addition, I don't think I'll be required to use the `json.load()` method. Only because I'm not pulling from a data. The json object is initialized by pulling the data using `requests.get()`. The `response` is transformed into a `json` object by calling `.json()` on the response object. 

I could probably step the initial steps and call the `csv` methods on the `station_data` object that I initialized...

### In the REPL

``` python
>>> for value in station_data[0].values():
...     print(value)
...
7000
Fort York  Blvd / Capreol Ct
REGULAR
43.639832
-79.395954
0.0
Fort York  Blvd / Capreol Ct
35
False
['KEY', 'TRANSITCARD', 'CREDITCARD', 'PHONE']
[]
647-643-9607
500.0
True
```

I hadn't done any operations with `dict` in a long while. Kind of cool to call values on the `dict` object just to see what it'd return.

The `json` object is a specifically-formatted object. However, it closely resembles as python dictionary. Which is a list of dictionaries, with each dictionary have a set of key-values pairs.

Which makes the for loop in the code example pretty clear. For each `dict` take the keys and make it the header, take values and write the values...

I forgot what kind of for loop syntax this is:

``` python
>>> print([key for key in station_data[0]])
['station_id', 'name', 'physical_configuration', 'lat', 'lon', 'altitude', 'address', 'capacity', 'is_charging_station', 'rental_methods', 'groups', 'obcn', 'nearby_distance', '_ride_code_support']
```

But this shows me what the headers of the stations table will be...

---
15:55

Going to take a look at the python docs for the `csv` library
	Reference: https://docs.python.org/3/library/csv.html

Note: `csv` is actually a module, not a library

`cvs.writer` is the function that I'm going to be using for the quick  script that I'm writing to pull convert from JSON to CSV

Though... `cvs.DictWriter` looks pretty interesting as  well...
- I might be  mistaken because this looks like they call `.writerow()` on the `DictWriter` object, which might not be something I'm interested in

On second thought, I'm not quite sure if I have the right tool for the problem. Maybe I have to consider `DictWriter`. This is because I'm actually not working with a json file. But I'll take a look at the example above again.

I don't quite understand the `count == 0` pattern...

``` bash
[athach@fedora stations]$ cat data_file.csv | wc -l
654
```

Looks like the contents of the json-type object successfully. However, I'm not sure why I have 1 extra record. I had 652 elements when I ran `len(station_data)` 653 would make sense because of the header row.

I'll take a look at the end to see if anything strange happened.

I lied it's 653. I think there might have been an additional station added between today and yesterday. Really strange... Because I ran a command the other day seen [[bike-share-dev-log-2023-01-16]]

--- 
``` bash
bike_share_toronto=# \copy bst_stations FROM /tmp/data_file.csv CSV HEADER
ERROR:  extra data after last expected column
CONTEXT:  COPY bst_stations, line 3: "7001,Wellesley Station Green P,ELECTRICBIKESTATION,43.66496415990742,-79.38355031526893,0.0,Yonge / ..."
```

Looks like I have some issues trying to load the csv

I might have initialize my sql table improperly...

Nope table has the correct number of fields

``` python
>>> pp.pprint(station_data[1])
{ 'station_id': '7001',
  'name': 'Wellesley Station Green P',
  'physical_configuration': 'ELECTRICBIKESTATION',
  'lat': 43.66496415990742,
  'lon': -79.38355031526893,
  'altitude': 0.0,
  'address': 'Yonge / Wellesley',
  'post_code': 'M4Y 1G7',
  'capacity': 26,
  'is_charging_station': True,
  'rental_methods': ['KEY', 'TRANSITCARD', 'CREDITCARD', 'PHONE'],
  'groups': [],
  'obcn': '416-617-9576',
  'nearby_distance': 500.0,
  '_ride_code_support': True}
```

*Pulled from `data_file.csv`*

``` text
station_id,name,physical_configuration,lat,lon,altitude,address,capacity,is_charging_station,rental_methods,groups,obcn,nearby_distance,_ride_code_support
7000,Fort York  Blvd / Capreol Ct,REGULAR,43.639832,-79.395954,0.0,Fort York  Blvd / Capreol Ct,35,False,"['KEY', 'TRANSITCARD', 'CREDITCARD', 'PHONE']",[],647-643-9607,500.0,True
7001,Wellesley Station Green P,ELECTRICBIKESTATION,43.66496415990742,-79.38355031526893,0.0,Yonge / Wellesley,M4Y 1G7,26,True,"['KEY', 'TRANSITCARD', 'CREDITCARD', 'PHONE']",[],416-617-9576,500.0,True
7002,St. George St / Bloor St W,REGULAR,43.667333,-79.399429,0.0,St. George St / Bloor St W,19,False,"['KEY', 'TRANSITCARD', 'CREDITCARD', 'PHONE']",[],647-643-9615,500.0,True
```

Looks like the address field might be causing some issues...

There must be a way for me to escape the commas found in the `address` field...

Nope silly me I think I forgot `post_code` or for some reason it didn't read out in the file... That or there are some missing key-value pairs for `post_code`

Yeah... I'm not sure why hasn't pulled `post_code` in the headers...

I think I might know what might be going on here. 

``` python
for station in station_data:
        if count == 0:

            header = station.keys()
            csv_writer.writerow(header)
            count += 1

        csv_writer.writerow(station.values())
```

It's looking like it's trying to pull header values from `station.keys()`. The issue is that I wasn't seeing `post_code` in the header of the csv file. Which is a bit strange. I'll have to investigate and see if there are any elements in dictionary that don't have any
`post_code` as keys.

Okay, so `post_code` is not found in every element found in stations. In other words, some elements don't have a `post_code` key-value pair.

Might have to find a pythonic way to parse through and see what the distinct key-value pairs are across the 653 elements.

I definitely do not want to print each set of keys for each element. Though probably have enough memory to do so.

Google is going to be my best friend here.

This might be a problem for another day. However, I'll try to prime my brain to solve the problem. Looks like it might involved itertools which is pretty cool actually.

https://www.geeksforgeeks.org/python-program-to-get-all-unique-keys-from-a-list-of-dictionaries/

Copy pasta'd from the link above, super helpful!

``` python
# Python3 program for the above approach
from itertools import chain


# Function to print all unique keys
# present in a list of dictionaries
def UniqueKeys(arr):

	# Stores the list of unique keys
	res = list(set(chain.from_iterable(sub.keys() for sub in arr)))

	# Print the list
	print(str(res))
```

``` python
>>> main.UniqueKeys(stations)
['post_code', 'altitude', 'obcn', 'lon', 'lat', 'capacity', 'physical_configuration', 'station_id', 'nearby_distance', 'address', '_ride_code_support', 'is_charging_station', 'name', 'cross_street', 'rental_methods', 'groups']
```

Looks quite different from my csv file

``` text
station_id,name,
physical_configuration,
lat,
lon,
altitude,
address,
capacity,is_charging_station,
rental_methods,
groups,
obcn,
nearby_distance,
_ride_code_support
```

I'm missing:
- `post_code
- `cross_street`

I think the solution to this is to ensure that I've inputted default values. And to make sure that I re-initialize the stations table to have the missing fields.

I think I have a way to input with null values already using `psql copy` But I'll take a look at it tomorrow or Sunday.

---

## Closing Up for the Day
- Bit of a review with python, was nice to write a quick and dirty script
- Re-familiarized myself with data types in python 
- Was nice to just be in a REPL environment working with python 
- Overall, I expect to complete the task of loading station data to the database during my next session
- The itertools chain module was really cool to employ; and save me a ton of time
- I'll look to re-initialize the `stations` table with the missing fields, then impute null in the missing data in the copy script that I'll use after
