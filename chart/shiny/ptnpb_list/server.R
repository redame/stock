library(shiny)
library(quantmod)
library(RMySQL)
library(zoo)
library(digest)
# 日本語


createPtnLink<-function(ptn,ashi){
  sprintf('<a href="../ptnpb_list/?ptn=%s&ashi=%s"  class="btn btn-primary">Link</a>',ptn,ashi)
}
createChartLink<-function(ptn,stockCode,ashi,pb_term,line1_stDate,line1_edDate){
  sprintf('<a href="../ptnpb_chart/?ptn=%s&stockCode=%s&ashi=%s&pb_term=%s&line1_stDate=%s&line1_edDate=%s"  class="btn btn-primary">Link</a>',ptn,stockCode,ashi,pb_term,line1_stDate,line1_edDate)
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
    res<-dbSendQuery(con,paste("select ptn,ashi,cnt from ptnPBListCntView where ashi='",ashi,"'",sep=""))
    data.df<-fetch(res,-1)
    data.table<-data.frame(ptn=data.df$ptn,ashi=data.df$ashi,cnt=data.df$cnt)
    data.table$link<-createPtnLink(data.df$ptn,data.df$ashi)
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

  output$ptnList <- renderDataTable({
    query <- parseQueryString(session$clientData$url_search)
    if (length(query)==0){
      return(NULL)
    }

    ptn<-query$ptn
    if(is.null(ptn)){
      return(NULL)
    }
    ashi<-query$ashi
    if(is.null(ashi)){
      ashi<-"d"
    }

    con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
    res<-dbGetQuery(con, "set names utf8") 
    res<-dbSendQuery(con,paste("select stockCode,ashi,pb_term,date_format(date_from,'%Y-%m-%d') as date_from,date_format(line1_stDate,'%Y-%m-%d') as line1_stDate,date_format(line1_edDate,'%Y-%m-%d') as line1_edDate from ",ptn," where ashi='",ashi,"' order by line1_stDate desc",sep=""))
    data.df<-fetch(res,-1)
    data.table<-data.frame(stockCode=data.df$stockCode,ashi=data.df$ashi,pb_term=data.df$pb_term,date_from=data.df$date_from)
    data.table$link<-createChartLink(ptn,data.df$stockCode,data.df$ashi,data.df$pb_term,data.df$line1_stDate,data.df$line1_edDate)
    dbDisconnect(con)
    return(data.table)
  },escape=F,options = list(pageLength = 20))

})


