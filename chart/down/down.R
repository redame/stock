Sys.setenv("http_proxy"="http://zaan15p.qr.com:8080")
library(quantmod)
setwd("/Volumes/admin/chartPatternBatch/down/")

## down
data.down<-read.csv("down.txt",sep="\t",header=F)
names(data.down)<-c("stockCode","beta","stDate","stTopix","stPrice","edDate","edTopix","edPrice","Ret","Date5","Price5","Ret5","Date10","Price10","Ret10","Date15","Price15","Ret15","Date20","Price20","Ret20")

par(mfrow=c(1,1))
par(mfrow=c(2,2))
hist((data.down$Ret5),main="return of after 5 days")
summary(data.down$Ret5)

hist((data.down$Ret10),main="return of after 10 days")
summary(data.down$Ret10)

hist((data.down$Ret15),main="return of after 15 days")
summary(data.down$Ret15)

hist((data.down$Ret20),main="return of after 20 days")
summary(data.down$Ret20)



##up
data.up<-read.csv("up.txt",sep="\t",header=F)
names(data.up)<-c("stockCode","beta","stDate","stTopix","stPrice","edDate","edTopix","edPrice","Ret","Date5","Price5","Ret5","Date10","Price10","Ret10","Date15","Price15","Ret15","Date20","Price20","Ret20")

par(mfrow=c(2,2))
hist((data.up$Ret5),main="return of after 5 days")
summary(data.up$Ret5)

hist((data.up$Ret10),main="return of after 10 days")
summary(data.up$Ret10)

hist((data.up$Ret15),main="return of after 15 days")
summary(data.up$Ret15)

hist((data.up$Ret20),main="return of after 20 days")
summary(data.up$Ret20)


## beta sample
hist(data.down$beta)
summary(data.down$beta)

#### down
# とりあえずbeta<0
data.down.1<-subset(data.down,beta<0)
summary(data.down.1$Ret5)
summary(data.down.1$Ret10)
summary(data.down.1$Ret15)
summary(data.down.1$Ret20)

# beta>=0 and beta<1
data.down.2<-subset(data.down,beta>=0 && beta<1)
summary(data.down.2$Ret5)
summary(data.down.2$Ret10)
summary(data.down.2$Ret15)
summary(data.down.2$Ret20)

# beta>=1
data.down.3<-subset(data.down,beta>=1)
summary(data.down.3$Ret5)
summary(data.down.3$Ret10)
summary(data.down.3$Ret15)
summary(data.down.3$Ret20)

#### up
# とりあえずbeta<0
data.up.1<-subset(data.up,beta<0)
summary(data.up.1$Ret5)
summary(data.up.1$Ret10)
summary(data.up.1$Ret15)
summary(data.up.1$Ret20)

# beta>=0 and beta<1
data.up.2<-subset(data.up,beta>=0 && beta<1)
summary(data.up.2$Ret5)
summary(data.up.2$Ret10)
summary(data.up.2$Ret15)
summary(data.up.2$Ret20)

# beta>=1
data.up.3<-subset(data.up,beta>=1)
summary(data.up.3$Ret5)
summary(data.up.3$Ret10)
summary(data.up.3$Ret15)
summary(data.up.3$Ret20)



