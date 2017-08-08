#!/bin/bash 

wget -P ./01_dwd_files/ ftp://ftp-cdc.dwd.de/pub/CDC/observations_germany/climate/hourly/air_temperature/recent/*

mkdir ./01_dwd_files/extract

for FILE in ./01_dwd_files/*.zip
do
	NEWDIR=./01_dwd_files/extract/${FILE:31:5}
	mkdir $NEWDIR
	unzip $FILE -d $NEWDIR
done