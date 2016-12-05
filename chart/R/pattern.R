Sys.setenv("http_proxy"="http://zaan15p.qr.com:8080")

library(shiny)
library(RMySQL)
library(zoo)
library(quantmod)
con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
res<-dbGetQuery(con,"set names utf8")

lineId<-"2_6356_1419346800"
res<-dbSendQuery(con,paste("select s.signalTime,s.stockCode,l.startTime,l.startPrice,l.endTime,l.endPrice from chartPatternSignal s left join chartPatternLines l on s.lineID=l.lineID where s.lineID='",lineId,"'",sep=""))
data.lines<-fetch(res,-1)
res<-dbSendQuery(con,paste("select date_format(date,'%Y-%m-%d') as Date,oprice as Open,high as High,low as low, cprice Close,volume as Volume from live.ST_priceHistAdj where stockCode='",data.lines[1,]$stockCode,"' and date>=date_add('",data.lines[1,]$signalTime,"',interval -120 day) and date<=date_add('",data.lines[1,]$signalTime,"',interval 30 day)",sep=""))
data.df<-fetch(res,-1)
data.df$Date<-as.POSIXct(data.df$Date)






#data.tl<-data.frame(Date=data.ts,Price=data.price)
#data.tmp<-read.zoo(data.tl)

make_trendline<-function(data.df,data.line){
  data.ts<-as.POSIXct(c(data.line$startTime,data.line$endTime))
  data.price<-c(data.line[1,]$startPrice,data.line[1,]$endPrice)
  data.cnt<-0
  data.tl<-data.frame(Date=as.POSIXct(data.df$Date),Close=rep(NA,length=length(data.df$Date)))
  for(i in 1:length(data.tl$Date)){
    if( (data.tl[i,]$Date >= data.ts[1]) && (data.tl[i,]$Date <= data.ts[2])){
      data.cnt<-data.cnt+1
    }
  }
  data.a<-(data.price[2]-data.price[1])/data.cnt  # 傾き
  data.k<-0
  for(i in 1:length(data.tl$Date)){
    if( (data.tl[i,]$Date >= data.ts[1]) && (data.tl[i,]$Date <= data.ts[2])){
      data.tl[i,]$Close<-data.price[1]+data.a*data.k
      data.k<-data.k+1
    }
  }
  return(data.tl)
}
data.tmp1<-make_trendline(data.df,data.lines[1,])
data.tmp2<-make_trendline(data.df,data.lines[2,])

candleChart(read.zoo(data.df),theme="white")
addTA(read.zoo(data.tmp1),on = 1,col='red')
addTA(read.zoo(data.tmp2),on = 1,col='red')
dbDisconnect(con)



################################

library(shiny)
library(quantmod)
library(RMySQL)
library(zoo)
library(digest)
# 日本語

make_trendline<-function(data.df,data.line){
  data.ts<-as.POSIXct(c(data.line$startTime,data.line$endTime))
  data.price<-c(data.line[1,]$startPrice,data.line[1,]$endPrice)
  data.cnt<-0
  data.tl<-data.frame(Date=as.POSIXct(data.df$Date),Close=rep(NA,length=length(data.df$Date)))
  for(i in 1:length(data.tl$Date)){
    if( (data.tl[i,]$Date >= data.ts[1]) && (data.tl[i,]$Date <= data.ts[2])){
      data.cnt<-data.cnt+1
    }
  }
  data.a<-(data.price[2]-data.price[1])/data.cnt  # 傾き
  data.k<-0
  for(i in 1:length(data.tl$Date)){
    if( (data.tl[i,]$Date >= data.ts[1]) && (data.tl[i,]$Date <= data.ts[2])){
      data.tl[i,]$Close<-data.price[1]+data.a*data.k
      data.k<-data.k+1
    }
  }
  return(data.tl)
}

lineId<-"3_4026_1445958000"

query <- parseQueryString(session$clientData$url_search)    
con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
res<-dbGetQuery(con, "set names utf8")

res<-dbSendQuery(con,paste("select s.signalTime,s.stockCode,l.startTime,l.startPrice,l.endTime,l.endPrice from chartPatternSignal s left join chartPatternLines l on s.lineID=l.lineID where s.lineID='",lineId,"'",sep=""))
data.lines<-fetch(res,-1)
dbDisconnect(con)

con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
res<-dbSendQuery(con,paste("select date as Date,oprice as Open,high as High,low as low,cprice Close,volume as Volume from live.ST_priceHistAdj where stockCode='",data.lines[1,]$stockCode,"' and date>=date_add('",data.lines[1,]$signalTime,"',interval -120 day) and date<=date_add('",data.lines[1,]$signalTime,"',interval 30 day)",sep=""))
data.df<-fetch(res,-1)
data.df$Date<-as.POSIXct(data.df$Date)
dbDisconnect(con)


candleChart(read.zoo(data.df),theme="white")
addTA(read.zoo(make_trendline(data.df,data.lines[1,])),on = 1,col='red')
addTA(read.zoo(make_trendline(data.df,data.lines[2,])),on = 1,col='red')




###
query <- parseQueryString(session$clientData$url_search)    
con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
res<-dbGetQuery(con, "set names utf8")

res<-dbSendQuery(con,paste("select s.signalTime,s.stockCode,l.startTime,l.startPrice,l.endTime,l.endPrice from chartPatternSignal s left join chartPatternLines l on s.lineID=l.lineID where s.lineID='",lineId,"'",sep=""))
data.lines<-fetch(res,-1)
dbDisconnect(con)

con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
res<-dbSendQuery(con,paste("select date as Date,oprice as Open,high as High,low as low,cprice Close,volume as Volume from live.ST_priceHistAdj where stockCode='",data.lines[1,]$stockCode,"' and date>=date_add('",data.lines[1,]$signalTime,"',interval -120 day) and date<=date_add('",data.lines[1,]$signalTime,"',interval 30 day)",sep=""))
data.df<-fetch(res,-1)
dbDisconnect(con)

data.df$Date<-as.POSIXct(data.df$Date)
data.zoo<-read.zoo(data.df)
candleChart(data.zoo,theme="white")

    for(i in 1:length(data.lines$stockCode)){
      data.tmp1<-make_trendline(data.df,data.lines[i,])
      plot(addTA(read.zoo(data.tmp1),on = 1,col='red'))
    }

data.pos<-match(as.POSIXct(data.lines[1,]$signalTime),data.df$Date)
plot(addLines(v=data.pos))
