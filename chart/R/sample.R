library(RMySQL)
con<-dbConnect(dbDriver("MySQL"),host="zaaa16d.qr.com",user="root",password="",dbname="live")

stockCode<-"6758"
#}
cat(stockCode)
dataTerm<-180
rsquared.min<-0.95
stockTerm<-'daily'
peakBottomTerm<-5
pngDir<-"png/"
#########
Sys.setenv(http_proxy="http://zaan15p.qr.com:8080")
library(quantmod)
library(RFinanceYJ)
library(RCurl)


source("lib/peakBottom.R")
source("lib/trendLine.R")
source("lib/trendLineDataInsert.R")
source("lib/chartBox.R")

####################
today<-Sys.Date()
sinceDate<-today-dataTerm #
fromDate<-"2000-01-01"
toDate<-"2010-12-31"
#stockData<-sktStockTsData(stockCode,since="2014-01-01",date.end="2015-01-31")
tmp<-dbSendQuery(con,paste("select date,oprice,high,low,cprice,volume from ST_priceHistAdj where stockCode='",stockCode,"' and date between='",fromDate,"' and '",toDate,"' order by date asc",sep=""))
stockData<-fetch(tmp,n=-1)

colnames(stockData)<-c("Date","Open","High","Low","Close","Volume")
stockData.zoo<-read.zoo(stockData)

#############
peakBottom<-calcuratePeakBottom(stockData,peakBottomTerm) #daily

############
len<-length(stockData$Date)
peak.frame<-data.frame(Date=stockData$Date,Close=rep(NA,length=len))
for(i in 1:len){
  #cat("i=",i,",peak=",peakBottom$Peak[i],"\n")
  if(peakBottom$Peak[i]){
    peak.frame$Close[i]<-stockData$High[i]
  }
}

bottom.frame<-data.frame(Date=stockData$Date,Close=rep(NA,length=len))
for(i in 1:len){
  if(peakBottom$Bottom[i]){
    bottom.frame$Close[i]<-stockData$Low[i]
  }
}

#fileName<-paste(pngDir,stockCode,".png",sep="")
#png(fileName,width=600,height=400)
############# chart
candleChart(stockData.zoo,theme="white")
peak.zoo<-read.zoo(peak.frame)
addTA(peak.zoo,on=1,col='red',type='b')

bottom.zoo<-read.zoo(bottom.frame)
addTA(bottom.zoo,on=1,col='blue',type='b')


############# TrendLine create
supportTrendLine<-makeSupportTrendLine(stockData,peakBottom,rsquared.min)
if(!is.null(supportTrendLine)){
  trend.zoo<-convertTrendLineToZoo(stockData,supportTrendLine)
  trendLineDataInsert(stockCode,stockTerm,supportTrendLine,stockData,0,peakBottomTerm)
  addTA(trend.zoo,on=1,col='blue')
}

resistanceTrendLine<-makeResistanceTrendLine(stockData,peakBottom,rsquared.min)
if(!is.null(resistanceTrendLine)){
  trend.zoo<-convertTrendLineToZoo(stockData,resistanceTrendLine)
  trendLineDataInsert(stockCode,stockTerm,resistanceTrendLine,stockData,1,peakBottomTerm)
  addTA(trend.zoo,on=1,col='red')
}
