# Bike Share Dev Log
[[2022-09-29]]

---
12:19

I've prototyped the transformations to ensure that all my start time data is in the correct format. I'll need to understand the steps that I've taken and also perform the transformations to `trip_end_time` as well. I should take some time to explore that column to ensure nothing strange is going on there... I.E. If it follows the same pattern as `trip_start_time` I should be okay. I'll just apply the same transformations as I did for `trip_start_time`. 

## Going through my order of operations. 
- I re-initialized my `temp_table` with 2017 and 2018 trip data
- I've realized that the only to cross-compare is to blow up the `trip_start_time` column