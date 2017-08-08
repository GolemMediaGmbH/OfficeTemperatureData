# Show the amount of Min-Max temperature ranges from 7am to 6pm only
library(RMySQL)
library(ggplot2)
library(scales)

source('dbconfig.R')

db <- dbConnect(MySQL(), user=USER, password=PASSWORD, dbname='bt')
rs <- dbSendQuery(db, "SELECT (max(r_temp)-min(r_temp)) AS diff, COUNT(tid) AS ctid
                  FROM ot 
                  WHERE 
                    f_ignore = 0 AND token IS NOT NULL AND 
                    HOUR(dt) >= 7 AND HOUR(dt) <= 18
                  GROUP BY token")
data <- fetch(rs, n=-1)
dbClearResult(rs)

summary(data)
data<-data[data$ctid > 1,]
data$diff <- data$diff/10

png("generated/417_histogram_variation_at_day.png", width=1000, height=600)
ggplot(data=data, aes(data$diff)) + 
  geom_histogram(bins=60, fill="#56B4E9") +
  ggtitle("Anzahl der Differenzen der Temperatur pro Messstation von7 Uhr morgens bis 18 Uhr abends")+  
  scale_y_continuous(name="Anzahl",labels=format_format(big.mark=".", decimal.mark=",", scientific=FALSE)) +
  scale_x_continuous(name="Temperaturdifferenz in °C",breaks = seq(0,60,by=2), labels=format_format(big.mark=".", decimal.mark=",", scientific=FALSE))+  
  theme( axis.text=element_text(size=16))
dev.off()

sprintf("Median: %f", median(data$diff))
summary(data)