library(quantmod)
library(RSQLite)

calcMacd<-function(stock.hist,code){
  calcTech<-function(stock.hist){
    tech<-NA
    tryCatch({
      tech<-MACD(stock.hist[,2])
      return (tech)
    },
    error=function(e){
      len<-length(stock.hist[,2])
      msg<-paste("code=",code,",stock.hist=",len,",n=",n,sep="")
      message(msg)
      tech<-matrix(NA,ncol=len,nrow=1)
      return(tech)
    })
  }
  if(length(stock.hist[,2])>0){ 
    stock.code<-rep(code,times=length(stock.hist[,2]))
    stock.macd<-calcTech(stock.hist)
    stock.tech<-data.frame(date=stock.hist[,1],code=stock.code,macd=stock.macd[,1],signal=stock.macd[,2])
    write.table(stock.tech,file=paste("/home/pi/stock/work/macd.txt",sep=""),col.names=F,row.names=F,quote=F,sep="\t",na="",append=T)
  }
}

dbd<-dbDriver("SQLite")
dbcon<-dbConnect(dbd,dbname="/home/pi/stock/data/stock.db")
stock.master<-dbGetQuery(dbcon,"select * from stockMaster")
dbDisconnect(dbcon)
stock.from<-Sys.Date()-365*3

stock.master_len<-length(stock.master[,1])
for(i in 1:stock.master_len){
#for(i in 1:1){
  code<-stock.master[i,1]
  dbcon<-dbConnect(dbd,dbname="/home/pi/stock/data/stock.db")
  stock.hist<-dbGetQuery(dbcon,paste("select date,adj_close,volume from histDaily where code='",code,"'",sep=""))
  dbDisconnect(dbcon)
  message(paste("code=",code,",len=",length(stock.hist[,1]),sep=""))
  tryCatch({
    calcMacd(stock.hist,code)
  },
  error=function(e){
    message(e)
  })
}


