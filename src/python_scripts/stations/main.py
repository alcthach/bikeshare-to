import requests
import json
import csv
from itertools import chain

url = 'https://tor.publicbikesystem.net/ube/gbfs/v1/en/station_information'

data_file = open('data_file.csv', 'w')

csv_writer = csv.writer(data_file)

def get_object():
    r = requests.get(url)
    data = r.json()
    return data

def get_station_data():
    station_data = get_object()['data']['stations']
    return station_data

def main():
    count = 0
    
    station_data = get_station_data()

    for station in station_data:
        if count == 0:

            header = station.keys()
            csv_writer.writerow(header)
            count += 1

        csv_writer.writerow(station.values())

    data_file.close()

# Python3 program for the above approach
from itertools import chain


# Function to print all unique keys
# present in a list of dictionaries
def UniqueKeys(arr):

	# Stores the list of unique keys
	res = list(set(chain.from_iterable(sub.keys() for sub in arr)))

	# Print the list
	print(str(res))



if __name__ == "__main__":
    main()

# Going to extend script to write to .csv file
# I already have the json object holding the station data available
# Was just thinking that I could also connect to the db instance from here as well
# To save the extra work...


# Counter variable used for writing
# headers to the CSV file

# TODO: Clean up code re-factor, modularize as needed; this can happen much later
