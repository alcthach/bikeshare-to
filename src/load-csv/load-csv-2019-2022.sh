#!/bin/bash

# Something weird is going on here. I can run the command from terminal but not out of this script...
# Looks like an issue with finding ./pgfutter directory...
 

# FILE=~/work/projects/bikeshare/data/raw/bikeshare_ridership_2017_Q1.csv
DBNAME=bikeshare
TABLENAME=raw_2019_2022
SCHEMA=public
PATH=~/work/projects/bikeshare/data/processed/

cd ~

# for FILE in ~/work/projects/bikeshare/data/raw/*20[1,2][0,1,2,9]*.csv;
# for FILE in ~/work/projects/bikeshare/data/processed/*.csv;
# if FILE 
# do
# echo $FILE
# ./pgfutter --db $DBNAME --schema $SCHEMA --table $TABLENAME csv "$FILE";
# done

# Load 2019 files
for FILE in $PATH*2019*.csv;
do 
./pgfutter --db $DBNAME --schema $SCHEMA --table $TABLENAME csv "$FILE";
# echo "$FILE has been loaded successfully to $DBNAME.$TABLENAME"; 
done

# Load 2020-2022 files
for FILE in $PATH*202[0-2]*.csv;
do 
./pgfutter --db $DBNAME --schema $SCHEMA --table $TABLENAME csv "$FILE";
# echo "$FILE has been loaded successfully to $DBNAME.$TABLENAME"; 
done
