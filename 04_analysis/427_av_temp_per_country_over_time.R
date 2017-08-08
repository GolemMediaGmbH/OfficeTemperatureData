# Average temperature by country over time

library(RMySQL)
library(ggplot2)
library(scales)
library(countrycode)

source('dbconfig.R')

db <- dbConnect(MySQL(), user=USER, password=PASSWORD, dbname='bt')
rs <- dbSendQuery(db, "SELECT 
                        f_country,
                        AVG(r_temp) AS rtemp,
                        CONCAT(YEAR(dt), '-', LPAD(MONTH(dt),2,'0'), '-',LPAD(DAY(dt),2,'0')) AS Day
                      FROM ot 
                      WHERE f_ignore = 0 AND f_country IS NOT NULL
                      GROUP BY f_country, CONCAT(YEAR(dt), '-', LPAD(MONTH(dt),2,'0'), '-',LPAD(DAY(dt),2,'0'))
                      ORDER BY f_country, CONCAT(YEAR(dt), '-', LPAD(MONTH(dt),2,'0'), '-',LPAD(DAY(dt),2,'0'))")
data <- fetch(rs, n=-1)
dbClearResult(rs)

data$temp <- data$rtemp/10
data$Day <- as.Date(data$Day)
data$country<-countrycode(data$f_country, 'iso2c', 'country.name.de')

png("generated/427_avg_temp_per_country_over_time.png", width=1000, height=600)
ggplot(data=data, aes(x=Day, y=temp,linetype=country, color=country)) + 
  geom_line() +
  ggtitle("Durchschnittstemperatur pro Land über die Zeit")+
  scale_y_continuous(name="Temperatur in °C",limit=c(0,30),breaks = seq(0,30,2),labels=format_format(big.mark=".", decimal.mark=",", scientific=FALSE)) +
  scale_x_date(name="Datum")+
  scale_linetype(name="Land") +
  scale_color_hue(name ="Land") +
  theme(axis.text=element_text(size=16))
dev.off()

