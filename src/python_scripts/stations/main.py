import requests
import json
import csv
from itertools import chain

url = 'https://tor.publicbikesystem.net/ube/gbfs/v1/en/station_information'


def get_object():
    r = requests.get(url)
    data = r.json()
    return data

def get_station_data():
    station_data = get_object()['data']['stations']
    return station_data

def get_header(arr):
    header = list(set(chain.from_iterable(sub.keys() for sub in arr)))
    return header

def write_header_to_csv():
    with open('stations.csv', 'w', newline='') as csvfile:
    
        header_writer = csv.writer(csvfile)
        # The line below could use some revising after 
        header_writer.writerow(get_header(get_station_data()))

# Let's clean this up a bit by doing this
def write_dicts_to_csv():
    with open('stations.csv', 'a', newline='') as csvfile:

        fieldnames = get_header(get_station_data())

        stations_writer = csv.DictWriter(csvfile, restval = 'null', fieldnames = fieldnames)

        stations = get_station_data()

        stations_writer.writerows(stations)

def main():
    write_header_to_csv()
    write_dicts_to_csv()
    
    # It appears these functions over-write rather than append to the file
    # However, it seems like the null values might have been imputed correctly
    
if __name__ == "__main__":
    main()

# Going to extend script to write to .csv file
# I already have the json object holding the station data available
# Was just thinking that I could also connect to the db instance from here as well
# To save the extra work...


# Counter variable used for writing
# headers to the CSV file

# TODO: Clean up code re-factor, modularize as needed; this can happen much later
