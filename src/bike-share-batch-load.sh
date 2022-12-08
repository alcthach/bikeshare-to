#!/bin/bash

# Load 2017 Q1 and Q2
echo 'Loading 2017 Q1 and Q2 data.'
cat bike-share-toronto-ridership-2017_Q[1,2].csv | psql -d bike_share_toronto -c '\copy raw_2017_q1q2 FROM stdin CSV HEADER'
echo $?

# Load 2017 Q3 and Q4
echo 'Loading 2017 Q3 and Q4 data.'
cat bike-share-toronto-ridership-2017_Q[3,4].csv | psql -d bike_share_toronto -c '\copy raw_2017_q3q4 FROM stdin CSV HEADER'
echo $?

# Load 2018 
echo 'Loading 2018 data.'
cat bike-share-toronto-ridership-2018*.csv | psql -d bike_share_toronto -c '\copy raw_2018 FROM stdin CSV HEADER'
echo $?

# Load 2019 
echo 'Loading 2019 data.'
cat bike-share-toronto-ridership-2019*.csv | psql -d bike_share_toronto -c '\copy raw_2019_present FROM stdin CSV HEADER'
echo $?


# Load 2020 to present
echo 'Loading 2020 to present data.' 
cat bike-share-toronto-ridership-2022*.csv | psql -d bike_share_toronto -c '\copy raw_2019_present FROM stdin CSV HEADER'
echo $?
