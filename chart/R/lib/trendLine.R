makeTrendLine<-function(date,dataPeakBottom,peakBottomFlag,isSupportTrendLine,rsquared.min=0.9){
	x<-NULL
	y<-NULL
	trendLine<-NULL
	len<-length(dataPeakBottom)
	for(i in 1:len){
		if(peakBottomFlag[i]){
			x<-append(x,i)
			y<-append(y,dataPeakBottom[i])
			if(length(x)>2){
				lm.result<-lm(y~x)
				lm.summary<-summary(lm.result)
				#if(isSupportTrendLine){
				#	if(as.double(lm.result$coefficients[2])<0){
				#		#down side
				#		#break;
				#	}
				#}else{
				#	if(as.double(lm.result$coefficients[2])>0){
				#		# upside
				#		#break;
				#	}
				#}
				rsquared<-as.double(lm.summary$r.squared)
				if(rsquared>=rsquared.min){
					#choose  longest one
					trendLine<-data.frame(x=x,y=as.vector(predict(lm.result)),gradient=lm.summary$coefficients[2],intercept=lm.summary$coefficients[1],rsquared=rsquared)
				}
			}
		}
	}
	trendLine	
}

makeResistanceTrendLine<-function(stockData,peakBottom,rsquared.min=0.9){
	trendLine<-NULL
	date<-stockData$Date[1:length(stockData$Date)]
	high<-stockData$High[1:length(stockData$High)]
	for(i in length(peakBottom$Peak):1){
		if(peakBottom$Peak[i]){
			peak<-peakBottom$Peak
			peak[1:(i-1)]<-FALSE
			trendLineTmp<-makeTrendLine(stockDate,high,peak,FALSE,rsquared.min)
			if(!is.null(trendLineTmp)){
				trendLine<-trendLineTmp
			}
		}
	}
	trendLine
}
makeSupportTrendLine<-function(stockData,peakBottom,rsquared.min=0.9){
	trendLine<-NULL
	date<-stockData$Date[1:length(stockData$Date)]
	low<-stockData$Low[1:length(stockData$Low)]
	for(i in length(peakBottom$Bottom):1){
		if(peakBottom$Bottom[i]){
			bottom<-peakBottom$Bottom
			bottom[1:(i-1)]<-FALSE
			trendLineTmp<-makeTrendLine(stockData,low,bottom,TRUE,rsquared.min)
			if(!is.null(trendLineTmp)){
				trendLine<-trendLineTmp
			}
		}
	}
	trendLine # newer only
}
convertTrendLineToZoo<-function(stockData,trendLine,futureCount=0){
	dateTmp<-stockData$Date
	date.end<-dateTmp[length(dateTmp)]
	if(futureCount>0){
		for(i in 1:futureCount){
			dateTmp<-append(dateTmp,date.end+i*(60*60*24))
		}
	}
	
	#trend.frame<-data.frame(Date=stockData$Date,Close=rep(NA,length=length(stockData$Date)))
	trend.frame<-data.frame(Date=dateTmp,Close=rep(NA,length=length(dateTmp)))

	x<-trendLine[1]
	xv<-x[[1]]
	x.end<-xv[length(xv)]
	x.start<-xv[1]
	if(x.start>x.end){
		tmp<-x.start
		x.start<-x.end
		x.end<-tmp
	}
	#update last x
	x.end<-length(trend.frame$Date)
	
	gradient<-trendLine$gradient[1]
	intercept<-trendLine$intercept[1]
	for(j in 1:length(trend.frame$Date)){
		if(j>=x.start && j<=x.end){
			val<-gradient*j+intercept
			trend.frame$Close[j]<-val
		}
	}	
	trend.zoo<-read.zoo(trend.frame)
	trend.zoo

}

addFutureStockData<-function(stockData,futureCount=0){
	dateTmp<-stockData$Date
	openTmp<-stockData$Open
	closeTmp<-stockData$Close
	highTmp<-stockData$High
	lowTmp<-stockData$Low
	volumeTmp<-stockData$Volume
	
	prcTmp<-closeTmp[length(closeTmp)]
	
	if(futureCount>0){
		date.end<-dateTmp[length(dateTmp)]
		for(i in 1:futureCount){
			dateTmp<-append(dateTmp,date.end+i*(60*60*24))
			openTmp<-append(openTmp, prcTmp)
			closeTmp<-append(closeTmp, prcTmp)
			highTmp<-append(highTmp, prcTmp)
			lowTmp<-append(lowTmp, prcTmp)
			volumeTmp<-append(volumeTmp,0)
		}
	}
	data.frame(Date=dateTmp,Open=openTmp,High=highTmp,Low=lowTmp,Close=closeTmp,Volume=volumeTmp)
	
}
