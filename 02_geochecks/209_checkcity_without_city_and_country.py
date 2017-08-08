import mysql.connector
import ogr
import pycountry
import decimal
import dbconfig

# find data points without  information in db, and add geo info via ESRI

# because getting the data from db takes some time, we cache it in a file
# called 'cities_nogeo.p'


db = mysql.connector.connect(user=dbconfig.user, password=dbconfig.password
							, host='localhost', database = 'bt')

cursor = db.cursor(buffered = True)

sql = ("SELECT  f_lat, f_lon FROM ot WHERE f_city IS NULL AND f_country IS NULL AND f_ignore = 0 AND f_lon IS NOT NULL AND f_lat IS NOT NULL GROUP BY f_lat, f_lon, f_country, f_city")

cursor.execute(sql)
result = cursor.fetchall()
data = [row for row in result]

cursor.close()
db.close()
	
drv = ogr.GetDriverByName('ESRI Shapefile')
ds2_in = drv.Open("shapes/gadm28_adm2.shp")
lyr2_in = ds2_in.GetLayer(0)
ds3_in = drv.Open("shapes/gadm28_adm3.shp")
lyr3_in = ds3_in.GetLayer(0)
ds4_in = drv.Open("shapes/gadm28_adm4.shp")
lyr4_in = ds4_in.GetLayer(0)

def checkGeoData(lyr_in, cityfield, lat, lon ):
	lyr_in.ResetReading()
	pt = ogr.Geometry(ogr.wkbPoint)
	pt.SetPoint_2D(0, float(lon), float(lat))
	lyr_in.SetSpatialFilter(pt)
	if 0 == lyr_in.GetFeatureCount():
		return False # location not found
	if 1 <= lyr_in.GetFeatureCount():
		feature = lyr_in.GetNextFeature()
		iso = feature.GetField('ISO')
		cityname = feature.GetField(cityfield)
		return {'lat': lat, 'lon': lon, 'iso':pycountry.countries.get(alpha_3=iso).alpha_2, 'city':cityname}

found = []
missing = []

for point in data:
	result = checkGeoData(lyr4_in, 'NAME_4', point[0], point[1])
	if False != result:
		found.append(result);
	else:
		missing.append(point)

for point in missing:
	result = checkGeoData(lyr3_in, 'NAME_3', point[0], point[1])
	if False != result:
		found.append(result);
	else:
		missing.append(point)

for point in missing:
	result = checkGeoData(lyr2_in, 'NAME_2', point[0], point[1])
	if False != result:
		found.append(result);
	else:
		missing.append(point)

fh = open('generated/209_addlonlat.sql','wb')
for point in found:
	sql = ("UPDATE ot SET f_country = '{}', f_city = '{}' "
			"WHERE f_lat = {} AND f_lon = {};\n")
	fh.write(sql.format(point['iso'], point['city'], point['lat'], point['lon']))
fh.close()

fh = open('generated/209_addlatlon_missing.csv','wb')
fh.write("lat, lon\n");
for point in missing:
	fh.write("{}, {}\n".format(point['lat'],point['lon']))
fh.close()