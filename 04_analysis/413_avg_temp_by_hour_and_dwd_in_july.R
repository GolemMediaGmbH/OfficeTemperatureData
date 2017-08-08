# Show average temperature in comparison with DWD values per hour in july 2016

library(RMySQL)
library(ggplot2)
library(scales)
library(reshape2)

source('dbconfig.R')

db <- dbConnect(MySQL(), user=USER, password=PASSWORD, dbname='bt')
rs <- dbSendQuery(db, "SELECT AVG(r_temp) AS rtemp, AVG(dwd_temp) AS dwdtemp, HOUR(dt) AS hour 
                      FROM ot 
                      WHERE f_ignore = 0 AND dwd_temp IS NOT NULL AND MONTH(dt) = 7
                      GROUP BY HOUR(dt) 
                      ORDER BY HOUR(dt) ASC")

data <- fetch(rs, n=-1)
dbClearResult(rs)

data$rtemp <- data$rtemp/10
data$dwdtemp <- data$dwdtemp/10

sprintf('Correlation: %f', cor(data$rtemp, data$dwdtemp))
mdata<-melt(data, id.vars=c("hour"))

png("generated/413_avg_temp_dwd_by_hour_in_july.png", width=1000, height=600)
ggplot(data=mdata, aes(x=hour,y=value,colour=variable, linetype=variable)) + 
  geom_line() +
  ggtitle("Durchschnittstemperaturen deutscher Messstationen im Vergleich mit DWD-Aussentemperaturen pro Stunde im Juli 2016")+
  scale_y_continuous(name="Temperatur in °C",breaks = seq(-5,30,by=2),limits=c(-5,30),labels=format_format(big.mark=".", decimal.mark=",", scientific=FALSE)) +
  scale_x_continuous(name="Stunde",breaks=seq(0,23,1))+      
  scale_linetype_manual(name="Typ", values = c("solid", "F1"),labels=c("Büro", "DWD")) +
  scale_color_manual(name ="Typ", values = c("black", "blue"),labels=c("Büro", "DWD")) +
  theme(axis.text=element_text(size=16))
dev.off()
