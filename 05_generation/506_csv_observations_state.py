# Create CSV file of observations per state in germany for d3 javascript library 

import mysql.connector
import dbconfig

db = mysql.connector.connect(user=dbconfig.user, password=dbconfig.password
							, host='localhost', database = 'bt')
cursor = db.cursor(buffered = True)

sql = ("SELECT COUNT(tid) AS ctid, " 
		" f_state, "
		" CONCAT(YEAR(dt), '-', LPAD(MONTH(dt),2,'0'), '-',LPAD(DAY(dt),2,'0')) AS date "
		" FROM ot "
		" WHERE f_ignore = 0 AND f_country = 'DE' AND f_state IS NOT NULL "
		" GROUP BY "
		" f_state, "
		" CONCAT(YEAR(dt), '-', LPAD(MONTH(dt),2,'0'), '-',LPAD(DAY(dt),2,'0'))"
		" ORDER BY date, f_state ASC")

cursor.execute(sql)

states = []
dates ={}
for (ctid,f_state,date) in cursor:
	if date not in dates:
		dates[date] = {}
	dates[date][f_state] = str(ctid)
	if f_state not in states:
		states.append(f_state)

cursor.close()
db.close()

lines = []

for key_date in sorted(dates):
	date = dates[key_date]
	line = [key_date]
	for state in states:
		if state in date:
			line.append(date[state])
		else:
			line.append("")
	lines.append(line)
	
fh = open('generated/d3-csv/observations-state.csv','wb')
fh.write("date,"+",".join(states)+"\n");
for line in lines:
	fh.write(','.join(line) + "\n");
fh.close()