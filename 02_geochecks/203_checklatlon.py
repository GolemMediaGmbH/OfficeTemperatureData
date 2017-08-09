import mysql.connector
import ogr
import dbconfig

# inspired by
# https://stackoverflow.com/questions/7861196/check-if-a-geopoint-with-latitude-and-longitude-is-within-a-shapefile

db = mysql.connector.connect(user=dbconfig.user, password=dbconfig.password
							, host='localhost', database = 'bt')
cursor = db.cursor(buffered = True)

sql = ("SELECT lat, lon, country FROM ot WHERE "
	" country IS NOT NULL  AND lat IS NOT NULL AND lon IS NOT NULL "
	" GROUP BY lat, lon, country")

cursor.execute(sql)

data = []
for (lat,lon, country) in cursor:
	data.append({"lat":lat, "lon":lon, "country":country})

cursor.close()
db.close()

drv = ogr.GetDriverByName('ESRI Shapefile')
ds_in = drv.Open("shapes/gadm28_adm0.shp")
lyr_in = ds_in.GetLayer(0)

idx_reg = lyr_in.GetLayerDefn().GetFieldIndex("ISO2")

geo_ref = lyr_in.GetSpatialRef()
point_ref = ogr.osr.SpatialReference()
point_ref.ImportFromEPSG(4326)
ctran = ogr.osr.CoordinateTransformation(point_ref,geo_ref)

def checkGeoData(lat, lon, expected_iso):
#	[lon,lat,z]= ctran.TransformPoint(lon,lat)
	lyr_in.ResetReading()
	pt = ogr.Geometry(ogr.wkbPoint)
	pt.SetPoint_2D(0, float(lon), float(lat))
	lyr_in.SetSpatialFilter(pt)
	if 0 == lyr_in.GetFeatureCount():
		return False # location not found
	if 1 <= lyr_in.GetFeatureCount():
		feat_in = lyr_in.GetNextFeature()
		if expected_iso == feat_in.GetFieldAsString(idx_reg): # location found
			return True 										# and correctly noted
		else:
			return False										# not correctly noted

fixable = []
unfixable = []

for point in data:
	if checkGeoData(point['lat'], point['lon'], point['country']):
		print point # this point is ok
	else: # data could not be verified
		if checkGeoData(point['lon'], point['lat'], point['country']):
			# by switching the values, it can be verified
			fixable.append(point)
		else:
			# still not verified, need manual check
			unfixable.append(point)
		
fh = open('generated/204_fixlatlon_data.sql','wb')
for point in fixable:
	sql = ("UPDATE ot SET f_lat = {}, f_lon = {}, f_country = '{}' "
			"WHERE lat = {} AND lon = {} AND country = '{}';\n")
	fh.write(sql.format(point['lon'], point['lat'], point['country'],
			point['lat'], point['lon'], point['country']));
fh.close()

fh = open('generated/204_unfixed_latlon_data.csv','wb')
fh.write("lon, lat, country\n");
for point in unfixable:
	fh.write("{}, {}, {}\n".format(point['lon'],point['lat'],point['country']));
fh.close()