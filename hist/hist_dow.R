library(quantmod)

#code<-"DOW"
code<-commandArgs(trailingOnly=TRUE)[1]

dow<-new.env()
dow.name<-getSymbols(code,env=dow,src="yahoo", from='2001-01-01',to='2016-12-31')
dow.prices<-dow[[dow.name]]
names(dow.prices)<-c("Open","High","Low","Close","Volume","Adjusted")
data<-as.data.frame(dow.prices)

fname<-paste("/mnt/stock/data/hist/daily/",code,".txt",sep="")
write.table(data,fname,quote=F,col.names=F,row.names=T,append=F,sep="\t")

