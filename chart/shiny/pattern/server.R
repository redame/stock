library(shiny)
library(quantmod)
library(RMySQL)
library(zoo)
library(digest)
# 日本語


createPatternLink<-function(data.patternId){
  sprintf('<a href="../pattern/?patternId=%s"  class="btn btn-primary">Link</a>',data.patternId)
}

createChartLink<-function(data.patternId,ata.lineId){
  sprintf('<a href="../chart/?patternId=%s&lineId=%s"  class="btn btn-primary">Link</a>',data.patternId,data.lineId)
}



# Define server logic required to draw a histogram
shinyServer(function(input, output,session) {

  output$patternImage<- renderText({
    query <- parseQueryString(session$clientData$url_search)
    if(length(query)>0){
      paste("<img src='../images/pattern/chartpattern-",query$patternId,".gif'>",sep="")
    }
  })
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
      res<-dbSendQuery(con,paste("select stockCode,signalTime,price,upDownFlag,lineID from chartPatternSignal where patternId='",query$patternId,"' order by signalTime desc",sep=""))
      data.df<-fetch(res,-1)
      data.table<-data.frame(signalTime=data.df$signalTime,stockCode=data.df$stockCode,price=data.df$price,upDownFlag=data.df$upDownFlag)
      data.table$link<-createChartLink(query$patternId,data.df$lineID)

    }else{
      res<-dbSendQuery(con,"select m.id,m.description,count(s.stockCode) as count from patternMaster m left outer join chartPatternSignal s on m.id=s.patternId group by m.id")
      data.df<-fetch(res,-1)
      data.table<-data.frame(id=data.df$id,description=data.df$description,count=data.df$count)
      data.table$link<-createPatternLink(data.df$id)
     }
    #data.table$stock<-createStockLink(data.df$stockCode)
    dbDisconnect(con)
    return(data.table)
  },escape=F,options = list(pageLength = 20))

})
