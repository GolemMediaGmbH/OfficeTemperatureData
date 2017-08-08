#!/bin/bash

source '../dbconfig.sh'

mysql $DBUSER bt < 207_addlonlat.sql
mysql $DBUSER bt < 207_addlonlat_manual.sql