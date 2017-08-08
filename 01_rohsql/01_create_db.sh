#!/bin/bash

source '../dbconfig.sh'

# create the database
mysql $DBUSER < 01_create_db.sql 
