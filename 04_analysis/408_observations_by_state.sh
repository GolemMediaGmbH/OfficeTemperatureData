#!/bin/bash

source '../dbconfig.sh'

# secure_file_priv="" is required in your mysql my.cnf to make this work
# don't do this on a public server
CWD=$(pwd)

rm "$CWD/generated/408_observations_by_state.csv"
rm "$CWD/generated/408_observations_by_state_null.csv"

SQL="SELECT COUNT(tid) AS ctid, f_state FROM ot WHERE f_state IS NOT NULL AND f_country = 'DE' GROUP BY f_state ORDER BY COUNT(tid) DESC INTO OUTFILE '$CWD/generated/408_observations_by_state.csv' FIELDS TERMINATED BY ',' ENCLOSED BY '' LINES TERMINATED BY '\n'"

mysql $DBUSER -e "$SQL" bt 

SQL="SELECT COUNT(tid) AS ctid FROM ot WHERE f_state IS NULL AND f_country = 'DE' GROUP BY f_state ORDER BY COUNT(tid) DESC INTO OUTFILE '$CWD/generated/408_observations_by_state_null.csv' FIELDS TERMINATED BY ',' ENCLOSED BY '' LINES TERMINATED BY '\n'"

mysql $DBUSER -e "$SQL" bt 