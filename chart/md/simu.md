# 形状データを確認

## 期間
```
mysql> select max(signalTime),min(signalTime) from chartSignal;
+---------------------+---------------------+
| max(signalTime)     | min(signalTime)     |
+---------------------+---------------------+
| 2016-05-30 00:00:00 | 2000-02-07 00:00:00 |
+---------------------+---------------------+
```
## 計算結果
#### 件数
|patternId|description|count(*)|
|:---|:---|---:|
|1	|逆V字トップ|	0	|
|2|	上昇三角形	|290	|
|3|	ペナント型	|11026	|
|4|	下降三角形	|672	|
|5|	長方形	|14122	|
|6|	チャネル・アップ	|0	|
|7|	チャネル・ダウン	|0	|
|8|	フラッグ	|0	|
|9|	上昇ウエッジ	|12	|
|10|	下降ウエッジ	|0	|
|11|	ヘッドアンドショルダーズトップ	|185	|
|12|	ヘッドアンドショルダーボトム	|2913|

## 詳細検証
件数の多いペナント型と長方形を確認する
#### ペナント型
```
> ## patternId=3,term=5
> res<-dbSendQuery(con,"select * from chartSimulation where patternId='3' and term=5 and rikaku=99999")
> data.penant<-fetch(res,n=-1)
> hist(data.penant$ret,main="patternId=3,temr=5")
> summary(data.penant$ret)
     Min.   1st Qu.    Median      Mean   3rd Qu.      Max.
-0.642900 -0.011980  0.006957  0.016100  0.033600  1.447000
>
> ## patternId=3,term=10
> res<-dbSendQuery(con,"select * from chartSimulation where patternId='3' and term=10 and rikaku=99999")
> data.penant<-fetch(res,n=-1)
> hist(data.penant$ret,main="patternId=3,temr=10")
> summary(data.penant$ret)
     Min.   1st Qu.    Median      Mean   3rd Qu.      Max.
-0.909400 -0.022940  0.006466  0.019990  0.044600  5.438000
>
```
#### 長方形
```>
> ## patternId=5,term=5
> res<-dbSendQuery(con,"select * from chartSimulation where patternId='5' and term=5 and rikaku=99999")
> data.penant<-fetch(res,n=-1)
> hist(data.penant$ret,main="patternId=5,temr=5")
> summary(data.penant$ret)
     Min.   1st Qu.    Median      Mean   3rd Qu.      Max.
-0.454300 -0.014080  0.002985  0.011670  0.028020  0.561200
>
> ## patternId=5,term=10
> res<-dbSendQuery(con,"select * from chartSimulation where patternId='5' and term=10 and rikaku=99999")
> data.penant<-fetch(res,n=-1)
> hist(data.penant$ret,main="patternId=5,temr=10")
> summary(data.penant$ret)
     Min.   1st Qu.    Median      Mean   3rd Qu.      Max.
-0.391300 -0.019900  0.004792  0.014930  0.040400  0.936400
```

## 結論
特徴が掴めなかった
