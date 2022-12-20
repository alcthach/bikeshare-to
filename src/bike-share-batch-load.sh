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
cat bike-share-toronto-ridership-2019*.csv | psql -d bike_share_toronto -c '\copy raw_2019_2020 FROM stdin CSV HEADER'
echo $?

# Load 2020
echo 'Loading 2020 data' 
cat bike-share-toronto-ridership-2020-0*.csv | psql -d bike_share_toronto -c '\copy raw_2019_2020 FROM stdin CSV HEADER'
echo $?

# Load Jan 2021
echo 'Loading Jan 2021 data.'
cat bike-share-toronto-ridership-2021-01.csv | psql -d bike_share_toronto -c '\copy raw_jan_2021 FROM stdin CSV HEADER'
echo $?

# Load Feb-Apr 2021
echo 'Loading Feb-Apr 2021 data.'
cat bike-share-toronto-ridership-2021-0[2-4].csv | psql -d bike_share_toronto -c '\copy raw_feb_apr_2021 FROM stdin CSV HEADER'
echo $?


# Load May 2021
echo 'Loading May 2021 data.' 
cat bike-share-toronto-ridership-2021-05.csv | psql -d bike_share_toronto -c '\copy raw_may_2021 FROM stdin CSV HEADER'
echo $?

# Load Jun-Sept 2021 
echo 'Loading Jun-Sept 2021 data'
cat bike-share-toronto-ridership-2021-0[6-9].csv | psql -d bike_share_toronto -c '\copy raw_jun_2021_present FROM stdin CSV HEADER'
echo $?

# Load Oct-Dec 2O21 Data
echo 'Loading Oct-Dec 2021 data'
cat bike-share-toronto-ridership-2021-1*.csv | psql -d bike_share_toronto -c '\copy raw_jun_2021_present FROM stdin CSV HEADER'
echo $?

# Load 2022 Data
echo 'Loading 2022 data'
cat bike-share-toronto-ridership-2022*.csv | psql -d bike_share_toronto -c '\copy raw_jun_2021_present FROM stdin CSV HEADER'
echo $?
