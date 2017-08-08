import mysql.connector
import ogr
import dbconfig

# check cities in db, via ESRI

db = mysql.connector.connect(user=dbconfig.user, password=dbconfig.password
						, host='localhost', database = 'bt')

cursor = db.cursor(buffered = True)

sql = ("SELECT DISTINCT(city) AS c FROM ot WHERE city IS NOT NULL")

cursor.execute(sql)
result = cursor.fetchall()
data = [row[0] for row in result]

cursor.close()
db.close()
	
drv = ogr.GetDriverByName('ESRI Shapefile')
ds2_in = drv.Open("shapes/gadm28_adm2.shp")
lyr2_in = ds2_in.GetLayer(0)
ds3_in = drv.Open("shapes/gadm28_adm3.shp")
lyr3_in = ds3_in.GetLayer(0)
ds4_in = drv.Open("shapes/gadm28_adm4.shp")
lyr4_in = ds4_in.GetLayer(0)

def checkCities(layer, field, data):
	cities = []
	result = []
	for feature in layer:
		cityname = feature.GetField(field)
		if cityname is not None:
			cities.append(cityname.decode('utf-8'))
	layer.ResetReading()
	for c in data:
		# we have some trouble with citynames encode in utf8 by users
		try: 
			c8 = c.encode('raw_unicode_escape').decode('utf-8') 
		except UnicodeDecodeError:
			c8 = c.encode('raw_unicode_escape')
			c8 = c8.decode('latin_1')
		if c8 not in cities:
			result.append(c8)
	return result

# we test against different types of municipalities and districts
rdata = checkCities(lyr2_in, 'NAME_1', data)
rdata = checkCities(lyr2_in, 'NAME_2', rdata)
rdata = checkCities(lyr3_in, 'NAME_1', rdata)
rdata = checkCities(lyr3_in, 'NAME_2', rdata)
rdata = checkCities(lyr3_in, 'NAME_3', rdata)
rdata = checkCities(lyr4_in, 'NAME_1', rdata)
rdata = checkCities(lyr4_in, 'NAME_2', rdata)
rdata = checkCities(lyr4_in, 'NAME_3', rdata)
rdata = checkCities(lyr4_in, 'NAME_4', rdata)

for city in rdata:
	print city.encode('utf-8');

