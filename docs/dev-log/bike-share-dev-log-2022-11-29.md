[[2022-11-29]]

---

11:19


This method of loading the data seems better in terms of debugging. The pgfutter tool, although quite useful poses an issue when there are errors. It's not robust in terms of automating the process. What I might do instead is just load the load data manually for the 2017-2018 data. Then find a find to manage data from 2019 to present. 

SLICKKK 🙌

``` BASH
cat /tmp/raw/bike-share-toronto-ridership-2018*.csv | psql -d bike_share_toronto -c '\copy raw_2018_trips FROM stdin CSV HEADER'
```

This is basically what pgfutter helped to accomplished. Just harnessing the power of linux and psql

cat 

	Cat(concatenate) command is very frequently used in Linux. It reads data from the file and gives their content as output. It helps us to create, view, concatenate files. So let us see some frequently used cat commands. 

stdin

	Short for standard input, stdin is an input stream where data is sent to and read by a program. It is a file descriptor in Unix-like operating systems, and programming languages, such as C, Perl, and Java. Below, is an example of how STDIN could be used in Perl.

In plain english, 

```
read each csv file from 2018 | this is a psql command, connect to bike_share_toronto database, run this command: copy from the cat output treat this as a csv file Re: comma delimiter, assume the first row is the headers
```

I would assume that the command iterates through each file. Otherwise it wouldn't know how to deal with the headers.

That is actually a super helpful pattern that I'm likely to use for the other data from 2019 to present. So elegant. Does not need python or anything else. Just Bash and psql! 😄

🔴 TODO: Refactor these commands into a bash script with confirmation messages