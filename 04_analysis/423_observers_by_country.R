# Show observers by country
# the numbers are estimates only

library(RMySQL)
library(ggplot2)
library(scales)
library(countrycode)

source('dbconfig.R')

db <- dbConnect(MySQL(), user=USER, password=PASSWORD, dbname='bt')
rs <- dbSendQuery(db, "SELECT f_country, COUNT(DISTINCT(token)) AS ctoken 
                      FROM ot 
                      WHERE 
                        f_ignore=0 AND 
                        f_country IS NOT NULL AND 
                        token IS NOT NULL AND 
                        f_lat IS NULL AND 
                        f_lon IS NULL 
                      GROUP BY f_country")
data.token <- fetch(rs, n=-1)
dbClearResult(rs)

rs <- dbSendQuery(db, "SELECT f_country, COUNT(DISTINCT(f_lat)) AS clatlon 
                      FROM ot 
                  WHERE 
                  f_ignore=0 AND 
                  f_country IS NOT NULL AND 
                  token IS NULL AND 
                  f_lat IS NOT NULL AND 
                  f_lon IS NOT NULL 
                  GROUP BY f_country")
data.latlon <- fetch(rs, n=-1)
dbClearResult(rs)

rs <- dbSendQuery(db, "SELECT f_country, COUNT(DISTINCT(token)) AS ctokenlatlon
                      FROM ot 
                  WHERE 
                  f_ignore=0 AND 
                  f_country IS NOT NULL AND 
                  token IS NOT NULL AND 
                  f_lat IS NOT NULL AND 
                  f_lon IS NOT NULL 
                  GROUP BY f_country")
data.tokenlatlon <- fetch(rs, n=-1)
dbClearResult(rs)

# the count of token values makes no sense but this way we get countries not in the results
# above
rs <- dbSendQuery(db, "SELECT f_country, COUNT(DISTINCT(token)) AS ccountry
                      FROM ot 
                  WHERE 
                  f_ignore=0 AND 
                  f_country IS NOT NULL AND 
                  token IS NULL AND 
                  f_lat IS NULL AND 
                  f_lon IS NULL 
                  GROUP BY f_country")
data.country <- fetch(rs, n=-1)
dbClearResult(rs)

data <- merge(data.token, data.latlon, by='f_country', all=TRUE)
data <- merge(data, data.tokenlatlon, by='f_country', all=TRUE)
data <- merge(data, data.country, by='f_country', all=TRUE)

data[is.na(data)] <- 0
data$sum <- data$ctoken + data$clatlon + data$ctokenlatlon + data$ccountry

data$country<-countrycode(data$f_country, 'iso2c', 'country.name.de')

png("generated/423_observers_by_country.png", width=1000, height=600)
ggplot(data=data, aes(x=reorder(country,-sum),y=sum))+
  geom_bar(stat = "identity",fill="#56B4E9") +
  ggtitle("Anzahl der Messstationen pro Land")+
  scale_y_continuous(name="Anzahl", labels=format_format(big.mark=".", decimal.mark=",", scientific=FALSE))+
  scale_x_discrete(name="Land")+
  theme( axis.text=element_text(size=15))
dev.off()