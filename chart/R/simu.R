library(RMySQL)

con<-dbConnect(dbDriver("MySQL"),host="zaaa16d",user="root",password="",dbname="fintech")

## patternId=3,term=5
res<-dbSendQuery(con,"select * from chartSimulation where patternId='3' and term=5 and rikaku=99999")
data.penant<-fetch(res,n=-1)
hist(data.penant$ret,main="patternId=3,temr=5")
summary(data.penant$ret)

## patternId=3,term=10
res<-dbSendQuery(con,"select * from chartSimulation where patternId='3' and term=10 and rikaku=99999")
data.penant<-fetch(res,n=-1)
hist(data.penant$ret,main="patternId=3,temr=10")
summary(data.penant$ret)


## patternId=5,term=5
res<-dbSendQuery(con,"select * from chartSimulation where patternId='5' and term=5 and rikaku=99999")
data.penant<-fetch(res,n=-1)
hist(data.penant$ret,main="patternId=5,temr=5")
summary(data.penant$ret)

## patternId=5,term=10
res<-dbSendQuery(con,"select * from chartSimulation where patternId='5' and term=10 and rikaku=99999")
data.penant<-fetch(res,n=-1)
hist(data.penant$ret,main="patternId=5,temr=10")
summary(data.penant$ret)
