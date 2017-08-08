#!/bin/bash 

for FILE in ./01_dwd_files/extract/*/Metadaten_Geographie_*.txt
do
	python ./303_import_station.py $FILE
done