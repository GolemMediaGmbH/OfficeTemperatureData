# Show average temperature by country

library(RMySQL)
library(ggplot2)
library(scales)
library(countrycode)

source('dbconfig.R')

db <- dbConnect(MySQL(), user=USER, password=PASSWORD, dbname='bt')
rs <- dbSendQuery(db, "SELECT 
                  AVG(r_temp) AS rtemp, f_country
                  FROM ot 
                  WHERE 
                    f_country NOT IN ('LI', 'TH', 'UG') 
                    AND f_country IS NOT NULL
                    AND f_ignore=0 
                  GROUP BY f_country 
                  ORDER BY AVG(r_temp) DESC")

data <- fetch(rs, n=-1)
dbClearResult(rs)

data$temp <- data$rtemp/10
data$country<-countrycode(data$f_country, 'iso2c', 'country.name.de')

png("generated/409_avg_temp_by_country.png", width=1000, height=600)
ggplot(data=data, aes(x=reorder(country, -temp) ,y=temp))+
  geom_bar(stat = "identity",fill="#56B4E9") +
  ggtitle("Durchschnittstemperatur pro Land")+
  scale_y_continuous(name="Temperatur in ^C",breaks = seq(0,30,by=2),labels=format_format(big.mark=".", decimal.mark=",", scientific=FALSE))+
  scale_x_discrete(name="Land")+
  theme(axis.text=element_text(size=15))
dev.off()