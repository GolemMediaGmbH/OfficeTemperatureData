# Show observations by type over time
library(RMySQL)
library(ggplot2)
library(scales)

source('dbconfig.R')

db <- dbConnect(MySQL(), user=USER, password=PASSWORD, dbname='bt')
rs <- dbSendQuery(db, "SELECT 
                        type,
                        COUNT(tid) AS ctid,
                        CONCAT(YEAR(dt), '-', LPAD(MONTH(dt),2,'0'), '-',LPAD(DAY(dt),2,'0')) AS Day
                      FROM ot 
                      WHERE f_ignore = 0
                      GROUP BY type, CONCAT(YEAR(dt), '-', LPAD(MONTH(dt),2,'0'), '-',LPAD(DAY(dt),2,'0'))
                      ORDER BY type, CONCAT(YEAR(dt), '-', LPAD(MONTH(dt),2,'0'), '-',LPAD(DAY(dt),2,'0'))")
data <- fetch(rs, n=-1)
dbClearResult(rs)

data$Day <- as.Date(data$Day)

dict <- data.frame(type = c("ard", "wifimcu", "sbc", "other"), name=c("Arduino", "Funkmodul", "Bastelrechner", "Andere"))
data$name <- with(dict, name[match(data$type, type)])

png("generated/425_type_over_time.png", width=1000, height=600)
ggplot(data=data, aes(x=Day, y=ctid,linetype=name, color=name)) + 
  geom_line() +
  ggtitle("Anzahl der Messstationen pro Tag und pro Gerätetyp")+
  scale_y_continuous(name="Anzahl",labels=format_format(big.mark=".", decimal.mark=",", scientific=FALSE)) +
  scale_x_date(name="Datum")+
  scale_linetype(name="Gerätetyp") +
  scale_color_hue(name ="Gerätetyp") +
  theme(axis.text=element_text(size=16))
dev.off()

