[[2023-02-23]]

---
08:33

Looks like I'll be exploring the `null` values found in the slice of 2017 data. Specifically in the start and end station IDs. I think the concern was that the station names were not consistent between 2017 and the rest of the data set. I mean, I still have some location data, however, I don't have access to lat and lon data. This is because the station names don't line up with `bst_stations` table. And I don't have the IDs. Re: nulls.

So the plan for today is to find and implement a solution. Semantically, it appears the names match up, but that's not good enough.

I think I was trying to figure out how to join on a partial string match.

---
| start\_station\_name | name | station\_id |
| :--- | :--- | :--- |
| 25 York St \(ACC/Union Station South\) | Union Station | 7033 |
| 519 Church St - SMART | 519 Church St | 7241 |
| Lake Shore Blvd W / Ontario Dr\(Ontario Place\) | Lake Shore Blvd W / Ontario Dr | 7242 |
| Queen St E / George St \(Moss Park\) | Moss Park | 7761 |

``` sql
select distinct on (start_station_name) start_station_name, name, station_id  
from  
    (  
        select start_station_name  
        from trips_clean  
        where start_station_id is null) as t0  
        join bst_stations on textcat('%', textcat(start_station_name, '%')) like textcat('%', textcat(bst_stations.name, '%'));
```

This needs to go into the documentation. This is a very specific case where one of the entire string is found somewhere in the other string.

This is a very restrictive condition but an important pattern to highlight in the data.

13452 rows fit this pattern, there are still 200k rows left to explore

---

Should note that I think there are some fields with direct matches, so I dealt with that already!

---
| name | start\_station\_name | station\_id |
| :--- | :--- | :--- |
| Bay St / Bloor St W \(East Side\) | Bay St / Bloor St W | 7029 |
| Bay St / Bloor St W \(West Side\) | Bay St / Bloor St W | 7335 |
| Dovercourt Rd / Harrison St \(Green P\) - SMART | Dovercourt Rd / Harrison St - SMART | 7249 |
| Essex St / Christie St - SMART | Essex St / Christie St | 7151 |
| Fort York  Blvd / Capreol Ct | Fort York  Blvd / Capreol Crt | 7000 |
| Seaton St / Dundas St E - SMART | Seaton St / Dundas St E | 7109 |
| Simcoe St / Dundas St W - SMART | Simcoe St / Dundas St W | 7668 |
| Simcoe St / Wellington St North | Simcoe St / Wellington St W | 7334 |
| Simcoe St / Wellington St South | Simcoe St / Wellington St W | 7057 |
| Spadina Ave / Sussex Ave - SMART | Spadina Ave / Sussex Ave | 7667 |
| University Ave / College St \(East\) | University Ave / College St | 7502 |
| University Ave / College St \(West\) | University Ave / College St | 7062 |
| University Ave / Gerrard St W \(East Side\) | University Ave / Gerrard St W | 7047 |
| University Ave / Gerrard St W \(WEST\) - SMART | University Ave / Gerrard St W | 7634 |
| University Ave / King St W - SMART | University Ave / King St W | 7284 |

- Query was quick and dirty
- For some reason I was interested in exploring this particular slice of the data
- The pattern looked something like
- `[street name] [street type] / [street name] [street type]`
- This makes up about ~95000 rows
	- If there's a chance to save this data, why not?

## Semantic Similarities
It will be up to me to decide if there if there is semantic similarity based on the pattern that I employed below.

### East/West Stations at the Same Intersection
- My guess is that in 2017, was only one station at the intersection
- However, this might have changed based what the customers/stakeholders wanted
- There are 4 intersections that match this pattern
	- `bay st / bloor st w`
	- `simcoe st / wellington st`
	- `university ave / college`
	- `university ave / gerrard`
- All four either have east/west or north/south, stations, with their own station
- The issue is I have no way of telling which station ID the station should belong to
- However, generally speaking, I could maybe use either just so that I have geographical data, but this would be grossly in accurate
- I almost feel like leaving it as is would be appropriate so that I at least have some data that I could incorporate into other analysis

### `Fort York Blvd / Capreol Ct` and `Fort York Blvd / Capreol Crt`
- One character off, just enough throw off the way the match
- Makes me wonder if there's anything happening in the first street name...

### `- SMART` suffix
- Probably best for me to use `if bst_stations.name has 'SMART' in it then impute the corresponding station ID`
- This helps ensure that I don't touch the e/w, n/s stations, just being more restrictive so it's less likely that I knock something over
- 7 cases matching this pattern
- I imputed the new station names but I'm wondering if for consistency's sake I should also change the station name to prevent confusion... #TODO 
- There are more of those suffixes that fall outside of the range with the above query
- Might as well see what's going on with those stations

# Query
``` sql
select distinct on (name)  
       name,  
       start_station_name,  
       station_id  
from  
    (  
        select start_station_name  
        from trips_clean  
        where start_station_id is null) as t0  
        join bst_stations on split_part(start_station_name, ' ', 1) like split_part(bst_stations.name, ' ', 1) and  
                             split_part(start_station_name, ' ', 2) like split_part(bst_stations.name, ' ', 2) and  
                             split_part(start_station_name, ' ', 3) like split_part(bst_stations.name, ' ', 3) and  
                             split_part(start_station_name, ' ', 4) like split_part(bst_stations.name, ' ', 4) and  
                             split_part(start_station_name, ' ', 5) like split_part(bst_stations.name, ' ', 5);
```

Might be worth taking a look at the end station names as well.

---
## Wrapping Up
- Querying the original `trips` table, it looks like I had about a million null values in `start_station_id`
- At this point it's down to about 200k rows
- It's been a bit frustrating trying to work through the this subset of the data
- However, part of it is likely due to my lack of patient
- But I'm holding onto tpo a fair amount of the data.
- Just have about 200k rows to profile
| start\_station\_name                            | count | id_is_imputable | reason |
|:----------------------------------------------- |:----- |:--------------- |:------ |
| Adelaide St W / Bay St - SMART                  | 3159  | false           |        |
| Base Station                                    | 2     |                 |        |
| Bathurst St / Queens Quay W                     | 6942  |                 |        |
| Bay St / Bloor St W                             | 7166  |                 |        |
| Bay St / Davenport Rd                           | 1969  |                 |        |
| Beverly St / College St                         | 6646  |                 |        |
| Beverly  St / Dundas St W                       | 9029  |                 |        |
| Bloor GO / UP Station \(West Toronto Railpath\) | 1458  |                 |        |
| Bloor St / Brunswick Ave                        | 5514  |                 |        |
| Borden St / Bloor St W - SMART                  | 1425  |                 |        |
| Boston Ave / Queen St E                         | 2795  |                 |        |
| Bremner Blvd / Spadina Ave                      | 6243  |                 |        |
| Castle Frank Station                            | 1072  |                 |        |
| Dockside Dr / Queens Quay E \(Sugar Beach\)     | 8183  |                 |        |
| East Liberty St / Pirandello St                 | 6847  |                 |        |
| Fringe Next Stage - 7219                        | 36    |                 |        |
| Huron/ Harbord St                               | 4427  |                 |        |
| Lakeshore Blvd W / Ellis Ave                    | 1807  | true            | typo       |
| Lakeshore Blvd W / The Boulevard Club           | 2098  | true            |  typo      | 
| Lansdowne Subway Green P                        | 1834  |                 |        |
| Lower Jarvis St / The Esplanade                 | 5411  |                 |        |
| Margueretta St / College St                     | 1169  |                 |        |
| Marlborough Ave / Yonge St                      | 1296  |                 |        |
| Michael Sweet Ave / St. Patrick St              | 10786 |                 |        |
| Ontario Place Blvd / Remembrance Dr             | 10994 |                 |        |
| Parliament St / Aberdeen Ave                    | 3498  |                 |        |
| Parliament St / Bloor St E                      | 1251  |                 |        |
| Princess St / Adelaide St E                     | 11186 |                 |        |
| Queens Park / Bloor St W                        | 5285  |                 |        |
| Queen St E / Berkely St                         | 1970  |                 |        |
| Queen St E / Larchmount Ave                     | 1991  |                 |        |
| Queen St W / Portland St                        | 11221 |                 |        |
| Queen St W / York St \(City Hall\)              | 5753  |                 |        |
| Roxton Rd / College St                          | 2466  |                 |        |
| Scott St / The Esplanade                        | 6367  |                 |        |
| Simcoe St / Wellington St W                     | 14176 |                 |        |
| Stephenson Ave / Main St                        | 284   |                 |        |
| Stewart St / Bathurst St  - SMART               | 2424  |                 |        |
| Summerhill Ave / MacLennan Ave - SMART          | 201   |                 |        |
| University Ave / College St                     | 6038  |                 |        |
| Victoria St / Gould St \(Ryerson University\)   | 6364  |                 |        |
| Wellesley St E / Yonge St \(Green P\)           | 5853  |                 |        |
| Wellington St W / Portland St                   | 8242  |                 |        |
| Widmer St / Adelaide St W                       | 11422 |                 |        |
| Woodbine Subway Green P \(Cedarvale Ave\)       | 310   |                 |        |
| York St / King St W - SMART                     | 2423  |                 |        |

Representing 46 different stations. Something to consider is if there are any partial matches. In case stations were moved around in close vicinity of the original station.

This is about 1.25% of the dataset. I'll try my best to impute the values. If I can't I can always come back to it as feature update.

I could also brute force it because there are 46 stations, out of a possible 635. Quite easy throught scroll through. I'll do this for my next work session.

Some stations might not exist anymore, and some might have moved. In either case, I don't think I'll be able to impute any station IDs

It's definitely not ideal to brute force check. But don't mind checking it out maybe tomorrow as a shallow work activity.

Alright, things got pretty hacky. I ended up just running the station names through the bike share station locator

I kept track of which values I can impute
https://docs.google.com/spreadsheets/d/1K3efcCDfqiLW-bFebWn6ZY37Ixt9x6ZZyyda9Mh_Zm0/edit#gid=555467019

I'll need to work on the end station names tomorrow...
