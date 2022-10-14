#!/bin/bash

# Something weird is going on here. I can run the command from terminal but not out of this script...
# Looks like an issue with finding ./pgfutter directory...

# FILE=~/work/projects/bikeshare/data/raw/bikeshare_ridership_2017_Q1.csv
DBNAME=bikeshare
TABLENAME=raw_2017-2018
SCHEMA=public

cd ~
for FILE in ~/work/projects/bikeshare/data/raw/*201[7,8]*.csv;
do
./pgfutter --db $DBNAME --schema $SCHEMA --table $TABLENAME csv "$FILE";
done

echo "$FILE has been loaded successfully to $DBNAME." 


