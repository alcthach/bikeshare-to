# Bikeshare - Dev Log
[[2022-09-11]]

---

The main task for today is to standard the file names for all the csv files that I had. After that I'll see if I can automate the loading of the csvs to a SQL database

- There are 2 main patterns for file naming
- As mentioned the other day, after 2019, the data was released on a monthly basis
- Perhaps I can grep, or search for "Q" in the filename, this would indicate that the file is split into quarter rather than months
- Also, I might want to consider cleaning and processing the data in SQL rather than bash
- However, I think there is some value in standardizing the filenames, just for quality and verbosities sake
- Also nice to now how to do it

Maybe I should consider 2 filenames...
`bikeshare_ridership_quarterly_Q*_yyyy.csv`
and
`bikeshare_ridership_monthly_yyyy_mm`

Logic could look something like:

``` bash
for file in raw data
	if file name has the character "Q"
		base = "bikeshare_ridership_quarterly_"
		get the year and save to $year
		get the quarter and save to $quarter
		rename the file to "$base$year_quarter*.csv"
	else 
		base = "bikeshare_ridership_monthly_" 
		get the year and save to $year
		get the month and save to $month
		rename the file to "$base$year_$month.csv"
end for
```

As it currently stands, I have some files that are just yyyy-mm.csv, which is a bit troublesome if the files get displaced, it's not a very user-friendly filename either. 

Alright this is getting a bit tricky now
I could either delimit using "Q" and pull the number after it and store it to quarter...

53
￼
Here's how i'd do it:

FN=someletters_12345_moreleters.ext
[[ ${FN} =~ _([[:digit:]]{5})_ ]] && NUM=${BASH_REMATCH[1]}
Explanation:

Bash-specific:

[[ ]] indicates a conditional expression
=~ indicates the condition is a regular expression
&& chains the commands if the prior command was successful
Regular Expressions (RE): _([[:digit:]]{5})_

_ are literals to demarcate/anchor matching boundaries for the string being matched
() create a capture group
[[:digit:]] is a character class, i think it speaks for itself
{5} means exactly five of the prior character, class (as in this example), or group must match
In english, you can think of it behaving like this: the FN string is iterated character by character until we see an _ at which point the capture group is opened and we attempt to match five digits. If that matching is successful to this point, the capture group saves the five digits traversed. If the next character is an _, the condition is successful, the capture group is made available in BASH_REMATCH, and the next NUM= statement can execute. If any part of the matching fails, saved details are disposed of and character by character processing continues after the _. e.g. if FN where _1 _12 _123 _1234 _12345_, there would be four false starts before it found a match.

Share
Improve this answer
￼Follow
edited May 16, 2020 at 19:43
answered Jan 12, 2009 at 19:43

12:03

I did it! Printed out the correctly formatted filename for quarterly data

---

PM Session 

Used this to check the headers of all the files I have for the Bikeshare Toronto dataset
``` bash
for FILE in ./*.csv; do head -n 1 $FILE >> check_headers; done 
```

Similar pattern, but printed the file name so that I know which set of headers belongs to which file
``` bash
for FILE in ./*.csv; do echo "$FILE"; head -n 1 $FILE; done
```

Can I grab pricing data as well?

I'm facing a bit of a problem here...
- It would be alright if my columns were all in the right order across the different years 
- However, I don't have the same dimensions; number of fields between the years
- And the columns aren't order the same way
- I'll have to unblock myself here

Possible answer here: https://community.snowflake.com/s/question/0D50Z00008Lfc6WSAR/how-to-load-csv-files-with-inconsistent-columns-and-column-order

Better solution, create a procedure it seems...

There needs to be some sort of control flow. 

https://social.technet.microsoft.com/Forums/en-US/ac98a0f2-da13-4140-990d-969dbcd0ff40/import-csv-files-with-same-columns-in-variable-order?forum=winserverpowershell

The logic might be something like:
For each csv, reference the headers then rearrange the headers on a temp table to match the main table
Write the data to the main table.
This sort of makes sense. 
The main thing is that there needs to be some sort of column mapping to ensure that I don't get data living in the wrong column

https://stackoverflow.com/questions/21290808/importing-to-sql-from-csv-in-changing-order-of-columns

https://stackoverflow.com/questions/63582818/bulk-insert-with-dynamic-mapping-in-sql-server
