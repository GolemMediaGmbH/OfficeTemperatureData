# Compare the average values in germany with DWD values per day

library(RMySQL)
library(ggplot2)
library(scales)
library(reshape2)

source('dbconfig.R')

db <- dbConnect(MySQL(), user=USER, password=PASSWORD, dbname='bt')
rs <- dbSendQuery(db, "SELECT 
                        AVG(r_temp) AS rtemp, 
                        AVG(dwd_temp) AS dwdtemp,
                        CONCAT(YEAR(dt), '-', LPAD(MONTH(dt),2,'0'), '-',LPAD(DAY(dt),2,'0')) AS Day
                      FROM ot 
                      WHERE f_ignore = 0 AND dwd_temp IS NOT NULL
                      GROUP BY CONCAT(YEAR(dt), '-', LPAD(MONTH(dt),2,'0'), '-',LPAD(DAY(dt),2,'0'))
                      ORDER BY CONCAT(YEAR(dt), '-', LPAD(MONTH(dt),2,'0'), '-',LPAD(DAY(dt),2,'0'))")
data <- fetch(rs, n=-1)
dbClearResult(rs)

data$rtemp <- data$rtemp/10
data$dwdtemp <- data$dwdtemp/10
data$Day <- as.Date(data$Day)

sprintf('Correlation: %f', cor(data$rtemp, data$dwdtemp))
mdata<-melt(data, id.vars=c("Day"))

png("generated/406_avg_temp_dwd_over_time.png", width=1000, height=600)
ggplot(data=mdata, aes(x=Day,y=value,colour=variable, linetype=variable)) + 
  geom_line() +
  ggtitle("Durchschnittswert der deutschen Messwerte und der Aussentemperatur laut DWD pro Tag")+
  scale_y_continuous(name="Temperatur in °C",breaks = seq(0,30,2),limits=c(-10,30),labels=format_format(big.mark=".", decimal.mark=",", scientific=FALSE)) +
  scale_x_date(name="Datum")+
  scale_linetype_manual(name="Typ", values = c("solid", "F1"),labels=c("Büro", "DWD")) +
  scale_color_manual(name ="Typ", values = c("black", "blue"),labels=c("Büro", "DWD")) +
  theme(axis.text=element_text(size=16))
dev.off()

