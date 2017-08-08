#!/bin/bash

source '../dbconfig.sh'

# secure_file_priv="" is required in your mysql my.cnf to make this work
# don't do this on a public server
CWD=$(pwd)

rm "$CWD/generated/407_observations_by_country.csv"
rm "$CWD/generated/407_observations_by_country_null.csv"

SQL="SELECT COUNT(tid) AS ctid, f_country FROM ot WHERE f_country IS NOT NULL GROUP BY f_country ORDER BY COUNT(tid) DESC INTO OUTFILE '$CWD/generated/407_observations_by_country.csv' FIELDS TERMINATED BY ',' ENCLOSED BY '' LINES TERMINATED BY '\n'"
mysql $DBUSER -e "$SQL" bt 

SQL="SELECT COUNT(tid) AS ctid FROM ot WHERE f_country IS NULL GROUP BY f_country ORDER BY COUNT(tid) DESC INTO OUTFILE '$CWD/generated/407_observations_by_country_null.csv' FIELDS TERMINATED BY ',' ENCLOSED BY '' LINES TERMINATED BY '\n'"
mysql $DBUSER -e "$SQL" bt 