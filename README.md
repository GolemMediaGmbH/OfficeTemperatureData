# OfficeTemperatureData
Raw data and processing code for analysis

For more information visit
https://www.golem.de/specials/mitmachprojekt-buero/ and
https://github.com/GolemMediaGmbH/OfficeTemperature
(in german)

## Explanation of directories

### 01_rohsql

Scripts in this directory must be called in order of the prefix number.
The SQL dump will be imported and we will create a copy. Additional columns will be added.

The dump can be found here
https://golem.de/projekte/ot/officetemp.zip

The dump will be downloaded by ```00_download.sh```

### 02_geochecks

Scripts in this directory should be called according to the prefix number. Re-runs in arbitrary order are recommended. The scripts validates geolocation information and helps you to fill in missing values. 

At start, ESRI geo database files will be downloaded.

Some scripts generate SQL and CSV files. Data in CSV files need to be processed manually.
Some generated SQL scripts might contain commented SQL statements in case of ambiguous results. You need to check the statements and resolve the ambiguities. 

The automatically and manually generated SQL files must be executed after their generation, not in batch at once.

```00_manual_fixes.sql``` contains additional SQL statements to fix geo location information. I also used it to store SQL statements created from CSV files. It is recommended to run this file several times between the other SQL scripts

### 03_climatedata

Scripts in this directory must be called in order of the prefix number.
The scripts download and import the weather data from the Deutschen Wetter Dienst (DWD).
Then the data is assigned to the values in the office temperature table.

Caution: The assignment will run several hours or even days depending on your hardware and MySQL settings. 

### 04_analysis

Except for the first two SQL scripts, the R scripts to generate statistics and charts can be called in any order.

### 05_generation

Scripts to generate several data files used for interactive graphics:
http://www.golem.de/projekte/ot/charts_final.php

## Settings and Requirements

### Software

- MySQL with Spatial Extension
- R
- Python
- Bash shell is recommended

You need to set the database credentials (username and password) in the various dbconfig files.

### Harddisk usage

Make sure you have at least 25 GByte free harddisk space.

### Recommended settings for MySQL

Requires at least 16 GByte RAM.

```
[mysqld]
general-log=0
innodb-buffer-pool-size=858993452
innodb-change-buffer-max-size=50
innodb-max-dirty-pages-pct=90
innodb-flush-log-at-trx-commit=0
max-heap-table-size=10737421824
secure_file_priv=
```