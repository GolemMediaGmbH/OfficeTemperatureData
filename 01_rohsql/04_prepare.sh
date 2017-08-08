#!/bin/bash

source '../dbconfig.sh'

# add additional columns in ot to clean data an make processing easier
# - r_temp -> temperature as integer value rounded to one decimal, divide by 10 to get float value
# - dt -> datetime of value as Mysql datetime value
mysql $DBUSER bt < 04_prepare.sql 