# Show observations by type of device
library(RMySQL)
library(ggplot2)
library(scales)

source('dbconfig.R')

db <- dbConnect(MySQL(), user=USER, password=PASSWORD, dbname='bt')
rs <- dbSendQuery(db, "SELECT COUNT(tid) AS ctid, type FROM ot GROUP BY type ORDER BY ctid DESC")
data <- fetch(rs, n=-1)
dbClearResult(rs)

dict <- data.frame(type = c("ard", "wifimcu", "sbc", "other"), name=c("Arduino", "Funkmodul", "Bastelrechner", "Andere"))

data$name <- with(dict, name[match(data$type, type)])

png("generated/419_observations_by_type.png", width=1000, height=600)
ggplot(data=data, aes(x=reorder(name,-ctid),y=ctid))+
  geom_bar(stat = "identity", fill="#56B4E9") +
  ggtitle("Anzahl der Messwerte pro Gerätetyp")+
  scale_y_continuous(name="Anzahl",labels=format_format(big.mark=".", decimal.mark=",", scientific=FALSE))+
  scale_x_discrete(name="Gerätrtype")+
  theme( axis.text=element_text(size=16))
dev.off()