# 計算方法

## 形状
| patternId | name                    | description     |
|:----|:-------------------------|:-----------------|
|  1 | reverseV                | 逆V字トップ         |
|  2 | ascendingTriangle       | 上昇三角形             |
|  3 | pennant                 | ペナント型            |
|  4 | descendingTriangle      | 下降三角形            |
|  5 | box                     | 長方形            |
|  6 | chanelUp                | チャネル・アップ      |
|  7 | chanelDown              | チャネル・ダウン    |
|  8 | flag                    | フラッグ        |
|  9 | ascendingWedge          | 上昇ウエッジ        |
| 10 | descendingWedge         | 下降ウエッジ      |
| 11 | headAndShoulder         | ヘッドアンドショルダーズトップ  |
| 12 | invertedHeadAndShoulder | ヘッドアンドショルダーボトム   |

----
## データベース
zaaa16d.qr.com

##### chartLine
トレンドラインを保存する
```
CREATE TABLE `chartLine` (
  `lineId` varchar(100) NOT NULL,
  `startTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `startPrice` float NOT NULL,
  `endTime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `endPrice` float NOT NULL,
  PRIMARY KEY (`lineId`,`startTime`,`endTime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
```
#### chartSignal
シグナルを保存     
upDownFlag：up,down,make　最後にUPで終わったか、Downで終わったかまたは作成中か
```
CREATE TABLE `chartSignal` (
  `patternId` int(11) NOT NULL,
  `stockCode` varchar(5) NOT NULL,
  `signalTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `price` float NOT NULL,
  `lineId` varchar(100) NOT NULL,
  `upDownFlag` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`patternId`,`stockCode`,`lineId`),
  KEY `idx_chartSignal` (`patternId`,`stockCode`,`signalTime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
```
#### chartWinRate
過去、シグナルが発生した際に、利確ライン(rikaku)、損切りライン(songiri)、発生後次の日からの本数(term)を与えて、その後のリターンとボラティリティを計算し格納している
```
CREATE TABLE `chartSimulation` (
  `patternId` int(11) NOT NULL,
  `stockCode` varchar(5) NOT NULL,
  `lineId` varchar(100) NOT NULL,
  `rikaku` double NOT NULL DEFAULT '0',
  `songiri` double NOT NULL DEFAULT '0',
  `term` int(11) NOT NULL DEFAULT '0',
  `upDownFlag` varchar(10) NOT NULL DEFAULT '',
  `ret` double DEFAULT NULL,
  `volat` double DEFAULT NULL,
  PRIMARY KEY (`patternId`,`stockCode`,`lineId`,`rikaku`,`songiri`,`term`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
```
----
## 作成方法
#### データ取得
DBから４本音を取得しファイルにする
```
$ cd bin
$ python getAllStockPrice.py
```

#### 形状計算
形状を判定しDBへ格納
```
$ cd bin/trendline
$ start.sh
```

#### シミュレーション
損切ライン、利確ライン、期間を変化させてシミュレーション
```
$ cd bin/winRate
$ simu.sh
```
