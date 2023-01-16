[[2023-01-16]]

---
16:10

A lot of the cleaning has been completed. However, I'm now faced with having to impute the missing station IDs. The tricky part is this data lives in JSON format. Which luckily I'm familiar with from working with the FPL project. 

I'll need to do a bit of profiling of this data. I could make my own reference table to save on time instead. But I think I'll see if I could pull the data from the endpoint.

*The Toronto Parking Authority manages the Bike Share Toronto program, a form of local mass transit and an enjoyable way to travel the city by bicycle. The system includes 6,850 bikes, 625 stations with 12,000 docking points. Bike Share stations are located in Toronto, East York, Scarborough, North York, York and Etobicoke.*

Wondering what the distinction between station and docking station is...

It's also interesting to see a "Download" link for what looks like an API endpoint.

bike-share-json
https://ckan0.cf.opendata.inter.prod-toronto.ca/dataset/2b44db0d-eea9-442d-b038-79335368ad5a/resource/5c1c2c06-d27f-47b7-ae82-926a6d23d76f/download/bike-share-json.json

bike-share-gbfs-general-bikeshare-feed-specification
https://ckan0.cf.opendata.inter.prod-toronto.ca/dataset/2b44db0d-eea9-442d-b038-79335368ad5a/resource/b69873a1-c180-4ccd-a970-514e434b4971/download/bike-share-gbfs-general-bikeshare-feed-specification.json

Time to bust out some curl/request library stuff!

There seems to be a ton of cool information from this API endpoint. Though it's probably best for me to push one feature at a time. 

With that being said, it looks like I'll be hitting this API for station information.

``` python
>>> len(r.json()['data']['stations'])
652
```

I'll probably need to import this to my database.
Pretty happy with what I accomplished today. 
It was nice to revisit poetry, python, and the requests library