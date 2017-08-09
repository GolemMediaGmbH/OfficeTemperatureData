# collect statistics for observations per country

library(RMySQL)
library(ggplot2)

source('dbconfig.R')

db <- dbConnect(MySQL(), user=USER, password=PASSWORD, dbname='bt')
rs <- dbSendQuery(db, "SELECT r_temp, f_country
                  FROM ot 
                  WHERE 
                  f_ignore = 0")
data <- fetch(rs, n=-1)
dbClearResult(rs)

data$r_temp <- data$r_temp/10

f.sem <- function(x) sd(x)/sqrt(length(x))

sdt<-sd(data$r_temp)
sem<-f.sem(data$r_temp)
sprintf('Observations: %i', length(data$r_temp))
sprintf('Standard deviation: %f', sdt)
sprintf('Standard error of mean: %f', sem)        

sample.mean<-aggregate(r_temp ~ f_country, data, mean)
names(sample.mean)[2]<-"mean"
sample.size<-aggregate(r_temp ~ f_country, data, length)
names(sample.size)[2]<-"size"
sample.sd<-aggregate(r_temp ~ f_country, data, sd)
names(sample.sd)[2]<-"sd"
sample.sem<-aggregate(r_temp ~ f_country, data, f.sem)
names(sample.sem)[2]<-"sem"
sample.data<-merge(sample.size, sample.sd, by="f_country")
sample.data<-merge(sample.data, sample.sem, by="f_country")
sample.data<-merge(sample.data, sample.mean, by="f_country")

f.moe<-function(x) data.frame(moe=qt(0.95, as.numeric(x['size']))*(as.numeric(x['sd'])/sqrt(as.numeric(x['size']))), f_country=x['f_country'])
moe <- apply(sample.data, 1, f.moe)
moe.df<-do.call(rbind, moe)
sample.data<-merge(sample.data, moe.df, by="f_country")

f.print<-function(x) {
  sprintf("%s,%s,%s,%s,%s", x['f_country'],x['mean'],trimws(x['size']),x['sd'],x['sem'],x['moe'])
}

lines <-apply(sample.data,1,f.print)
lines <- c(sprintf("%s,%s,%s,%s,%s,%s", "country",'mean','samplesize','sd','sem','moe'), lines)
write(lines,"./generated/422_stats_country.csv")