#!/bin/bash

source '../dbconfig.sh'

mysql $DBUSER bt < generated/205_fix_cities.sql
