# Dev Log
2022-09-10

- I like riding bikes
- I have some experience with the Bixi project, it'd be fun to port the project from BTSN over to Bike Share Toronto

## Initial tasks
- Download data
- Unzip the data
- Standardize the filenames

# Addressing different types of file names
- Looks like there are 4 patterns of file names for the data
- Going to perform some string manipulations and re-write each pattern to a standard file name pattern
- I'll have to consider that some csvs contain monthly data, some contain quarterly data
- Do I want have quarter data or monthly?
- "Limitations
** ** Note: There is a variation between the information included in 2014/2015 vs 2016 & ongoing. This is due to a change in software providers in July 2016, and the data collection/reporting methods are different compared to previous provider. While 2014 - 2019 is provided in quarters, 2020 and beyond is provided as monthly data."
- I'll have to investigate the limitation above

# Limitations:
- Are the headers the same though?
- Semantically, yes. However, I'll need to normalize the headers
- I might have to do somework to convert quarterly into monthly data
- head -n1 test.txt | tr , '\n'

# TODO
- Also download station data, and bike path data Re: Able to ask more interesting questions!
- Pull historical weather data
- Special events data

# Snippets
[athach@fedora dev_log]$ head -n1 ../../data/raw/'Bike Share Toronto Ridership_Q1 2018.csv' | tr , '\n'
trip_id
trip_duration_seconds
from_station_id
trip_start_time
from_station_name
trip_stop_time
to_station_id
to_station_name
user_type

[athach@fedora dev_log]$ head -n1 ../../data/raw/'Bike Share Toronto Ridership_Q1 2018.csv' | tr , '\n'
trip_id
trip_duration_seconds
from_station_id
trip_start_time
from_station_name
trip_stop_time
to_station_id
to_station_name
user_type


