# Generate a KML file with the observers

import mysql.connector
import dbconfig

db = mysql.connector.connect(user=dbconfig.user, password=dbconfig.password
							, host='localhost', database = 'bt')
cursor = db.cursor(buffered = True)

sql = "SELECT f_lat, f_lon FROM ot WHERE f_lat IS NOT NULL AND f_lon IS NOT NULL AND f_ignore = 0 GROUP BY f_lat, f_lon"

cursor.execute(sql)

file_start = """<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<kml xmlns=\"http://www.opengis.net/kml/2.2\">
<Document>
"""

file_end = """</Document>
</kml>"""

with open("generated/kml/stations.kml", 'wb') as file:
	file.write(file_start)
	for lat, lon in cursor:
		file.write(("<Placemark><Point>"
					"<coordinates>"
					+str(lon)+
					","
					+str(lat)+
					",0</coordinates>"
					"</Point></Placemark>\n"))
	file.write(file_end)
