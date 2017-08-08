import mysql.connector
import ogr
import re
import dbconfig

# find the state for all locations in DE

# because getting the data from db takes some time, we cache it in a file
# called 'cities.p'

db = mysql.connector.connect(user=dbconfig.user, password=dbconfig.password
							, host='localhost', database = 'bt')

cursor = db.cursor(buffered = True)

sql = ("SELECT f_lat, f_lon FROM ot WHERE f_lat IS NOT NULL AND f_lon IS NOT NULL AND f_country = 'DE' AND f_ignore = 0 GROUP BY f_lat, f_lon")

cursor.execute(sql)
result = cursor.fetchall()
data = [row for row in result]

cursor.close()
db.close()
	
drv = ogr.GetDriverByName('ESRI Shapefile')
ds1_in = drv.Open("shapes/gadm28_adm1.shp")
lyr1_in = ds1_in.GetLayer(0)

def checkGeoData(lyr_in, lat, lon ):
	lyr_in.ResetReading()
	pt = ogr.Geometry(ogr.wkbPoint)
	pt.SetPoint_2D(0, float(lon), float(lat))
	lyr_in.SetSpatialFilter(pt)
	if 0 == lyr_in.GetFeatureCount():
		return False # location not found
	if 1 <= lyr_in.GetFeatureCount():
		feature = lyr_in.GetNextFeature()
		state = feature.GetField('HASC_1') # Name of the state as abbreviation

		return {'lat': lat, 'lon': lon, 'iso':'DE', 'state':re.sub('.+\.', '', state)}

found = []
missing = []

for point in data:
	result = checkGeoData(lyr1_in, point[0], point[1])
	if False != result:
		found.append(result);
	else:
		missing.append(point)

fh = open('generated/210_addstateDE.sql','wb')
for point in found:
	sql = ("UPDATE ot SET f_state = '{}' "
			"WHERE f_lat = {} AND f_lon = {};\n")
	fh.write(sql.format(point['state'], point['lat'], point['lon']))
fh.close()

fh = open('generated/210_addstateDE_missing.csv','wb')
fh.write("lat, lon\n");
for point in missing:
	fh.write("{}, {}\n".format(point[0],point[1]))
fh.close()