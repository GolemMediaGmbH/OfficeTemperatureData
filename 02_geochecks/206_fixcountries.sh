#!/bin/bash

source '../dbconfig.sh'

mysql $DBUSER bt < 206_fix_countries.sql
mysql $DBUSER bt < 206_fix_countries_manual.sql