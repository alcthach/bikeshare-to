[[2023-01-26]]

---

10:26

# Wrapping Up
Things are moving, slow but steady. Next session I'll work in loading the csv file to my database. Hoping to impute the missing values shortly after.

So the plan for today is to load the csv stations file to the sql database.

I'll need to re-initialize the `stations` table with the correct headers.

14:11

Just a quick update. I re-initialized a new `bst-stations` table. And loaded all the records to the this table. In total, 653 stations were loaded to the database.  

I'm going to take some time to profile the columns I need. Re: The ones needed to impute the missing station data in `trips`. Although, I'm not too sure if this actually needed. It might help for me to take a look at Kimball's text to see if the data should just live elsewhere.

#todo Review Kimball for when it's time to model the data.

obsidian://open?vault=athach&file=work%2Fprojects%2Fbikeshare-to%2Fdocs%2Fbike-share-toronto-data-profiling-2022-12-29

Almost ready to impute my missing values. Luckily, I'm not missing any station ids. Makes my work a bit easier. I could just focus trying to impute the missing station names. However, I'm not entirely how this would benefit me. But I'll go with it for now since I almost have a complete data set.

Below might be a useful reference to help with the imputation problem.

https://stackoverflow.com/questions/31587707/sql-to-copy-missing-data-from-one-table-to-another
