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


shinyServer(function(input, output, session) {

#  output$patternImage<- renderText({
#    query <- parseQueryString(session$clientData$url_search)
#    if(length(query)>0){
#      paste("<img src='/images/pattern/chartpattern-",query$patternId,".gif'>",sep="")
#    }
#  })

  output$patternDescription <- renderText({
    query <- parseQueryString(session$clientData$url_search)
    con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
    res<-dbGetQuery(con, "set names utf8")
    res<-dbSendQuery(con,paste("select id,description from patternMaster where id='",query$id,"'",sep=""))
    data.df<-fetch(res,-1)
    dbDisconnect(con)

    data.df$description
  })

  output$distPlot <- renderPlot({
    query <- parseQueryString(session$clientData$url_search)
    con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
    res<-dbGetQuery(con, "set names utf8")

    res<-dbSendQuery(con,paste("select s.signalTime,s.stockCode,l.startTime,l.startPrice,l.endTime,l.endPrice from chartPatternSignal s left join chartPatternLines l on s.lineID=l.lineID where s.lineID='",query$lineId,"'",sep=""))
    data.lines<-fetch(res,-1)
    dbDisconnect(con)

    con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
    res<-dbSendQuery(con,paste("select date as Date,oprice as Open,high as High,low as low,cprice Close,volume as Volume from live.ST_priceHistAdj where stockCode='",data.lines[1,]$stockCode,"' and date>=date_add('",data.lines[1,]$signalTime,"',interval -120 day) and date<=date_add('",data.lines[1,]$signalTime,"',interval 30 day)",sep=""))
    data.df<-fetch(res,-1)
    data.df$Date<-as.POSIXct(data.df$Date)
    data.zoo<-read.zoo(data.df)
    dbDisconnect(con)

    # draw chart
    candleChart(data.zoo,theme="white")

    # trend line
    for(i in 1:length(data.lines$stockCode)){
      data.tmp1<-make_trendline(data.df,data.lines[i,])
      plot(addTA(read.zoo(data.tmp1),on = 1,col='red'))
    }

    # vertical line
    data.pos<-match(as.POSIXct(data.lines[1,]$signalTime),data.df$Date)
    plot(addLines(v=data.pos))
  })

  output$patternImage<- renderText({
    query <- parseQueryString(session$clientData$url_search)
    paste("<img src='/images/chart/chartpattern-",query$id,".gif'>",sep="")
  })


  output$patternWinRate <- renderDataTable({
#    query <- parseQueryString(session$clientData$url_search)
#    con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
#    res<-dbGetQuery(con, "set names utf8")
#    res<-dbSendQuery(con,paste("select n.date,n.stockCode,n.title,n.href,s.score,s.score_cnt,s.score_std from fintech.yahooStockNews n left outer join fintech.yahooStockNewsSentiment s on n.href=s.href where n.stockCode='",query$stockCode,"' and  n.date>='2016-01-01' order by n.date desc",sep=""))
#    data.df<-fetch(res,-1)
#    data.table<-data.frame(date=data.df$date,title=data.df$title,score=data.df$score,score_cnt=data.df$score_cnt,reliability=data.df$score_std)
#    data.table$link<-createNewsLink(data.df$href)
#    dbDisconnect(con)
#    data.table
  },escape=F,options = list(pageLength = 10))


})
