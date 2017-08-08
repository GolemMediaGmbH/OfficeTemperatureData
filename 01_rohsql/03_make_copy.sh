#!/bin/bash

source '../dbconfig.sh'

# creates the table ot we want to deal with
mysql $DBUSER bt < 03_make_copy.sql 