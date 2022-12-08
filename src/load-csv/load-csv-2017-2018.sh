#!/bin/bash

# Something weird is going on here. I can run the command from terminal but not out of this script...
# Looks like an issue with finding ./pgfutter directory...

# FILE=~/work/projects/bikeshare/data/raw/bikeshare_ridership_2017_Q1.csv
DBNAME=bikeshare
TABLENAME=raw_2017-2018
SCHEMA=public

cd ~
for FILE in ~/work/projects/bikeshare-to/data/raw/*201[7,8]*.csv;
do
echo "$FILE"
head -1 "$FILE" 
echo " "
done



