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

make_hist<-function(query,hist_func){
    con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
    res<-dbGetQuery(con, "set names utf8")

    #par(mfrow=c(1,3)) 
    rikaku<-99999
    songiri<-99999
    term<-5
    #rikaku<-0.05
    #songiri<-0.05
    res<-dbSendQuery(con,paste("select m.patternId,m.stockCode,m.lineId,m.ret,m.volat from chartSimulation m inner join chartSignal g on m.patternId=g.patternId and m.lineId=g.lineId and m.stockCode=g.stockCode where g.signalTime<(select signalTime from chartSignal where lineId='",query$lineId,"') and m.patternId=",query$patternId," and m.rikaku=",rikaku," and m.songiri=",songiri, " and term=",term,sep=""))
    data5<-fetch(res,-1)
#    dbDisconnect(con)
    #hist(data$ret,main=paste("term=",term,sep=""))

    term<-10
    #rikaku<-0.1
    #songiri<-0.1
    res<-dbSendQuery(con,paste("select m.patternId,m.stockCode,m.lineId,m.ret,m.volat from chartSimulation m inner join chartSignal g on m.patternId=g.patternId and m.lineId=g.lineId and m.stockCode=g.stockCode where g.signalTime<(select signalTime from chartSignal where lineId='",query$lineId,"') and m.patternId=",query$patternId," and m.rikaku=",rikaku," and m.songiri=",songiri, " and term=",term,sep=""))
    data10<-fetch(res,-1)
    #hist(data$ret,main=paste("term=",term,sep=""))

#    con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
    term<-20
    res<-dbSendQuery(con,paste("select m.patternId,m.stockCode,m.lineId,m.ret,m.volat from chartSimulation m inner join chartSignal g on m.patternId=g.patternId and m.lineId=g.lineId and m.stockCode=g.stockCode where g.signalTime<(select signalTime from chartSignal where lineId='",query$lineId,"') and m.patternId=",query$patternId," and m.rikaku=",rikaku," and m.songiri=",songiri, " and term=",term,sep=""))
    data20<-fetch(res,-1)
    #hist(data$ret,main=paste("term=",term,sep=""))

    dbDisconnect(con)
    return(hist_func(data5,data10,data20))
}

shinyServer(function(input, output, session) {

  output$returnButton<- renderText({
    query <- parseQueryString(session$clientData$url_search)
    str<-sprintf('<a href="pattern3/?patternId=%s"  class="btn btn-primary">Back</a>',query$patternId)

    paste(str)
  })

  output$patternDescription <- renderText({
    query <- parseQueryString(session$clientData$url_search)
    con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
    res<-dbGetQuery(con, "set names utf8")
    res<-dbSendQuery(con,paste("select id,description from patternMaster where id='",query$patternId,"'",sep=""))
    data.df<-fetch(res,-1)
    dbDisconnect(con)

    paste("<h5>",data.df$description,"</h5>",sep="")
  })
  output$simuChart<-renderPlot({
    query <- parseQueryString(session$clientData$url_search)
    make_hist(query,function(data5,data10,data20){
      par(mfrow=c(1,3)) 
      hist(data5$ret,main="term=5")
      hist(data10$ret,main="term=10")
      hist(data20$ret,main="term=20")
      par(mfrow=c(1,1)) 
    })
  })

  output$stockChart <- renderPlot({
    query <- parseQueryString(session$clientData$url_search)
    con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
    res<-dbGetQuery(con, "set names utf8")

    res<-dbSendQuery(con,paste("select s.signalTime,s.stockCode,l.startTime,l.startPrice,l.endTime,l.endPrice from chartSignal s left join chartLine l on s.lineID=l.lineID where s.lineID='",query$lineId,"'",sep=""))
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
    res<-dbSendQuery(con,paste("select s.stockCode,m.englishName from chartSignal s inner join live.stockMasterFull m  on s.stockCode=m.stockCode where s.lineID='",query$lineId,"'",sep=""))
    data.lines<-fetch(res,-1)
    dbDisconnect(con)
    paste("<h3>",data.lines[1,]$englishName,"</h3>",sep="")
  })



  output$simuResult <- renderDataTable({
    query <- parseQueryString(session$clientData$url_search)
    data.table<-make_hist(query,function(data5,data10,data20){
      sum5<-as.numeric(summary(data5$ret))
      sum10<-as.numeric(summary(data10$ret))
      sum20<-as.numeric(summary(data20$ret))
      return(data.frame(summary=c("Min","1Q","Median","Mean","3Q","Max"),sum5=sum5,sum10=sum10,sum20=sum20))
    })
    return(data.table)
  },escape=F,options = list(pageLength = 20))


})
