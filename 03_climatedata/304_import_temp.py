# imports a single weather data file into db
# use 304_import_temp.sh for bulk import

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
		if 'STATIONS_ID' != row[0]:
			data.append({'id':row[0].strip(), 'dt' : row[1].strip(), 'temp':row[3].strip()})
		
db = mysql.connector.connect(user=dbconfig.user, password=dbconfig.password
							, host='localhost', database = 'bt')
cursor = db.cursor(buffered = True)

for e in data:
	if e['temp'] != '-999':
		sql = "INSERT INTO dwd_tempdata (station_id, dt, temp) VALUES ({}, STR_TO_DATE('{}','%Y%m%d%H'), ROUND({}*10))".format(e['id'], e['dt'],e['temp'])
	
	cursor.execute(sql);
	
cursor.close()
db.commit()
db.close()