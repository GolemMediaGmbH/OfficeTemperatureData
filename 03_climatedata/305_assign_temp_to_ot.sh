#!/bin/bash 

source '../dbconfig.sh'

mysql $DBUSER bt < 305_1_calculate_distances.sql
mysql $DBUSER bt < 305_2_assign_dwd_temp.sql