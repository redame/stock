create table chartLine(
  `lineId` varchar(100) NOT NULL,
  `startTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `startPrice` float NOT NULL,
  `endTime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `endPrice` float NOT NULL,
  `stockCode` varchar(5) NOT NULL,
  PRIMARY KEY (`lineID`,startTime,endTime)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

create table chartSignal(
  `patternId` int(11) NOT NULL,
  `stockCode` varchar(5) NOT NULL,
  `signalTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `price` float NOT NULL,
  `lineId` varchar(100) NOT NULL,
  `upDownFlag` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`patternId`,stockCode,lineId),
  KEY `idx_chartSignal` (`patternId`,`stockCode`,`signalTime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

create table chartWinRate(
  `patternId` int(11) NOT NULL,
  `winRate` float NOT NULL,
  `targetRate` float DEFAULT NULL,
  `sigma` float DEFAULT NULL,
  `upDownFlag` varchar(10) DEFAULT NULL,
  `total` int(11) DEFAULT NULL,
  PRIMARY KEY (`patternId`,upDownFlag),
  KEY `patternId` (`patternId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

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

mysql -uroot -hlive.c8t088zeyxow.ap-northeast-1.rds.amazonaws.com -pfintechlabo

