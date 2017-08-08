import mysql.connector
import ogr
import pycountry
import dbconfig

# find cities without country information in db, and add geo info via ESRI
# creates 26_fix_countries.sql
# with update statements for solved countries
# 26_fix_countries_manual.sql
# with commented update statements that need to be checked
# 26_fix_countries_unknow.cvs
# list of cities with unknown country

# because getting the data from db takes some time, we cache it in a file
# called 'cities_nocountry.p'

db = mysql.connector.connect(user=dbconfig.user, password=dbconfig.password
							, host='localhost', database = 'bt')

cursor = db.cursor(buffered = True)

sql = ("SELECT f_city,f_country FROM ot WHERE lat IS NULL AND lon IS NULL AND f_ignore = 0 AND f_city IS NOT NULL AND f_country IS NULL GROUP BY f_city, f_country;")

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

def checkCity(layer, field, data):
	lfound = []
	lnotfound = []
	for city in data:
		found = False
		for feature in layer:
			cityname = feature.GetField(field)
			if (cityname is not None and cityname.decode('utf-8') == city):
				found = True
				country = feature.GetField('ISO')
				lfound.append((city, pycountry.countries.get(alpha_3=country).alpha_2))
		if not found:
			lnotfound.append(city)
		layer.ResetReading()
	return {'found':lfound, 'notfound':lnotfound}

print "Number of cities found: {}".format(len(data))

# we test against different types of municipalities and districts
result_lyr4 = checkCity(lyr4_in, 'NAME_4', data)
result_lyr3 = checkCity(lyr3_in, 'NAME_3', data)

found = []
for tc in result_lyr4['found']:
	if tc not in found:
		found.append(tc)
for tc in result_lyr3['found']:
	if tc not in found:
		found.append(tc)

missing = result_lyr4['notfound'] + result_lyr3['notfound']

for (city, iso) in found:
	if city in missing:
		missing.remove(city)

doublette = []
single = []

for (city1, iso1) in found:
	for (city2, iso2) in found:
		if iso1 != iso2 and city1 == city2:
			doublette.append(((city1, iso1),(city2, iso2)))

for t in found:
	f = False
	for (t1, t2) in doublette:
		if t == t1 or t == t2:
			f = True
	if not f:
		single.append(t)
	

fh = open('generated/206_fix_countries.sql','wb')
for point in single:
	sql = ("UPDATE ot SET f_country = '{}' "
			"WHERE f_country IS NULL AND f_city = '{}';\n")
	fh.write(sql.format(point[1], point[0].encode('utf-8')))
fh.close()

fh = open('generated/206_fix_countries_manual.sql','wb')
for (point1, point2) in doublette:
	sql = ("/* UPDATE ot SET f_country = '{}' "
			"WHERE f_country IS NULL AND f_city = '{}'; */\n")
	fh.write(sql.format(point1[1], point1[0].encode('utf-8')))
	sql = ("/* UPDATE ot SET f_country = '{}' "
			"WHERE f_country IS NULL AND f_city = '{}'; */\n\n")
	fh.write(sql.format(point2[1], point2[0].encode('utf-8')))
fh.close()

fh = open('generated/206_fix_countries_unknow.csv','wb')
fh.write('city\n')
for city in missing:
	fh.write("{}\n".format(city.encode('utf-8')));
fh.close()
