# Show observers by german states
# the numbers are estimates only

library(RMySQL)
library(ggplot2)
library(scales)

source('dbconfig.R')

db <- dbConnect(MySQL(), user=USER, password=PASSWORD, dbname='bt')
rs <- dbSendQuery(db, "SELECT f_state, COUNT(DISTINCT(token)) AS ctoken 
                      FROM ot 
                      WHERE 
                        f_ignore=0 AND 
                        f_country = 'DE' AND 
                        f_state IS NOT NULL AND
                        token IS NOT NULL AND 
                        f_lat IS NULL AND 
                        f_lon IS NULL 
                      GROUP BY f_state")
data.token <- fetch(rs, n=-1)
dbClearResult(rs)

rs <- dbSendQuery(db, "SELECT f_state, COUNT(DISTINCT(f_lat)) AS clatlon 
                      FROM ot 
                  WHERE 
                  f_ignore=0 AND 
                  f_country = 'DE' AND 
                  f_state IS NOT NULL AND
                  token IS NULL AND 
                  f_lat IS NOT NULL AND 
                  f_lon IS NOT NULL 
                  GROUP BY f_state")
data.latlon <- fetch(rs, n=-1)
dbClearResult(rs)

rs <- dbSendQuery(db, "SELECT f_state, COUNT(DISTINCT(token)) AS ctokenlatlon
                      FROM ot 
                  WHERE 
                  f_ignore=0 AND 
                  f_country ='DE' AND 
                  f_state IS NOT NULL AND
                  token IS NOT NULL AND 
                  f_lat IS NOT NULL AND 
                  f_lon IS NOT NULL 
                  GROUP BY f_state")
data.tokenlatlon <- fetch(rs, n=-1)
dbClearResult(rs)

data <- merge(data.token, data.latlon, by='f_state', all=TRUE)
data <- merge(data, data.tokenlatlon, by='f_state', all=TRUE)

data[is.na(data)] <- 0
data$sum <- data$ctoken + data$clatlon + data$ctokenlatlon

dict <- data.frame(iso = c('BE','BY','NW','BW','TH','SN','NI','ST','HE','HH','RP','SL','BR','SH','MV','HB'),
                   state = c('Berlin', 'Bayern','Nordrhein-\nWestfalen','Baden-\nWürttemberg','Thüringen','Sachsen',
                             'Nieder-\nsachsen','Sachsen-\nAnhalt','Hessen','Hamburg','Rheinland-\nPfalz','Saarland','Branden-\nburg',
                             'Schleswig-\nHolstein','Mecklenburg-\nVorpommern','Bremen'))

data$state <- with(dict, state[match(data$f_state, iso)])

png("generated/424_observers_by_state.png", width=1000, height=600)
ggplot(data=data, aes(x=reorder(state,-sum),y=sum))+
  geom_bar(stat = "identity",fill="#56B4E9") +
  ggtitle("Anzahl der Messstationen pro Bundesland")+
  scale_y_continuous(name="Anzahl",labels=format_format(big.mark=".", decimal.mark=",", scientific=FALSE))+
  scale_x_discrete(name="Bundesland")+
  theme(axis.text.x=element_text(size=10),axis.text.y=element_text(size=16))
dev.off()