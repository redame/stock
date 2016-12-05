Sys.setenv("http_proxy"="http://zaan15p.qr.com:8080")

library(shiny)
library(RMySQL)
library(zoo)
library(quantmod)
con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
res<-dbGetQuery(con,"set names utf8")

par(mfrow=c(1,3)) 

rikaku=0.05
songiri=0.05
term=5
#res<-dbSendQuery(con,paste("select m.patternId,m.stockCode,m.lineId,m.ret,m.volat from chartSimulation m inner join chartPatternSignal2 s on m.patternId=s.patternId and m.stockCode=s.stockCode and m.lineId=s.lineId  where s.patternId=",patternId," and s.upDownFlag!='make' and m.rikaku=",rikaku," and m.songiri=",songiri, " and term=",term,sep=""))
data.simu<-fetch(res,n=-1)
hist(data.simu$ret,main=paste("songiri=",songiri,",rikaku=",rikaku,",term=",term,sep=""))
length(data.simu$ret)
summary(data.simu$ret)



par(mfrow=c(1,3))
patternId=3
rikaku<-0.05
songiri<-0.05
term<-5
res<-dbSendQuery(con,paste("select m.patternId,m.stockCode,m.lineId,m.ret,m.volat from chartSimulation m where m.patternId=",patternId," and m.rikaku=",rikaku," and m.songiri=",songiri, " and term=",term,sep=""))
data<-fetch(res,-1)
hist(data$ret,main=paste("songiri=",songiri,",rikaku=",rikaku,",term=",term,sep=""))
summary(data$ret)

rikaku<-0.1
songiri<-0.1
res<-dbSendQuery(con,paste("select m.patternId,m.stockCode,m.lineId,m.ret,m.volat from chartSimulation m where m.patternId=",patternId," and m.rikaku=",rikaku," and m.songiri=",songiri, " and term=",term,sep=""))
data<-fetch(res,-1)
hist(data$ret,main=paste("term=",term,sep=""))
summary(data$ret)

rikaku<-99999
songiri<-99999
res<-dbSendQuery(con,paste("select m.patternId,m.stockCode,m.lineId,m.ret,m.volat from chartSimulation m where m.patternId=",patternId," and m.rikaku=",rikaku," and m.songiri=",songiri, " and term=",term,sep=""))
data<-fetch(res,-1)
hist(data$ret,main=paste("term=",term,sep=""))
summary(data$ret)



dbDisconnect(con)