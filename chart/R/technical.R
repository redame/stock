library(quantmod)
library(RMySQL)
library(xts)

con<-dbConnect(dbDriver("MySQL"),dbname="live",host="zaaa16d.qr.com",user="root")
price_getter<-function(code){
  data.res<-dbSendQuery(con,paste("select date as Date,oprice as Open,high as High,low as Low,cprice as Close,volume as Volume from live.ST_priceHistAdj where stockCode='",code,"'",sep=""))
  data.price<-fetch(data.res,n=-1)
  return(data.price)
}

calc_macd<-function(data.price,code){
  data.macd<-MACD(Cl(data.price))
  for(i in 1:(length(data.macd[,1])-1)){
    if(is.na(data.macd[i,1]) || is.na(data.macd[i,2]) || is.na(data.macd[i+1,1]) || is.na(data.macd[i+1,2])){
      next
    }
    sql<-NULL
    if(data.macd[i,1]<data.macd[i,2] && data.macd[i+1,1]>data.macd[i+1,2] && data.macd[i+1,1]<0 && data.macd[i+1,2]<0){
      sql<-paste("replace into fintech.technicalSignal values('",code,"','",data.price[i+1,]$Date,"','macd','buy')",sep="")
    }
    if(data.macd[i,1]>data.macd[i,2] && data.macd[i+1,1]<data.macd[i+1,2] && data.macd[i+1,1]>0 && data.macd[i+1,2]>0){
      sql<-paste("replace into fintech.technicalSignal values('",code,"','",data.price[i+1,]$Date,"','macd','sell')",sep="")
    }
    if(!is.null(sql)){
      dbSendQuery(con,sql)
    }
  }
}
calc_rsi<-function(data.price,code){
  data.rsi<-RSI(Cl(data.price))
  for(i in 1:(length(data.rsi))){
    if(is.na(data.rsi[i])){
      next
    }
    sql<-NULL
    if(data.rsi[i]<30){
      sql<-paste("replace into fintech.technicalSignal values('",code,"','",data.price[i,]$Date,"','rsi','buy')",sep="")
    }
    if(data.rsi[i]>70){
      sql<-paste("replace into fintech.technicalSignal values('",code,"','",data.price[i,]$Date,"','rsi','sell')",sep="")
    }
    if(!is.null(sql)){
      dbSendQuery(con,sql)
    }
  }
}

calc_sma<-function(data.price,code){
  data.sma5<-SMA(Cl(data.price),n=5)
  data.sma25<-SMA(Cl(data.price),n=25)
  data.sma75<-SMA(Cl(data.price),n=75)
  calc_sma_check(code,data.sma5,data.sma25,"smashort")
  calc_sma_check(code,data.sma25,data.sma75,"smalong")
}
calc_sma_check<-function(code,data.smas,data.smal,key){
  for(i in 1:(length(data.smas)-1)){
    if(is.na(data.smas[i]) || is.na(data.smal[i]) || is.na(data.smas[i+1]) || is.na(data.smal[i+1])){
      next
    }
    sql<-NULL
    if(data.smas[i]<data.smal[i] && data.smas[i+1]>data.smal[i+1]){
      sql<-paste("replace into fintech.technicalSignal values('",code,"','",data.price[i+1,]$Date,"','",key,"','buy')",sep="")
    }
    if(data.smas[i]>data.smas[i] && data.sma[i+1]<data.sma[i+1]){
      sql<-paste("replace into fintech.technicalSignal values('",code,"','",data.price[i+1,]$Date,"','",key,"','sell')",sep="")
    }
    if(!is.null(sql)){
      dbSendQuery(con,sql)
    }
  }
}

calc_stochastics<-function(data.price,code){
  data.stoch<-stoch(HLC(data.price))
  for(i in 1:(length(data.stoch[,1])-1)){

    if(is.na(data.stoch[i,1]) || is.na(data.stoch[i,2]) || is.na(data.stoch[i,3]) || is.na(data.stoch[i+1,1]) || is.na(data.stoch[i+1,2]) || is.na(data.stoch[i+1,3])){
      next
    }

    # fast
    sql<-NULL
    if(data.stoch[i,1]<data.stoch[i,2] && data.stoch[i+1,1]>data.stoch[i+1,2] && data.stoch[i+1,1]<0.2 && data.stoch[i+1,2]<0.2){
      sql<-paste("replace into fintech.technicalSignal values('",code,"','",data.price[i+1,]$Date,"','fstoch','buy')",sep="")
    }
    if(data.stoch[i,1]>data.stoch[i,2] && data.stoch[i+1,1]<data.stoch[i+1,2] && data.stoch[i+1,1]>0.8 && data.stoch[i+1,2]>0.8){
      sql<-paste("replace into fintech.technicalSignal values('",code,"','",data.price[i+1,]$Date,"','fstoch','sell')",sep="")
    }
    if(!is.null(sql)){
      dbSendQuery(con,sql)
    }

    # slow
    sql<-NULL
    if(data.stoch[i,2]<data.stoch[i,3] && data.stoch[i+1,2]>data.stoch[i+1,3] && data.stoch[i+1,2]<0.2 && data.stoch[i+1,3]<0.2){
      sql<-paste("replace into fintech.technicalSignal values('",code,"','",data.price[i+1,]$Date,"','sstoch','buy')",sep="")
    }
    if(data.stoch[i,2]>data.stoch[i,3] && data.stoch[i+1,2]<data.stoch[i+1,3] && data.stoch[i+1,2]>0.8 && data.stoch[i+1,3]>0.8){
      sql<-paste("replace into fintech.technicalSignal values('",code,"','",data.price[i+1,]$Date,"','sstoch','sell')",sep="")
    }
    if(!is.null(sql)){
      dbSendQuery(con,sql)
    }
  }
}



data.res<-dbSendQuery(con,"select stockCode from stockMasterFull")
data.code<-fetch(data.res,n=-1)

for(code in data.code$stockCode){
  data.price<-price_getter(code)
  calc_macd(data.price,code)
  calc_rsi(data.price,code)
  calc_sma(data.price,code)
  calc_stochastics(data.price,code)
}


dbDisconnect(con)

