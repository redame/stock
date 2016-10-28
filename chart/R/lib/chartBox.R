
createChartBox<-function(stockData,boxTerm){
	# make chart box , from latest data
	cnt<-1
	start.x<-NULL
	end.x<-NULL
	max.high<-NULL
	min.low<-NULL

	idx<-1
	i<-1
	for(i in length(stockData$Date):1){
		#cat("i=",i,",cnt=",cnt,",idx=",idx,"\n")
		if(cnt==1){
			end.x[idx]<-i
			max.high[idx]<-stockData$High[i]
			min.low[idx]<-stockData$Low[i]
			cnt<-cnt+1
		}else if(cnt<boxTerm){
			max.high[idx]<-ifelse(max.high[idx]>stockData$High[i],max.high[idx],stockData$High[i])
			min.low[idx]<-ifelse(min.low[idx]<stockData$Low[i],min.low[idx],stockData$Low[i])
			cnt<-cnt+1
		}else{
			start.x[idx]<-i		
			cnt<-1
			idx<-idx+1
		}
	}
	# end process
	if(cnt<boxTerm){
		start.x[idx]<-i
	}
	mid.x<-(start.x+end.x)/2
	mid.price<-(max.high+min.low)/2
	chartBox<-data.frame(start.x=start.x,end.x=end.x,max.high=max.high,min.low=min.low,mid.x=mid.x,mid.price=mid.price)
	chartBox
}


# check points in box or not
isIncludeChartBox<-function(predict.y,min.low,max.high){
	ret<-T
	for(i in 1:length(predict.y)){
		if(predict.y[i]<min.low[i] || predict.y[i]>max.high[i]){
			ret<-F
			break
		}
	}
	ret
}

# lm with box mid point, and end of out of box  
# chartBox is order by desc
lmChartBox<-function(chartBox,start.i=1){
	x<-NULL
	y<-NULL
	start.x<-NULL
	end.x<-NULL
	min.low<-NULL
	max.high<-NULL
	lm.result.ok<-NULL
	lm.summary.ok<-NULL
	x.ok<-NULL
	y.ok<-NULL
	for(i in start.i:length(chartBox$start.x)){
		x<-append(x,chartBox$mid.x[i])
		y<-append(y,chartBox$mid.price[i])
		min.low<-append(min.low,chartBox$min.low[i])
		max.high<-append(max.high,chartBox$max.high[i])
		if(length(x)>2){
			lm.result<-lm(y~x)
			lm.summary<-summary(lm.result)
			predict.y<-as.vector(predict(lm.result))
			if(!isIncludeChartBox(predict.y,min.low,max.high)){
				break
			}else{
				x.ok<-x
				y.ok<-y
				lm.result.ok<-lm.result
				lm.summary.ok<-lm.summary
			}
		}
	}
	trendLine<-NULL
	if(!is.null(x.ok)){
		rsquared<-as.double(lm.summary.ok$r.squared)
		trendLine<-data.frame(x=x.ok,y=y.ok,predict.y=as.vector(predict(lm.result.ok)),gradient=lm.summary.ok$coefficients[2],intercept=lm.summary.ok$coefficients[1],rsquared=rsquared)
	}
	trendLine
}


#lm with upper , lower mid point 
makeTrendLineByChartBox<-function(trendLine,chartBox,isSupport)	{
	price<-NULL
	lm.result<-NULL
  if(length(chartBox$mid.x)>0){
	for(i in 1:length(chartBox$mid.x)){
		if(chartBox$mid.x[i]==trendLine$x[1]){
			if(isSupport){
				price<-chartBox$min.low[i:(i-1+length(trendLine$x))]
			}else{
				price<-chartBox$max.high[i:(i-1+length(trendLine$x))]
			}
			lm.result<-lm(price~trendLine$x)
			break
		}
	}
  }
	edgeTrendLine<-NULL
	if(!is.null(lm.result)){
		lm.summary<-summary(lm.result)
		edgeTrendLine<-data.frame(x=trendLine$x,y=price,predict.y=as.vector(predict(lm.result)),gradient=lm.summary$coefficients[2],intercept=lm.summary$coefficients[1],rsquared=as.double(lm.summary$r.squared))
	}
	edgeTrendLine
}
makeSupportTrendLineByChartBox<-function(trendLine,chartBox){
	makeTrendLineByChartBox(trendLine,chartBox,T)
}
makeResistanceTrendLineByChartBox<-function(trendLine,chartBox){
	makeTrendLineByChartBox(trendLine,chartBox,F)
}


makeFutureTrendLineByChartBox<-function(stockData,trendLine,futureCount){
	xvec<-NULL
	yvec<-NULL
	gvec<-NULL
	ivec<-NULL
	futureTrendLine<-NULL
	if(!is.null(trendLine) && length(trendLine$x)>0){
		gradient<-trendLine$gradient[1]
		intercept<-trendLine$intercept[1]
		xmax<-max(trendLine$x)
		for(i in 1:futureCount){
			xtmp<-xmax+i
			xvec<-append(xvec,xtmp)
			yvec<-append(yvec,xtmp*gradient+intercept)
			gvec<-append(gvec,gradient)
			ivec<-append(ivec,intercept)
		}
		futureTrendLine<-data.frame(x=xvec,y=yvec,gradient=gvec,intercept=ivec)
	}
	futureTrendLine
}





