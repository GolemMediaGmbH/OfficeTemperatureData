# Show average temperature by german states
library(RMySQL)
library(ggplot2)
library(scales)

source('dbconfig.R')

db <- dbConnect(MySQL(), user=USER, password=PASSWORD, dbname='bt')
rs <- dbSendQuery(db, "SELECT 
                  AVG(r_temp) AS rtemp, f_state 
                  FROM ot 
                  WHERE 
                    f_country = 'DE' 
                    AND f_state IS NOT NULL 
                    AND f_ignore=0 
                  GROUP BY f_state 
                  ORDER BY AVG(r_temp) DESC")

data <- fetch(rs, n=-1)
dbClearResult(rs)

dict <- data.frame(iso = c('BE','BY','NW','BW','TH','SN','NI','ST','HE','HH','RP','SL','BR','SH','MV','HB'),
                   state = c('Berlin', 'Bayern','Nordrhein-\nWestfalen','Baden-\nWürttemberg','Thüringen','Sachsen',
                             'Nieder-\nsachsen','Sachsen-\nAnhalt','Hessen','Hamburg','Rheinland-\nPfalz','Saarland','Branden-\nburg',
                             'Schleswig-\nHolstein','Mecklenburg-\nVorpommern','Bremen'))
data$f_state <- as.factor(data$f_state)
data$state <- with(dict, state[match(data$f_state, iso)])

data$temp <- data$rtemp/10

png("generated/410_avg_temp_by_state.png", width=1000, height=600)
ggplot(data=data, aes(x=reorder(state, -temp),y=temp))+
  geom_bar(stat = "identity",fill="#56B4E9") +
  ggtitle("Durchschnittstemperaturen der deutschen Bundesländer")+
  scale_y_continuous(name="Temperatur in °C",breaks = seq(0,30,by=2),labels=format_format(big.mark=".", decimal.mark=",", scientific=FALSE))+
  scale_x_discrete("Bundesland")+
  theme(axis.text.x=element_text(size=10),axis.text.y=element_text(size=16))
dev.off()