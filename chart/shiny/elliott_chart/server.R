library(shiny)
library(quantmod)
library(RMySQL)
library(zoo)
library(digest)
# 日本語


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

get_tablename<-function(ashi){
    table<-"ST_priceHistAdj"
    if(ashi == "m"){
      table<-"ST_priceHistMonthly"
    }else if(ashi=="w"){
      table<-"ST_priceHistWeekly"
    }
    return(table)
}


shinyServer(function(input, output, session) {

  output$returnButton<- renderText({
    query <- parseQueryString(session$clientData$url_search)
    str<-sprintf('<a href="../elliott_list/"  class="btn btn-primary">Back</a>',query$patternId)

    paste(str)
  })

  output$fromDate<-renderUI({
    query <- parseQueryString(session$clientData$url_search)
    query$fromDate
    
  })
  output$stockChart <- renderPlot({
    query <- parseQueryString(session$clientData$url_search)
    stockCode<-query$stockCode
    fromDate<-query$fromDate
    toDate<-query$toDate
    ashi<-query$ashi
    table<-get_tablename(ashi)

    con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
    res<-dbGetQuery(con, "set names utf8")
    
    data.lines<-fetch(dbSendQuery(con,paste("select * from elliott where stockCode='",stockCode,"' and date1>='",fromDate,"' and date9<='",toDate,"' and ashi='",ashi,"' order by date9 asc",sep="")),-1)
    res<-dbSendQuery(con,paste("select date as Date,oprice as Open,high as High,low as low,cprice Close,volume as Volume from live.",table," where stockCode='",stockCode,"' and date between '",fromDate,"' and '",toDate,"'",sep=""))
    data.df<-fetch(res,-1)
    data.df$Date<-as.POSIXct(data.df$Date)
    data.zoo<-read.zoo(data.df)
    
    dbDisconnect(con)
    
    # draw chart
    candleChart(data.zoo,theme="white",plot=F)
  
    # trend line
    l<-c()
    for(i in 1:length(data.lines$stockCode)){
      d<-data.lines[i,]
  
#      l<-c(l,read.zoo(make_elliott(data.df,d)))
      l<-read.zoo(make_elliott(data.df,d))
      plot(addTA(l,legend=NULL,on = 1,col=i,type="l"))
    }
#    for(i in 1:length(l)){
#      plot(addTA(l[i],legend=NULL,on = 1,col=i,type="l"))
#    }
  })

  output$stockName<- renderText({
    query <- parseQueryString(session$clientData$url_search)
    stockCode<-query$stockCode
    con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
    res<-dbGetQuery(con, "set names utf8")
    res<-dbSendQuery(con,paste("select m.stockCode,m.englishName from live.stockMasterFull m where m.stockCode='",stockCode,"'",sep=""))
    data.lines<-fetch(res,-1)
    dbDisconnect(con)
    paste("<h3>(",stockCode,")",data.lines[1,]$englishName,"</h3>",sep="")
  })





  output$patternData <- renderDataTable({
    query <- parseQueryString(session$clientData$url_search)
    stockCode<-query$stockCode
    fromDate<-query$fromDate
    toDate<-query$toDate
    ashi<-query$ashi
    
    con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
    res<-dbGetQuery(con, "set names utf8")

    data.lines<-fetch(dbSendQuery(con,paste("select ashi,zigzag,date_format(date1,'%Y-%m-%d') as date1,date_format(date2,'%Y-%m-%d') as date2,date_format(date3,'%Y-%m-%d') as date3,date_format(date4,'%Y-%m-%d') as date4,date_format(date5,'%Y-%m-%d') as date5,date_format(date6,'%Y-%m-%d') as date6,date_format(date7,'%Y-%m-%d') as date7,date_format(date8,'%Y-%m-%d') as date8,date_format(date9,'%Y-%m-%d') as date9 from elliott where stockCode='",stockCode,"' and date1>='",fromDate,"' and date9<='",toDate,"' and ashi='",ashi,"' order by date9 asc",sep="")),-1)
    dbDisconnect(con)
    return(data.lines)
  },escape=F,options = list(pageLength = 20))

})
