library(quantmod)
library(RSQLite)

calcAll<-function(stock.hist,code){
  calcTech<-function(stock.hist,term,n){
    tech<-NA
    tryCatch({
      tech<-BBnands(stock.hist[,2],n=term,sd=n)
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
  term<-20
  if(length(stock.hist[,2])>0){ 
    stock.code<-rep(code,times=length(stock.hist[,2]))
    stock.n<-calcTech(stock.hist,term,0)
    stock.ps<-calcTech(stock.hist,term,1)
    stock.pm<-calcTech(stock.hist,term,2)
    stock.pl<-calcTech(stock.hist,term,3)
    stock.ns<-calcTech(stock.hist,term,-1)
    stock.nm<-calcTech(stock.hist,term,-2)
    stock.nl<-calcTech(stock.hist,term,-3)
    stock.tech<-data.frame(date=stock.hist[,1],code=stock.code,n=stock.n,ps=stock.ps,pm=stock.pm,pl=stock.pl,ns=stock.ns,nm=stock.nm,nl=stock.nl)
    write.table(stock.tech,file=paste("/home/pi/stock/work/bband.txt",sep=""),col.names=F,row.names=F,quote=F,sep="\t",na="",append=T)
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
    calcAll(stock.hist,code)
  },
  error=function(e){
    message(e)
  })
}


