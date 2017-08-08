# Observations per day separated by token and non-token submits
library(RMySQL)
library(ggplot2)
library(scales)
library(reshape2)

source('dbconfig.R')

db <- dbConnect(MySQL(), user=USER, password=PASSWORD, dbname='bt')
rs <- dbSendQuery(db, "SELECT withToken.ctid AS wtCtid, withoutToken.ctid AS otCtid, withToken.d AS day
                  FROM 
                    (
                      SELECT 
                        COUNT(tid) AS ctid, 
                        CONCAT(YEAR(dt),'-',LPAD(MONTH(dt),2,'0'),'-',LPAD(DAY(dt),2,'0')) AS d 
                      FROM ot 
                      WHERE f_ignore=0 AND token IS NULL 
                      GROUP BY CONCAT(YEAR(dt),'-',LPAD(MONTH(dt),2,'0'),'-',LPAD(DAY(dt),2,'0'))
                    ) AS withoutToken
                  RIGHT JOIN
                    (
                      SELECT 
                        COUNT(tid) AS ctid, 
                        CONCAT(YEAR(dt),'-',LPAD(MONTH(dt),2,'0'),'-',LPAD(DAY(dt),2,'0')) AS d 
                        FROM ot 
                        WHERE f_ignore=0 AND token IS NOT NULL 
                        GROUP BY CONCAT(YEAR(dt),'-',LPAD(MONTH(dt),2,'0'),'-',LPAD(DAY(dt),2,'0'))
                    ) AS withToken
                  ON
                    withToken.d = withoutToken.d
                  ORDER BY withToken.d")

data <- fetch(rs, n=-1)
dbClearResult(rs)

data$day <- as.Date(data$day)

mdata<-melt(data, id.vars=c("day"))

png("generated/415_token_notoken.png", width=1000, height=600)
ggplot(data=mdata, aes(x=day,y=value,colour=variable, linetype=variable)) + 
  geom_line(color="#56B4E9") +
  ggtitle("Anzahl der Werte pro Tag getrennt nach Übermittlungen mit und ohne Token")+
  scale_y_continuous(name="Anzahl",labels=format_format(big.mark=".", decimal.mark=",", scientific=FALSE)) +
  scale_x_date(name="Datum")+
  scale_linetype_manual(name="Token", values = c("solid", "F1"),labels=c("Mit", "Ohne")) +
  scale_color_manual(name ="Token", values = c("black", "blue"),labels=c("Mit", "Ohne")) +
  theme(axis.text=element_text(size=16))
dev.off()

