library(shiny)
library(quantmod)
library(RMySQL)
library(zoo)
library(digest)
# 日本語


createChartLink<-function(stockCode,fromDate,toDate,ashi){
  sprintf('<a href="../elliottpb_chart/?stockCode=%s&fromDate=%s&toDate=%s&ashi=%s"  class="btn btn-primary">chart</a>',stockCode,fromDate,toDate,ashi)
}



# Define server logic required to draw a histogram
shinyServer(function(input, output,session) {

  output$patternList <- renderDataTable({
    query <- parseQueryString(session$clientData$url_search)
    con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
    res<-dbGetQuery(con, "set names utf8") 

    res<-dbSendQuery(con,paste("select stockCode,ashi,pb_term,date1 as fromDate,date9  as toDate from elliottPB order by date9 desc",sep=""))
    data.df<-fetch(res,-1)
    data.table<-data.frame(stockCode=data.df$stockCode,pb_term=data.df$pb_term,fromDate=data.df$fromDate,toDate=data.df$toDate,ashi=data.df$ashi)
    data.table$link<-createChartLink(data.df$stockCode,data.df$fromDate,data.df$toDate,data.df$ashi)
    dbDisconnect(con)
    return(data.table)
  },escape=F,options = list(pageLength = 20))

})
