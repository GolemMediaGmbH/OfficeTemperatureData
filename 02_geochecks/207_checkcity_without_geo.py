import mysql.connector
import ogr
import pycountry
import dbconfig

# find cities without geo information in db, and add geo info via ESRI

# because getting the data from db takes some time, we cache it in a file
# called 'cities_nogeo.p'

db = mysql.connector.connect(user=dbconfig.user, password=dbconfig.password
							, host='localhost', database = 'bt')

cursor = db.cursor(buffered = True)

sql = ("SELECT  f_city, f_country FROM ot WHERE f_lon IS NULL AND f_lat IS NULL AND f_city IS NOT NULL AND f_country IS NOT NULL GROUP BY f_lon, f_lat, f_city, f_country;")

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

def checkCity(layer, field, data):
	found = []
	failed = []
	for (city, country) in data:
		c3 = pycountry.countries.get(alpha_2=country).alpha_3
		f = False
		for feature in layer:
			cityname = feature.GetField(field)
			iso = feature.GetField('ISO')
			if (iso == c3 and cityname is not None and cityname.decode('utf-8') == city):
				geo = feature.GetGeometryRef().Centroid()
				found.append((city, country, geo)) 
				f = True
		layer.ResetReading()
		if not f:
			failed.append((city, country))

	return {'found':found,'notfound':failed}
	
# we test against different types of municipalities and districts
# orders matters, we want to go from smaller to bigger units
assigned = []
result = checkCity(lyr4_in, 'NAME_4', data)
assigned = assigned + result['found']
result = checkCity(lyr3_in, 'NAME_3', result['notfound'])
assigned = assigned + result['found']
result = checkCity(lyr2_in, 'NAME_2', result['notfound'])
assigned = assigned + result['found']

doublette = []
single = []
for obj in assigned:
	found = False
	for s in single:
		if obj[0] == s[0]:
			found = True
	if found:
		doublette.append(obj)
	else:
		single.append(obj)

for d in doublette:
	for s in single:
		if d[0] == s[0]:
			single.remove(s)
			doublette.append(s)


fh = open('generated/207_addlonlat.sql','wb')
for point in single:
	sql = ("UPDATE ot SET f_lat = {}, f_lon = {} "
			"WHERE f_country = '{}' AND f_city = '{}';\n")
	fh.write(sql.format(round(point[2].GetY(),5), round(point[2].GetX(),5), point[1], point[0].encode('utf-8')))
fh.close()

fh = open('generated/207_addlonlat_manual.sql','wb')
for point in doublette:
	sql = ("/* UPDATE ot SET f_lat = {}, f_lon = {} "
			"WHERE f_country = '{}' AND f_city = '{}';*/\n")
	fh.write(sql.format(round(point[2].GetY(),5), round(point[2].GetX(),5), point[1], point[0].encode('utf-8')))
fh.close()