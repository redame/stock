#CREATE TABLE `stockAutoTrendLine` (
#  `validDate` datetime NOT NULL,
#  `stockCode` varchar(8) NOT NULL,
#  `stockTerm` varchar(10) NOT NULL,
#  `peakBottomTerm` int(11) DEFAULT NULL,
#  `isPeak` int(11) DEFAULT NULL,
#  `peakBottomCount` int(11) DEFAULT NULL,
#  `startDate` datetime DEFAULT NULL,
#  `startPrice` double DEFAULT NULL,
#  `endDate` datetime DEFAULT NULL,
#  `endPrice` double DEFAULT NULL,
#  `gradient` double DEFAULT NULL,
#  `intercept` double DEFAULT NULL,
#  `rsquared` double DEFAULT NULL,
#  KEY `idx_stockAutoTrendLine` (`stockCode`,`stockTerm`,`isPeak`)
#)
#
#CREATE TABLE `stockAutoTrendLinePoints` (
#  `validDate` datetime NOT NULL,
#  `stockCode` varchar(8) NOT NULL,
#  `stockTerm` varchar(10) NOT NULL,
#  `isPeak` int(11) DEFAULT NULL,
#  `date` datetime DEFAULT NULL,
#  `price` double DEFAULT NULL,
#  `predictPrice` double DEFAULT NULL,
#  UNIQUE KEY `idx_stockAutoTrendLinePoints` (`stockCode`,`stockTerm`,`isPeak`,`date`)
#)

trendLineDataInsert<-function(stockCode,stockTerm,trendLine,stockData,isPeak,peakBottomTerm){
	today<-Sys.Date()
	library(RMySQL)
	driver<-dbDriver("MySQL")
	conn<-dbConnect(driver,dbname="live",host="zaaa16d",user="root",password="")
	query<-paste("delete from live.stockAutoTrendLine where stockCode='",stockCode,"' and stockTerm='",stockTerm,"' and isPeak=",isPeak)
	query.result<-dbSendQuery(conn,query)
	query<-paste("delete from live.stockAutoTrendLinePoints where stockCode='",stockCode,"' and stockTerm='",stockTerm,"' and isPeak=",isPeak)
	query.result<-dbSendQuery(conn,query)
	
	startPos<-trendLine$x[1]
	endPos<-trendLine$x[length(trendLine$x)]
	startDate<-stockData$Date[startPos]
	startPrice<-stockData$Low[startPos]
	if(isPeak==1){
		startPrice<-stockData$High[startPos]
	}
	endDate<-stockData$Date[endPos]
	endPrice<-stockData$Low[endPos]
	if(isPeak==1){
		endPrice<-stockData$High[endPos]
	}
	query<-paste("insert into live.stockAutoTrendLine values('",today,"','",stockCode,"','",stockTerm,"',",peakBottomTerm,",",isPeak,",",length(trendLine$x),",'",startDate,"',",startPrice,",'",endDate,"',",endPrice,",",trendLine$gradient[1],",",trendLine$intercept[1],",",trendLine$rsquared[1],")")	
	query.result<-dbSendQuery(conn,query)	
	
	
	for(i in 1:length(trendLine$x)){
		x<-trendLine$x[i]
		y<-trendLine$y[i]
		price<-stockData$Low[x]
		if(isPeak==1)price<-stockData$High[x]
		date<-stockData$Date[x]
		query<-paste("insert into live.stockAutoTrendLinePoints values('",today,"','",stockCode,"','",stockTerm,"',",isPeak,",'",date,"',",price,",",y,")")
		query.result<-dbSendQuery(conn,query)
	}
	
	dbDisconnect(conn)
}
