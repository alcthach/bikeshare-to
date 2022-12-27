-- Checking to see if I have the correct number of rows in the destination table

select sum(row_count)
from (select count(*) as row_count
      from raw_2017_q1q2
      union
      select count(*) as row_count
      from raw_2017_q3q4
      union
      select count(*) as row_count
      from raw_2018
      union
      select count(*) as row_count
      from raw_2019_2020
      union
      select count(*) as row_count
      from raw_feb_apr_2021
      union
      select count(*) as row_count
      from raw_jan_2021
      union
      select count(*) as row_count
      from raw_jun_2021_present
      union
      select count(*) as row_count
      from raw_may_2021) as table_row_counts

-- Total rows in 'trips'
SELECT count(*)
from trips;

-- Looks good! :thumbsup343