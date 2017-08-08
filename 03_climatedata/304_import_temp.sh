#!/bin/bash 

for FILE in ./01_dwd_files/extract/*/produkt_tu_stunde_*.txt
do
	python ./304_import_temp.py $FILE
done