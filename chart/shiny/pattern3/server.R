library(shiny)
library(quantmod)
library(RMySQL)
library(zoo)
library(digest)
# 日本語


createPatternLink<-function(data.patternId){
  sprintf('<a href="../pattern3/?patternId=%s"  class="btn btn-primary">Link</a>',data.patternId)
}

createChartLink<-function(data.patternId,data.lineId){
  sprintf('<a href="../chart3/?patternId=%s&lineId=%s"  class="btn btn-primary">Link</a>',data.patternId,data.lineId)
}



# Define server logic required to draw a histogram
shinyServer(function(input, output,session) {

  output$patternImage<- renderText({
    query <- parseQueryString(session$clientData$url_search)
    if(length(query)>0){
      paste("<img src='../images/pattern/chartpattern-",query$patternId,".gif'>",sep="")
    }
  })
  output$patternNow<-renderDataTable({
    query <- parseQueryString(session$clientData$url_search)
    if (length(query)>0){
      return(NULL)
    }
    con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
    res<-dbGetQuery(con, "set names utf8") 
    res<-dbSendQuery(con,paste("select s.patternId,s.stockCode,s.signalTime,s.price,s.upDownFlag,s.lineId,m.description from patternMaster m left outer join chartSignal s on m.id=s.patternId where signalTime=(select max(signalTime) from chartSignal) order by patternId,stockCode ",sep=""))
    data.df<-fetch(res,-1)
    data.table<-data.frame(id=data.df$patternId,description=data.df$description,signalTime=data.df$signalTime,stockCode=data.df$stockCode,price=data.df$price,upDownFlag=data.df$upDownFlag)
    data.table$link<-createChartLink(data.df$patternId,data.df$lineId)
    dbDisconnect(con)
    return(data.table)
  },escape=F,options = list(pageLength = 20))


  output$patternDescription<-renderText({
    query <- parseQueryString(session$clientData$url_search)
    con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
    res<-dbGetQuery(con, "set names utf8") 
    res<-dbSendQuery(con,paste("select description from patternMaster where id='",query$patternId,"'",sep=""))
    data.df<-fetch(res,-1)
    dbDisconnect(con)
    data.df$description
  })

  output$patternView <- renderDataTable({
    query <- parseQueryString(session$clientData$url_search)
    con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
    res<-dbGetQuery(con, "set names utf8") 

    if (length(query)>0){
      res<-dbSendQuery(con,paste("select stockCode,signalTime,price,upDownFlag,lineID from chartSignal where patternId='",query$patternId,"' order by signalTime desc",sep=""))
      data.df<-fetch(res,-1)
      data.table<-data.frame(signalTime=data.df$signalTime,stockCode=data.df$stockCode,price=data.df$price,upDownFlag=data.df$upDownFlag)
      data.table$link<-createChartLink(query$patternId,data.df$lineID)

    }else{
      res<-dbSendQuery(con,"select m.id,m.description,count(s.stockCode) as count from patternMaster m left outer join chartSignal s on m.id=s.patternId group by m.id")
      data.df<-fetch(res,-1)
      data.table<-data.frame(id=data.df$id,description=data.df$description,count=data.df$count)
      data.table$link<-createPatternLink(data.df$id)
     }
    #data.table$stock<-createStockLink(data.df$stockCode)
    dbDisconnect(con)
    return(data.table)
  },escape=F,options = list(pageLength = 20))

})
