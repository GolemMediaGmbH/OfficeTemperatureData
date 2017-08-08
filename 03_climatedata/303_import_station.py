# imports a single station data file into db
# use 303_import_station.sh for bulk import

import csv
import mysql.connector
import sys
import dbconfig

filename = sys.argv[1]
print "Reading ", filename

data = []

with open(filename, 'rb') as csvfile:
	reader = csv.reader(csvfile, delimiter=';')
	for row in reader:
		if 'Stations_id' != row[0]:
			data.append({'id':row[0].strip(), 'lat' : row[2].strip(), 'lon':row[3].strip(),'dt_start':row[4].strip(), 'dt_end':row[5].strip()})
		
db = mysql.connector.connect(user=dbconfig.user, password=dbconfig.password
							, host='localhost', database = 'bt')
cursor = db.cursor(buffered = True)

for e in data:
	if '' != e['dt_end']:
		sql = "INSERT INTO dwd_station (station_id, lat, lon, dt_start, dt_end) VALUES ({}, {},{},STR_TO_DATE('{}','%Y%m%d'),STR_TO_DATE('{}','%Y%m%d'))".format(e['id'], e['lat'], e['lon'],e['dt_start'],e['dt_end'])
	else: 
		sql = "INSERT INTO dwd_station (station_id, lat, lon, dt_start) VALUES ({}, {},{},STR_TO_DATE('{}','%Y%m%d'))".format(e['id'], e['lat'], e['lon'],e['dt_start'])
	
	cursor.execute(sql);
	
cursor.close()
db.commit()
db.close()