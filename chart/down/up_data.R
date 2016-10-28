#比較用
Sys.setenv("http_proxy"="http://zaan15p.qr.com:8080")
library(RMySQL)
STEP<-5   # term to calculate return
LIMIT<-0.2 # upper limit of return
BETATERM<-250
OUTFILE<-"up.txt"
if(file.exists(OUTFILE)){
  file.remove(OUTFILE)
}

# beta calculated by 250 days
calc_beta<-function(data.prices,i){
  # https://books.google.co.jp/books?id=sKWiDAAAQBAJ&pg=PT162&lpg=PT162&dq=%E6%A0%AA%E4%BE%A1beta+r+%E8%A8%88%E7%AE%97&source=bl&ots=8XxgtJkKYZ&sig=1yX_5fN6AYWZW1ad6W_VonkY8cQ&hl=ja&sa=X&ved=0ahUKEwiagrax9I_OAhXJopQKHYzYCPUQ6AEIQjAI#v=onepage&q=%E6%A0%AA%E4%BE%A1beta%20r%20%E8%A8%88%E7%AE%97&f=false
  data.tmp<-data.prices[i:(i+BETATERM),]
  ret.stock<--diff(data.tmp$stock)/data.tmp[-1,]$stock
  ret.topix<--diff(data.tmp$topix)/data.tmp[-1,]$topix
  ret.lm<-lm(ret.stock ~ ret.topix)
  #summary(ret.lm)
  beta<-ret.lm$coefficients[2]
  return(beta)
}
check_after<-function(i,n,data.prices,beta){
  after.stock<-(data.prices[i-n,]$stock-data.prices[i,]$stock)/data.prices[i,]$stock
  after.topix<-(data.prices[i-n,]$topix-data.prices[i,]$topix)/data.prices[i,]$topix
  return(after.stock-after.topix*beta)
}
check_data<-function(con,stockCode){
  query<-paste("select p.date,p.cprice as stock,i.cprice as topix from ST_priceHistAdj p inner join indexHist i on p.date=i.date where i.indexCode='751' and p.date>='2000-01-04' and p.date<='2010-12-31' and p.stockCode='",stockCode,"' order by date desc",sep="")
  tmp<-dbSendQuery(con,query)
  data.prices<-fetch(tmp,n=-1)

  siz<-(length(data.prices$date)-BETATERM-1)
  cat(paste("siz=",siz,"\n",sep=""))
  if(siz>0){
    for(i in 21:siz){
      data.now<-data.prices[i,]
      data.prev<-data.prices[i+STEP,]

      ret.stock<-(data.now$stock-data.prev$stock)/data.prev$stock
      ret.topix<-(data.now$topix-data.prev$topix)/data.prev$topix
      if(length(ret.stock)==0){
        next
      }
      beta<-calc_beta(data.prices,i)
      ret<-ret.stock-ret.topix*beta
      cat(paste("stockCode:",stockCode,",date=",data.prev$date,",i=",i,",",length(data.prices$date),",",ret.stock,",",ret.topix,",","ret=",ret,",beta=",beta,"\n",sep=""))
      if(ret>LIMIT){ # up
        data.ret5<-check_after(i,5,data.prices,beta)
        data.ret10<-check_after(i,10,data.prices,beta)
        data.ret15<-check_after(i,15,data.prices,beta)
        data.ret20<-check_after(i,20,data.prices,beta)
        out<-file(OUTFILE,"a")
        tmp<-paste(stockCode,beta,data.now$date,data.now$topix,data.now$stock,data.prev$date,data.prev$topix,data.prev$stock,ret,data.prices[i-5,]$date,data.prices[i-5,]$stock,data.ret5,data.prices[i-10,]$date,data.prices[i-10,]$stock,data.ret10,data.prices[i-15,]$date,data.prices[i-15,]$stock,data.ret15,data.prices[i-20,]$date,data.prices[i-20,]$stock,data.ret20,sep="\t")

        writeLines(tmp,out,sep="\n")
        close(out)
      }
    }
  }
}

con<-dbConnect(dbDriver("MySQL"),host="zaaa16d",user="root",password="",dbname="live")
data.stockCodes<-fetch(dbSendQuery(con,"select distinct stockCode from ST_priceHistAdj"),n=-1)
for(stockCode in data.stockCodes$stockCode){
  check_data(con,stockCode)
}


dbDisconnect(con)
