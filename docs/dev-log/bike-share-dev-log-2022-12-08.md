[[2022-12-08]]

---

12:14

# Data Profiling - 2017 Q1 and Q2

Hmmm it might make more sense for me to batch load *all* of the data for now. And perform a shallow profiling of the data to ensure that I have an idea of what I'm working with.

So I'll go ahead and load 2019 to present data as well...

## Just checking to see if the headers of 2019 to present data shifts

``` BASH
head -1 bike-share-toronto-ridership-2022*.csv
```

I'm missing 2019-2021 data...

Downloading and loading that now...

- Ran `head -1 bike-share-toronto-ridership-2022*.csv` again on all the files from 2017
- Found that from 2019 onwards the columns are identical

So there are three slices of data
- 2017 Q1 and Q2, and 2018 
- 2017 Q3 and Q4
- 2019 to present

This means that I could profile, clean and load to the destination table by these three slices. 

- 4 slices could also work as well
- Giving 2018 their own slice
- So instead, 
	- 2017 Q1 Q2
	- 2017 Q3 Q4
	- 2018
	- 2019 - Present

---

## Distilled Version:

- Loaded the raw data onto the database
- Some of the loading scripts can use a refactor afterwards
- 
