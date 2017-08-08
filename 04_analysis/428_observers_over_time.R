# Observers over time

library(RMySQL)
library(ggplot2)
library(scales)

source('dbconfig.R')

db <- dbConnect(MySQL(), user=USER, password=PASSWORD, dbname='bt')
rs <- dbSendQuery(db, "SELECT COUNT(DISTINCT(token)) AS ctoken,
                        CONCAT(YEAR(dt), '-', LPAD(MONTH(dt),2,'0'), '-',LPAD(DAY(dt),2,'0')) AS Day
                      FROM ot 
                      WHERE 
                        f_ignore=0 AND 
                        f_country IS NOT NULL AND 
                        token IS NOT NULL AND 
                        f_lat IS NULL AND 
                        f_lon IS NULL 
                      GROUP BY CONCAT(YEAR(dt), '-', LPAD(MONTH(dt),2,'0'), '-',LPAD(DAY(dt),2,'0'))")
data.token <- fetch(rs, n=-1)
dbClearResult(rs)

rs <- dbSendQuery(db, "SELECT COUNT(DISTINCT(f_lat)) AS clatlon,
                        CONCAT(YEAR(dt), '-', LPAD(MONTH(dt),2,'0'), '-',LPAD(DAY(dt),2,'0')) AS Day
                      FROM ot 
                  WHERE 
                  f_ignore=0 AND 
                  f_country IS NOT NULL AND 
                  token IS NULL AND 
                  f_lat IS NOT NULL AND 
                  f_lon IS NOT NULL 
                  GROUP BY CONCAT(YEAR(dt), '-', LPAD(MONTH(dt),2,'0'), '-',LPAD(DAY(dt),2,'0'))")
data.latlon <- fetch(rs, n=-1)
dbClearResult(rs)

rs <- dbSendQuery(db, "SELECT COUNT(DISTINCT(token)) AS ctokenlatlon,
                        CONCAT(YEAR(dt), '-', LPAD(MONTH(dt),2,'0'), '-',LPAD(DAY(dt),2,'0')) AS Day
                      FROM ot 
                  WHERE 
                  f_ignore=0 AND 
                  f_country IS NOT NULL AND 
                  token IS NOT NULL AND 
                  f_lat IS NOT NULL AND 
                  f_lon IS NOT NULL 
                  GROUP BY CONCAT(YEAR(dt), '-', LPAD(MONTH(dt),2,'0'), '-',LPAD(DAY(dt),2,'0'))")
data.tokenlatlon <- fetch(rs, n=-1)
dbClearResult(rs)

# the count of token values makes no sense but this way we get countries not in the results
# above
rs <- dbSendQuery(db, "SELECT COUNT(DISTINCT(token)) AS ccountry,
                        CONCAT(YEAR(dt), '-', LPAD(MONTH(dt),2,'0'), '-',LPAD(DAY(dt),2,'0')) AS Day
                  FROM ot 
                  WHERE 
                  f_ignore=0 AND 
                  f_country IS NOT NULL AND 
                  token IS NULL AND 
                  f_lat IS NULL AND 
                  f_lon IS NULL 
                  GROUP BY CONCAT(YEAR(dt), '-', LPAD(MONTH(dt),2,'0'), '-',LPAD(DAY(dt),2,'0'))")
data.country <- fetch(rs, n=-1)
dbClearResult(rs)

data <- merge(data.token, data.latlon, by='Day', all=TRUE)
data <- merge(data, data.tokenlatlon, by='Day', all=TRUE)
data <- merge(data, data.country, by='Day', all=TRUE)

data[is.na(data)] <- 0
data$sum <- data$ctoken + data$clatlon + data$ctokenlatlon + data$ccountry
data$Day <- as.Date(data$Day)

png("generated/428_observers_over_time.png", width=1000, height=600)
ggplot(data=data, aes(x=Day,y=sum))+
  geom_line(stat = "identity",color="#56B4E9") +
  ggtitle("Anzahl der Messsation pro Tag")+
  scale_y_continuous(name="Anzahl",labels=format_format(big.mark=".", decimal.mark=",", scientific=FALSE))+
  scale_x_date(name="Datum")+
  theme(axis.text=element_text(size=16))
dev.off()