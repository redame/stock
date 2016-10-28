library(shiny)
library(quantmod)
library(RMySQL)
library(zoo)
library(digest)
# 日本語


createChartLink<-function(ptn,stockCode,ashi,pb_term,line1_stDate,line1_edDate,date_from,date_to,price_to){
  sprintf('<a href="../ptn_signal_chart/?ptn=%s&stockCode=%s&ashi=%s&pb_term=%s&line1_stDate=%s&line1_edDate=%s&date_from=%s&date_to=%s&price_to=%s"  class="btn btn-primary">Link</a>',ptn,stockCode,ashi,pb_term,line1_stDate,line1_edDate,date_from,date_to,price_to)
}



# Define server logic required to draw a histogram
shinyServer(function(input, output,session) {

  output$ptnAllList <- renderDataTable({
    query <- parseQueryString(session$clientData$url_search)
    ashi="d"
    if(length(query)!=0){
      ashi<-query$ashi
    }
    con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
    res<-dbGetQuery(con, "set names utf8") 
    res<-dbSendQuery(con,paste("select ptnNowPB,stockCode,pb_term,ashi,date_from,date_to,price_to,line1_stDate,line1_edDate from ptnNowPBListView where ashi='",ashi,"' order by date_to desc",sep=""))
    data.df<-fetch(res,-1)
    data.table<-data.frame(ptn=data.df$ptnNowPB,stockCode=data.df$stockCode,ashi=data.df$ashi,date_from=data.df$date_from,date_to=data.df$date_to)
    data.table$link<-createChartLink(data.df$ptn,data.df$stockCode,data.df$ashi,data.df$pb_term,data.df$line1_stDate,data.df$line1_edDate,data.df$date_from,data.df$date_to,data.df$price_to)
    dbDisconnect(con)
    return(data.table)
  },escape=F,options = list(pageLength = 20))

  output$ptnListName<-renderText({
    query <- parseQueryString(session$clientData$url_search)
    sprintf("<h3>%s</h3>",query$ptn)
  })

  output$ptnAshi<-renderText({
    query <- parseQueryString(session$clientData$url_search)
    ashi<-"Daily"
    if (length(query)>0){
      if(query$ashi=="w"){
        ashi<-"Weekly"
      }else{
        ashi<-"Monthly"
      }
    }
    sprintf("<h3>%s</h3>",ashi)
  })
})
