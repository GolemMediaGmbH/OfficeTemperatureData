#!/bin/bash

source '../dbconfig.sh'

# import the database with the collected values
mysql $DBUSER bt < officetemp.sql 