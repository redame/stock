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

  output$returnButton<- renderText({
    query <- parseQueryString(session$clientData$url_search)
    str<-sprintf('<a href="pattern2/?patternId=%s"  class="btn btn-primary">Back</a>',query$patternId)

    paste(str)
  })

  output$patternDescription <- renderText({
    query <- parseQueryString(session$clientData$url_search)
    con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
    res<-dbGetQuery(con, "set names utf8")
    res<-dbSendQuery(con,paste("select id,description from patternMaster where id='",query$id,"'",sep=""))
    data.df<-fetch(res,-1)
    dbDisconnect(con)

    data.df$description
  })
  output$hist5Plot<-renderPlot({
    query <- parseQueryString(session$clientData$url_search)
    con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
    res<-dbGetQuery(con, "set names utf8")

    par(mfrow=c(1,3)) 
    rikaku<-0.05
    songiri<-0.05
    term<-10
    res<-dbSendQuery(con,paste("select m.patternId,m.stockCode,m.lineId,m.ret,m.volat from chartSimulation m where m.patternId=",query$patternId," and m.rikaku=",rikaku," and m.songiri=",songiri, " and term=",term,sep=""))
    data<-fetch(res,-1)
#    dbDisconnect(con)
    hist(data$ret,main=paste("songiri=",songiri,",rikaku=",rikaku,",term=",term,sep=""))

    rikaku<-0.1
    songiri<-0.1
    res<-dbSendQuery(con,paste("select m.patternId,m.stockCode,m.lineId,m.ret,m.volat from chartSimulation m where m.patternId=",query$patternId," and m.rikaku=",rikaku," and m.songiri=",songiri, " and term=",term,sep=""))
    data<-fetch(res,-1)
    hist(data$ret,main=paste("songiri=",songiri,",rikaku=",rikaku,",term=",term,sep=""))

#    con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
    rikaku<-99999
    songiri<-99999
    res<-dbSendQuery(con,paste("select m.patternId,m.stockCode,m.lineId,m.ret,m.volat from chartSimulation m where m.patternId=",query$patternId," and m.rikaku=",rikaku," and m.songiri=",songiri, " and term=",term,sep=""))
    data<-fetch(res,-1)
    hist(data$ret,main=paste("term=",term,sep=""))

    dbDisconnect(con)

  })

  output$distPlot <- renderPlot({
    query <- parseQueryString(session$clientData$url_search)
    con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
    res<-dbGetQuery(con, "set names utf8")

    res<-dbSendQuery(con,paste("select s.signalTime,s.stockCode,l.startTime,l.startPrice,l.endTime,l.endPrice from chartPatternSignal2 s left join chartPatternLines2 l on s.lineID=l.lineID where s.lineID='",query$lineId,"'",sep=""))
    data.lines<-fetch(res,-1)
#    dbDisconnect(con)

#    con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
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

  output$stockName<- renderText({
    query <- parseQueryString(session$clientData$url_search)
    con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
    res<-dbGetQuery(con, "set names utf8")
    res<-dbSendQuery(con,paste("select s.stockCode,m.englishName from chartPatternSignal2 s inner join live.stockMasterFull m  on s.stockCode=m.stockCode where s.lineID='",query$lineId,"'",sep=""))
    data.lines<-fetch(res,-1)
    dbDisconnect(con)
    paste("<h3>",data.lines[1,]$englishName,"</h3>",sep="")
  })



  output$patternSimulation <- renderDataTable({
#    query <- parseQueryString(session$clientData$url_search)
#    con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
#    res<-dbGetQuery(con, "set names utf8")
#    res<-dbSendQuery(con,paste(""))
#    data.df<-fetch(res,-1)
#    data.table<-data.frame(date=data.df$date,title=data.df$title,score=data.df$score,score_cnt=data.df$score_cnt,reliability=data.df$score_std)
#    data.table$link<-createNewsLink(data.df$href)
#    dbDisconnect(con)
#    data.table
  },escape=F,options = list(pageLength = 10))


})
