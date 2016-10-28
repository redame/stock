library(shiny)
library(quantmod)
library(RMySQL)
library(zoo)
library(digest)

#options(shiny.trace = TRUE)
# 日本語

date_interval<-function(ashi,date_from,date_to){
  interval_num<-30
  interval<-"day"
  if (ashi=="w"){
    interval<-"week"
  }else if (ashi=="m"){
    interval="month"
  }
  fm_day<-paste("date_add('",date_from,"',interval -",interval_num," ",interval,")",sep="")
  to_day<-paste("date_add('",date_to,"', interval ",interval_num," ",interval,")",sep="")
  return (c(fm_day,to_day))
}


make_ptn_line<-function(ohlc,con,stockCode,date_from,date_to,zigzag,ashi,table,col){
  dt<-date_interval(ashi,date_from,date_to)
  query<-paste("select * from ",table," where stockCode='",stockCode,"' and zigzag=",zigzag," and date_from>=",dt[1]," and date_to<=",dt[2]," and ashi='",ashi,"'  ",sep="")
  cat(file=stderr(),query,"\n")
  lines<-fetch(dbSendQuery(con,query),n=-1)
  cat(file=stderr(),"table=",table,",len=",length(lines$stockCode),"\n")
  
  if(length(lines$stockCode)>0){
    for(i in 1:length(lines$stockCode)){
      tl<-data.frame(Date=as.POSIXct(ohlc$Date),Close=rep(NA,length=length(ohlc$Date)))
      line<-lines[i,]
      tl<-make_trendline(tl,line$date_pre,line$price_pre,line$date_from,line$price_from)
      tl<-make_trendline(tl,line$date_from,line$price_from,line$date2,line$price2)
      if(length(line$date4)>0){
        tl<-make_trendline(tl,line$date2,line$price2,line$date3,line$price3)
        tl<-make_trendline(tl,line$date3,line$price3,line$date4,line$price4)
        tl<-make_trendline(tl,line$date4,line$price4,line$date_to,line$price_to)
      }else if(length(line$date3)>0){
        tl<-make_trendline(tl,line$date2,line$price2,line$date3,line$price3)
        tl<-make_trendline(tl,line$date3,line$price3,line$date_to,line$price_to)
      }else{
        tl<-make_trendline(tl,line$date2,line$price2,line$date_to,line$price_to)
      }
      tl<-make_trendline(tl,line$date_to,line$price_to,line$date_post,line$price_post)
      plot(addTA(read.zoo(tl),legend=NULL,on = 1,col=col,type="l"))


      # upper lower line
      tl<-data.frame(Date=as.POSIXct(ohlc$Date),Close=rep(NA,length=length(ohlc$Date)))
      tl<-make_trendline(tl,line$line1_stDate,line$line1_stPrice,line$line1_edDate,line$line1_edPrice)
      plot(addTA(read.zoo(tl),legend=NULL,on = 1,col=col,type="l"))
      cat(file=stderr(),"line2_stDate=",length(line$line2_stDate),"\n")
      if(length(line$line2_stDate)>0){
        tl<-data.frame(Date=as.POSIXct(ohlc$Date),Close=rep(NA,length=length(ohlc$Date)))
        tl<-make_trendline(tl,line$line2_stDate,line$line2_stPrice,line$line2_edDate,line$line2_edPrice)
        plot(addTA(read.zoo(tl),legend=NULL,on = 1,col=col,type="l"))
        cat(file=stderr(),"line2_stDate=",length(line$line2_stDate),"\n")
      }
    }
  }
}

make_ptn<-function(ohlc,con,stockCode,date_from,date_to,zigzag,ashi){
  make_ptn_line(ohlc,con,stockCode,date_from,date_to,zigzag,ashi,"ptnDoubleBottom",1)
  make_ptn_line(ohlc,con,stockCode,date_from,date_to,zigzag,ashi,"ptnDoubleTop",2)
  make_ptn_line(ohlc,con,stockCode,date_from,date_to,zigzag,ashi,"ptnDownChannel",3)
  make_ptn_line(ohlc,con,stockCode,date_from,date_to,zigzag,ashi,"ptnFallingTriangle",4)
  make_ptn_line(ohlc,con,stockCode,date_from,date_to,zigzag,ashi,"ptnFallingWedge",5)
  make_ptn_line(ohlc,con,stockCode,date_from,date_to,zigzag,ashi,"ptnHeadAndShoulderBottom",6)
  make_ptn_line(ohlc,con,stockCode,date_from,date_to,zigzag,ashi,"ptnHeadAndShoulderTop",13)
  make_ptn_line(ohlc,con,stockCode,date_from,date_to,zigzag,ashi,"ptnRisingTriangle",8)
  make_ptn_line(ohlc,con,stockCode,date_from,date_to,zigzag,ashi,"ptnRisingWedge",9)
  make_ptn_line(ohlc,con,stockCode,date_from,date_to,zigzag,ashi,"ptnTripleBottom",10)
  make_ptn_line(ohlc,con,stockCode,date_from,date_to,zigzag,ashi,"ptnTripleTop",11)
  make_ptn_line(ohlc,con,stockCode,date_from,date_to,zigzag,ashi,"ptnUpChannel",12)

}
make_trendline<-function(tl,fdate,fprice,tdate,tprice){
  cat(file=stderr(),"fdate=",fdate,",fprice=",fprice,",tdate=",tdate,",tprice=",tprice,"\n")
  data.ts<-as.POSIXct(c(fdate,tdate))
  data.price<-c(fprice,tprice)
  data.cnt<-0
  for(i in 1:length(tl$Date)){
    #cat(file=stderr(),"tl=",tl[i,]$Date,",data.ts[1]=",data.ts[1],",",data.ts[2],"\n")
    if( (tl[i,]$Date >= data.ts[1]) && (tl[i,]$Date <= data.ts[2])){
      data.cnt<-data.cnt+1
    }
  }
  data.a<-(data.price[2]-data.price[1])/data.cnt  # 傾き
  data.k<-0
  for(i in 1:length(tl$Date)){
    if( (tl[i,]$Date >= data.ts[1]) && (tl[i,]$Date <= data.ts[2])){
      tl[i,]$Close<-data.price[1]+data.a*data.k
      data.k<-data.k+1
    }
  }
  return(tl)
}

get_tablename<-function(ashi){
  if (ashi=="w"){
    return ("ST_priceHistWeekly")
  }else if(ashi=="m"){
    return ("ST_priceHistMonthly")
  }else{
    return ("ST_priceHistAdj")
  }
}

shinyServer(function(input, output, session) {

  output$returnButton<- renderText({
    query <- parseQueryString(session$clientData$url_search)
    str<-sprintf('<a href="../ptn_list/?ptn=%s&ashi"  class="btn btn-primary">Back</a>',query$ptn,query$ashi)
    paste(str)
  })

  output$patternDescription <- renderText({
    query <- parseQueryString(session$clientData$url_search)
    paste("<h5>",query$ptn,",",query$ashi,"</h5>",sep="")
  })


  output$stockChart <- renderPlot({
    query <- parseQueryString(session$clientData$url_search)
    stockCode<-query$stockCode
    line1_stDate<-query$line1_stDate
    line1_edDate<-query$line1_edDate
    zigzag<-query$zigzag
    ashi<-query$ashi
    ptn<-query$ptn
    table<-get_tablename(ashi)

    con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
    res<-dbGetQuery(con, "set names utf8")

    dt<-date_interval(ashi,line1_stDate,line1_edDate)
    res<-dbSendQuery(con,paste("select date as Date,oprice as Open,high as High,low as low,cprice Close,volume as Volume from live.",table," where stockCode='",stockCode,"' and date between ",dt[1]," and ",dt[2],sep=""))
    ohlc<-fetch(res,-1)
    ohlc$Date<-as.POSIXct(ohlc$Date)
    ohlc.zoo<-read.zoo(ohlc)


    # draw chart
    candleChart(ohlc.zoo,theme="white",plot=F)
    #candleChart(ohlc.zoo,theme="white")
    make_ptn(ohlc,con,stockCode,line1_stDate,line1_edDate,zigzag,ashi)
    dbDisconnect(con)
  })

  output$stockName<- renderText({
    query <- parseQueryString(session$clientData$url_search)
    con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
    res<-dbGetQuery(con, "set names utf8")
    res<-dbSendQuery(con,paste("select m.stockCode,m.englishName from live.stockMasterFull m  where m.stockCode='",query$stockCode,"'",sep=""))
    data.lines<-fetch(res,-1)
    dbDisconnect(con)
    paste("<h3>",data.lines[1,]$englishName,"</h3>",sep="")
  })


  output$ptnList<-renderDataTable({
    query <- parseQueryString(session$clientData$url_search)
    con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
    res<-dbGetQuery(con, "set names utf8") 

    ptn<-query$ptn
    ashi<-query$ashi
    stockCode<-query$stockCode
    zigzag<-query$zigzag
    line1_stDate<-query$line1_stDate
    line1_edDate<-query$line1_edDate

    dt<-date_interval(ashi,line1_stDate,line1_edDate)
    #cat(file=stderr(),dt)
    query<-paste(
"select  'ptnDoubleBottom' as ptn,stockCode,zigzag,ashi,date_from,date_to from ptnDoubleBottom where stockCode='",stockCode,"' and date_from>=",dt[1]," and date_to<=",dt[2]," and ashi='",ashi,"' and zigzag=",zigzag," union ",
"select  'ptnDoubleTop' as ptn,stockCode,zigzag,ashi,date_from,date_to from ptnDoubleTop where stockCode='",stockCode,"' and date_from>=",dt[1]," and date_to<=",dt[2]," and ashi='",ashi,"' and zigzag=",zigzag," union ",
"select  'ptnDownChannel' as ptn,stockCode,zigzag,ashi,date_from,date_to from ptnDownChannel where stockCode='",stockCode,"' and date_from>=",dt[1]," and date_to<=",dt[2]," and ashi='",ashi,"' and zigzag=",zigzag," union ",
"select  'ptnFallingTriangle' as ptn,stockCode,zigzag,ashi,date_from,date_to from ptnFallingTriangle where stockCode='",stockCode,"' and date_from>=",dt[1]," and date_to<=",dt[2]," and ashi='",ashi,"' and zigzag=",zigzag," union ",
"select  'ptnFallingWedge' as ptn,stockCode,zigzag,ashi,date_from,date_to from ptnFallingWedge where stockCode='",stockCode,"' and date_from>=",dt[1]," and date_to<=",dt[2]," and ashi='",ashi,"' and zigzag=",zigzag," union ",
"select  'ptnHeadAndShoulderBottom' as ptn,stockCode,zigzag,ashi,date_from,date_to from ptnHeadAndShoulderBottom where stockCode='",stockCode,"' and date_from>=",dt[1]," and date_to<=",dt[2]," and ashi='",ashi,"' and zigzag=",zigzag," union ",
"select  'ptnHeadAndShoulderTop' as ptn,stockCode,zigzag,ashi,date_from,date_to from ptnHeadAndShoulderTop where stockCode='",stockCode,"' and date_from>=",dt[1]," and date_to<=",dt[2]," and ashi='",ashi,"' and zigzag=",zigzag," union ",
"select  'ptnRisingTriangle' as ptn,stockCode,zigzag,ashi,date_from,date_to from ptnRisingTriangle where stockCode='",stockCode,"' and date_from>=",dt[1]," and date_to<=",dt[2]," and ashi='",ashi,"' and zigzag=",zigzag," union ",
"select  'ptnRisingWedge' as ptn,stockCode,zigzag,ashi,date_from,date_to from ptnRisingWedge where stockCode='",stockCode,"' and date_from>=",dt[1]," and date_to<=",dt[2]," and ashi='",ashi,"' and zigzag=",zigzag," union ",
"select  'ptnTripleBottom' as ptn,stockCode,zigzag,ashi,date_from,date_to from ptnTripleBottom where stockCode='",stockCode,"' and date_from>=",dt[1]," and date_to<=",dt[2]," and ashi='",ashi,"' and zigzag=",zigzag," union ",
"select  'ptnTripleTop' as ptn,stockCode,zigzag,ashi,date_from,date_to from ptnTripleTop where stockCode='",stockCode,"' and date_from>=",dt[1]," and date_to<=",dt[2]," and ashi='",ashi,"' and zigzag=",zigzag," union ",
"select  'ptnUpChannel' as ptn,stockCode,zigzag,ashi,date_from,date_to from ptnUpChannel  where stockCode='",stockCode,"' and date_from>=",dt[1]," and date_to<=",dt[2]," and ashi='",ashi,"' and zigzag=",zigzag,
sep="")

    #cat(file=stderr(),query,"\n")

    data.df<-fetch(dbSendQuery(con,query),n=-1)
    data.table<-data.frame(ptn=data.df$ptn,stockCode=data.df$stockCode,ashi=data.df$ashi,zigzag=data.df$zigzag,date_from=data.df$date_from,date_to=data.df$date_to)
    dbDisconnect(con)
    return(data.table)
  },escape=F,options = list(pageLength = 20))


})
