# Create CSV file of avg temperatures per country for d3 javascript library 

import mysql.connector
import dbconfig

db = mysql.connector.connect(user=dbconfig.user, password=dbconfig.password
							, host='localhost', database = 'bt')
cursor = db.cursor(buffered = True)

sql = ("SELECT AVG(r_temp)/10 AS temp, " 
		" f_country, "
		" CONCAT(YEAR(dt), '-', LPAD(MONTH(dt),2,'0'), '-',LPAD(DAY(dt),2,'0')) AS date "
		" FROM ot "
		" WHERE f_ignore = 0 AND f_country IS NOT NULL "
		" GROUP BY "
		" f_country, "
		" CONCAT(YEAR(dt), '-', LPAD(MONTH(dt),2,'0'), '-',LPAD(DAY(dt),2,'0'))"
		" ORDER BY date, f_country ASC")

cursor.execute(sql)

countries = []
dates ={}
for (temp,f_country,date) in cursor:
	if date not in dates:
		dates[date] = {}
	dates[date][f_country] = str(temp)
	if f_country not in countries:
		countries.append(f_country)

cursor.close()
db.close()

lines = []

for key_date in sorted(dates):
	date = dates[key_date]
	line = [key_date]
	for country in countries:
		if country in date:
			line.append(date[country])
		else:
			line.append("")
	lines.append(line)
	
fh = open('generated/d3-csv/avg-temp-country.csv','wb')
fh.write("date,"+",".join(countries)+"\n");
for line in lines:
	fh.write(','.join(line) + "\n");
fh.close()