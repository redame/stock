# analyze elliott data from mysql db
library(RMySQL)
# http://www.stock-traderz.com/chart/trend_elliott.html
# http://www.geocities.jp/site_click/elliot.html
# １波、２波、３波、４波、５波のフィボナッチ比率を計算
con<-dbConnect(dbDriver("MySQL"),dbname="fintech",host="zaaa16d.qr.com",user="root")


elliott_analyze<-function(pb_term,ashi){
  tmp<-dbSendQuery(con,paste("select * from elliottPB where pb_term=",pb_term," and ashi='",ashi,"'",sep=""))
  data.elliott<-fetch(tmp,n=-1)
  for(i in 1:length(data.elliott$stockCode)){
    stockCode<-data.elliott[i,]$stockCode
    date1<-data.elliott[i,]$date1
    date9<-data.elliott[i,]$date9
    
    # 第１波
    w1<-data.elliott[i,]$price2-data.elliott[i,]$price1
    # 第２波
    w2<-data.elliott[i,]$price2-data.elliott[i,]$price3
    # 第３波
    w3<-data.elliott[i,]$price4-data.elliott[i,]$price3
    # 第４波
    w4<-data.elliott[i,]$price4-data.elliott[i,]$price5
    # 第５波
    w5<-data.elliott[i,]$price6-data.elliott[i,]$price5
    # A波
    wa<-data.elliott[i,]$price6-data.elliott[i,]$price7
    # B波
    wb<-data.elliott[i,]$price8-data.elliott[i,]$price7
    # C波
    wc<-data.elliott[i,]$price9-data.elliott[i,]$price7
    
    # 第１波と比較した第２波の押し
    wave2_1<-w2/w1
    # 第１波と比較した第３波のあげ
    wave3_1<-w3/w1
    # 第１波と比較した第４波の押し
    wave4_1<-w4/w1
    # 第３波と比較した第４波の押し
    wave4_3<-w4/w3
    # 第１波と比較した第５波のあげ
    wave5_1<-w5/w1    
    # 第４波と比較した第５波のあげ
    wave5_4<-w5/w4   
    # 第５はと比較したA波の押し
    wavea_5<-wa/w5
    # 第１波と比較したA波の押し
    wavea_1<-wa/w1
    # A波と比較したB波のあげ
    waveb_a<-wb/wa
    # A波と比較したC波の押し
    wavec_a<-wc/wa
    
    tryCatch({
      if(is.na(stockCode) || is.na(date1) || is.na(date9) || is.na(wave2_1) || is.na(wave3_1) || is.na(wave4_1) || is.na(wave4_3) || is.na(wave5_1) || is.na(wave5_4) || is.na(wavea_1) || is.na(waveb_a) || is.na(wavec_a)){
        next
      }
      query<-paste("replace into elliottPB_analyze values('",stockCode,"',",pb_term,",'",date1,"','",date9,"','",ashi,"',",wave2_1,",",wave3_1,",",wave4_1,",",wave4_3,",",wave5_1,",",wave5_4,",",wavea_5,",",wavea_1,",",waveb_a,",",wavec_a,")",sep="")
      print(query)
      dbSendQuery(con,query)
    }, 
    error = function(e) {    # e にはエラーメッセージが保存されている
      message("ERROR!")
      message(e)    
      next
    })
  }
}

### make data
for(ashi in c("d","w","m")){
  for(pb_term in seq(5,100,5)){
    elliott_analyze(pb_term,ashi)
  }
}



#### analyze
pb_term<-10
ashi<-"w"

tmp<-dbSendQuery(con,paste("select * from elliottPB_analyze where  ashi='",ashi,"'",sep=""))
data.analyze<-fetch(tmp,n=-1)
# http://www.geocities.jp/site_click/elliot.html

# 第２波動
# 第１波動の0.382、0.5、0.618押し
hist(data.analyze$wave2_1)

# 第３波動
# 第１波動の1.618倍、2.618倍、3倍を第２波の終了点
hist(log10(data.analyze$wave3_1))

# 第４波動
# 第１波動の全値か1.618倍。あるいは第３波動の0.382、0.5、0.618倍を戻します。
hist(log10(data.analyze$wave4_1))
hist(log10(data.analyze$wave4_3))

# 第５波動
# 第１波動の0.382、0.5、0.618、1倍、または、第4波の下落幅の1.618倍の上昇
hist(log10(data.analyze$wave5_1))
hist(log10(data.analyze$wave5_4))

# A波動
# 第５波動の0.382、0.5、0.618押し、あるいは第１波動0.382、0.5、0.618、1倍を下落
hist(log10(data.analyze$wavea_5))
hist(log10(data.analyze$wavea_1))

#B波動
#a波動の0.382、0.5、0.618を戻します。
hist(data.analyze$waveb_a)

#C波動
#a波動の0.382、0.5、0.618、1倍か1.618倍を下落します。
hist(data.analyze$wavec_a)

