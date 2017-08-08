# Show the average value per day 
library(RMySQL)
library(ggplot2)
library(scales)

source('dbconfig.R')

db <- dbConnect(MySQL(), user=USER, password=PASSWORD, dbname='bt')
rs <- dbSendQuery(db, "SELECT 
                        AVG(r_temp) AS rtemp, 
                        CONCAT(YEAR(dt), '-', LPAD(MONTH(dt),2,'0'), '-',LPAD(DAY(dt),2,'0')) AS Day
                      FROM ot 
                      WHERE f_ignore = 0
                      GROUP BY CONCAT(YEAR(dt), '-', LPAD(MONTH(dt),2,'0'), '-',LPAD(DAY(dt),2,'0'))
                      ORDER BY CONCAT(YEAR(dt), '-', LPAD(MONTH(dt),2,'0'), '-',LPAD(DAY(dt),2,'0'))")
data <- fetch(rs, n=-1)
dbClearResult(rs)

data$temp <- data$rtemp/10
data$Day <- as.Date(data$Day)
summary(data)

png("generated/404_avg_over_time.png", width=1000, height=600)
ggplot(data=data, aes(x=Day, y=temp)) + 
  geom_line(color="#56B4E9") +
  ggtitle("Durchschnittswert der Temperaturen pro Tag")+
  scale_y_continuous(name="Temperatur in °C",limits=c(0,30),breaks = seq(0,30,2),labels=format_format(big.mark=".", decimal.mark=",", scientific=FALSE)) +
  scale_x_date(name="Datum")+
  theme(axis.text=element_text(size=16))
dev.off()

