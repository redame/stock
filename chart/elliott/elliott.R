# deprecated
library(RMySQL)
library(quantmod)
library(RMySQL)
library(zoo)
library(digest)

# http://blogs.yahoo.co.jp/igproj_fusion/16095656.html
# https://github.com/joshuaulrich/quantmod/releases
#library(devtools)

Sys.setenv("http_proxy"="http://zaan15p.qr.com:8080")
#Sys.setenv("https_proxy"="http://zaan15p.qr.com:8080")

#install_github("joshuaulrich/quantmod")


make_elliott<-function(data.df,data.line){
  data.tl<-data.frame(Date=as.POSIXct(data.df$Date),Close=rep(NA,length=length(data.df$Date)))
  data.tl<-make_trendline(data.df,data.tl,data.line$date1,data.line$price1,data.line$date2,data.line$price2)
  data.tl<-make_trendline(data.df,data.tl,data.line$date2,data.line$price2,data.line$date3,data.line$price3)
  data.tl<-make_trendline(data.df,data.tl,data.line$date3,data.line$price3,data.line$date4,data.line$price4)
  data.tl<-make_trendline(data.df,data.tl,data.line$date4,data.line$price4,data.line$date5,data.line$price5)
  data.tl<-make_trendline(data.df,data.tl,data.line$date5,data.line$price5,data.line$date6,data.line$price6)
  data.tl<-make_trendline(data.df,data.tl,data.line$date6,data.line$price6,data.line$date7,data.line$price7)
  data.tl<-make_trendline(data.df,data.tl,data.line$date7,data.line$price7,data.line$date8,data.line$price8)
  data.tl<-make_trendline(data.df,data.tl,data.line$date8,data.line$price8,data.line$date9,data.line$price9)
  return(data.tl)
}
make_trendline<-function(data.df,data.tl,fdate,fprice,tdate,tprice){
  data.ts<-as.POSIXct(c(fdate,tdate))
  data.price<-c(fprice,tprice)
  data.cnt<-0
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

draw_chart<-function(stockCode,fromDate,toDate){
  
  con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
  res<-dbGetQuery(con, "set names utf8")
  
  data.lines<-fetch(dbSendQuery(con,paste("select * from elliott where stockCode='",stockCode,"' and date1>='",fromDate,"' and date9<='",toDate,"' order by date9 asc",sep="")),-1)
  res<-dbSendQuery(con,paste("select date as Date,oprice as Open,high as High,low as low,cprice Close,volume as Volume from live.ST_priceHistAdj where stockCode='",stockCode,"' and date between '",fromDate,"' and '",toDate,"'",sep=""))
  data.df<-fetch(res,-1)
  data.df$Date<-as.POSIXct(data.df$Date)
  data.zoo<-read.zoo(data.df)
  
  dbDisconnect(con)
  
  # draw chart
  candleChart(data.zoo,theme="white",plot=F)

  # trend line
  for(i in 1:length(data.lines$stockCode)){
    d<-data.lines[i,]

    l<-read.zoo(make_elliott(data.df,d))
    plot(addTA(l,legend=NULL,on = 1,col=i,type="l"))
  }
  
  
  # vertical line
  #data.pos<-match(as.POSIXct(data.lines[1,]$signalTime),data.df$Date)
  #plot(addLines(v=data.pos))
}





stockCode<-"6758"
fromDate<-"2015-01-01"
toDate<-"2015-12-31"
draw_chart(stockCode,fromDate,toDate)

#data<-fetch(dbSendQuery(con,paste("select * from elliott where stockCode='",stockCode,"' order by date9 desc ",sep="")),n=-1)
