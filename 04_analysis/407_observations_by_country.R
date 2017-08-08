# Observations per country
library(RMySQL)
library(ggplot2)
library(scales)
library(countrycode)

source('dbconfig.R')

db <- dbConnect(MySQL(), user=USER, password=PASSWORD, dbname='bt')
rs <- dbSendQuery(db, "SELECT 
                        COUNT(tid) AS ctid, f_country 
                        FROM ot 
                        WHERE f_country IS NOT NULL 
                        GROUP BY f_country;")
data <- fetch(rs, n=-1)
dbClearResult(rs)

data$country<-countrycode(data$f_country, 'iso2c', 'country.name.de')

png("generated/407_observations_by_country.png", width=1000, height=600)
ggplot(data=data, aes(x=reorder(country, -ctid),y=ctid))+
  geom_bar(stat = "identity", fill="#56B4E9") +
  ggtitle("Messwerte pro Land")+
  scale_y_continuous(name="Anzahl",labels=format_format(big.mark=".", decimal.mark=",", scientific=FALSE)) +
  scale_x_discrete(name="Land")+
  theme(axis.text=element_text(size=15))
dev.off()