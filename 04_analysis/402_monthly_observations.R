# Observations per Month
library(RMySQL)
library(ggplot2)
library(scales)

source('dbconfig.R')

db <- dbConnect(MySQL(), user=USER, password=PASSWORD, dbname='bt')
rs <- dbSendQuery(db, "SELECT COUNT(tid) AS ctid, CONCAT(YEAR(dt), '-', LPAD(MONTH(dt),2,'0')) AS Monat
                 FROM ot WHERE f_ignore = 0 
                  GROUP BY CONCAT(YEAR(dt), '-', LPAD(MONTH(dt),2,'0')) 
                  ORDER BY CONCAT(YEAR(dt), '-', LPAD(MONTH(dt),2,'0'))")
data <- fetch(rs, n=-1)
dbClearResult(rs)

data$Monat<-as.factor(data$Monat)

png("generated/402_montly_observations.png", width=1000, height=600)
ggplot(data=data, aes(x=Monat,y=ctid)) +
  geom_bar(stat="identity", fill="#56B4E9") +
  ggtitle("Messwerte pro Monat")+
  scale_y_continuous(name="Anzahl",labels=format_format(big.mark=".", decimal.mark=",", scientific=FALSE)) +
  theme(axis.text=element_text(size=16))
dev.off()
