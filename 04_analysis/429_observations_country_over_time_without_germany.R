# Show observations by country over time without germany

library(RMySQL)
library(ggplot2)
library(scales)
library(countrycode)

source('dbconfig.R')

db <- dbConnect(MySQL(), user=USER, password=PASSWORD, dbname='bt')
rs <- dbSendQuery(db, "SELECT 
                        f_country,
                        COUNT(tid) AS ctid,
                        CONCAT(YEAR(dt), '-', LPAD(MONTH(dt),2,'0'), '-',LPAD(DAY(dt),2,'0')) AS Day
                      FROM ot 
                      WHERE f_ignore = 0 AND f_country IS NOT NULL AND f_country != 'DE'
                      GROUP BY f_country, CONCAT(YEAR(dt), '-', LPAD(MONTH(dt),2,'0'), '-',LPAD(DAY(dt),2,'0'))
                      ORDER BY f_country, CONCAT(YEAR(dt), '-', LPAD(MONTH(dt),2,'0'), '-',LPAD(DAY(dt),2,'0'))")
data <- fetch(rs, n=-1)
dbClearResult(rs)

data$Day <- as.Date(data$Day)
data$country<-countrycode(data$f_country, 'iso2c', 'country.name.de')

png("generated/429_observations_country_over_time_without_germany.png", width=1000, height=600)
ggplot(data=data, aes(x=Day, y=ctid,linetype=country, color=country)) + 
  geom_line() +
  ggtitle("Anzahl der Messstationen pro Tag und Land ohne Deutschland")+
  scale_y_continuous(name="Anzahl", labels=format_format(big.mark=".", decimal.mark=",", scientific=FALSE)) +
  scale_x_date(name="Datum")+
  scale_linetype(name="Land") +
  scale_color_hue(name ="Land") +
  theme(axis.text=element_text(size=16))
dev.off()

