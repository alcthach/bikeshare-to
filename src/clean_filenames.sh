!#/bin/bash

# TODO Review code and translate into pseudocode

BASE_FILENAME="bikeshare_ridership_"

# Standardize filename
for FILE in ~/work/projects/bikeshare/data/raw/*.csv; do
	if [[ "$FILE" == *"Q"* ]]; then
		[[ ${FILE} =~ Q([[:digit:]]{1}). ]] && QUARTER=${BASH_REMATCH[1]}	
		[[ ${FILE} =~ .([[:digit:]]{4}). ]] && YEAR=${BASH_REMATCH[1]}	
		mv "$FILE" ~/work/projects/bikeshare/data/raw/"$BASE_FILENAME$YEAR"_Q"$QUARTER.csv"
	#elif [[ "FILE" =~ .[[:digit:]]{4}-[[:digit:]]{2} ]]; then	
else
		[[ "$FILE" =~ -([[:digit:]]{2}). ]] && MONTH=${BASH_REMATCH[1]}
		[[ "$FILE" =~ .([[:digit:]]{4})- ]] && YEAR=${BASH_REMATCH[1]}
		mv "$FILE" ~/work/projects/bikeshare/data/raw/"$BASE_FILENAME$YEAR"-"$MONTH.csv"
	fi
done


# Standardize to monthly rather than quartly for easier programmatic loading?

# Take a look at the clean BSTN Bixi dataset
