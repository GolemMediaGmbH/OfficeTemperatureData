# Shows average temperature per hour of day
library(RMySQL)
library(ggplot2)
library(scales)

source('dbconfig.R')

db <- dbConnect(MySQL(), user=USER, password=PASSWORD, dbname='bt')
rs <- dbSendQuery(db, "SELECT AVG(r_temp) AS rtemp, HOUR(dt) AS hour 
                      FROM ot 
                      WHERE f_ignore = 0 
                      GROUP BY HOUR(dt) 
                      ORDER BY HOUR(dt) ASC")

data <- fetch(rs, n=-1)
dbClearResult(rs)

data$temp <- data$rtemp/10

png("generated/411_avg_temp_by_hour.png", width=1000, height=600)
ggplot(data=data, aes(x=hour, y=temp)) + 
  geom_line(color="#56B4E9") +
  ggtitle("Durchschnittstemperatur über den Tag verteilt")+
  scale_y_continuous(name="Temperatur in °C",limits=c(-5,30),breaks = seq(-5,30,by=2),labels=format_format(big.mark=".", decimal.mark=",", scientific=FALSE)) +
  scale_x_continuous(name="Stunde",breaks=seq(0,23,1))+
  theme(axis.text=element_text(size=16))
dev.off()
