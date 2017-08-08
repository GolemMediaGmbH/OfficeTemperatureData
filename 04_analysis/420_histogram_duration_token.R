# Shows how long the token user participate
# binsize is 30 days

library(RMySQL)
library(ggplot2)
library(scales)

source('dbconfig.R')

db <- dbConnect(MySQL(), user=USER, password=PASSWORD, dbname='bt')
rs <- dbSendQuery(db, "SELECT DATEDIFF(MAX(dt), MIN(dt)) AS duration 
                  FROM ot WHERE token IS NOT NULL GROUP BY token")
data <- fetch(rs, n=-1)
dbClearResult(rs)

png("generated/420_histogram_duration_token.png", width=1000, height=600)
ggplot(data=data, aes(data$duration)) + 
  geom_histogram(binwidth=30,fill="#56B4E9") +
  ggtitle("Häufigkeiten der Teilnahmedauer von Messstationen mit Token")+
  scale_y_continuous(name="Anzahl",labels=format_format(big.mark=".", decimal.mark=",", scientific=FALSE)) +
  scale_x_continuous(name="Tage")+
  theme( axis.text=element_text(size=16))
dev.off()

sprintf("Median: %f", median(data$duration))
summary(data)