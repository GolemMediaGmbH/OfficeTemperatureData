# Histogram of all values
library(RMySQL)
library(ggplot2)
library(scales)

source('dbconfig.R')

db <- dbConnect(MySQL(), user=USER, password=PASSWORD, dbname='bt')
rs <- dbSendQuery(db, "SELECT r_temp FROM ot WHERE f_ignore = 0")
data <- fetch(rs, n=-1)
dbClearResult(rs)

data$temp <- data$r_temp/10

png("generated/403_histogram_temp.png", width=1000, height=600)
ggplot(data=data, aes(data$temp)) + 
  geom_histogram(bins=45, fill="#56B4E9") +
  ggtitle("Verteilung der Temperaturwerte")+
  scale_y_continuous(name="Anzahl",labels=format_format(big.mark=".", decimal.mark=",", scientific=FALSE)) +
  scale_x_continuous(name="Temperatur in °C")+
  theme(axis.text=element_text(size=16))
dev.off()

sde = sd(data$temp)/sqrt(length(data$temp))

sprintf("Mean: %f", mean(data$temp))
sprintf("Standard deviation: %f", sd(data$temp))
sprintf("Standard error: %f", sde)
summary(data)