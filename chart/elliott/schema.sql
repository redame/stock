

create table elliott(
    stockCode varchar(8) not null,
    zigzag double precision not null,
    date1 datetime not null,
    price1 double precision null,
    date2 datetime null,
    price2 double precision null,
    date3 datetime null,
    price3 double precision null,
    date4 datetime null,
    price4 double precision null,
    date5 datetime null,
    price5 double precision null,
    date6 datetime null,
    price6 double precision null,
    date7 datetime null,
    price7 double precision null,
    date8 datetime null,
    price8 double precision null,
    date9 datetime not null,
    price9 double precision null,
    ashi char(1) null
)
;
create unique index idx_elliott on elliott(stockCode,zigzag,date1,date9,ashi)
;

--alter table elliott add column ashi char(1) null
--;


-- calcurate elliott by using peak bottom logic
create table elliottPB(
    stockCode varchar(8) not null,
    pb_term double precision not null,
    date1 datetime not null,
    price1 double precision null,
    date2 datetime null,
    price2 double precision null,
    date3 datetime null,
    price3 double precision null,
    date4 datetime null,
    price4 double precision null,
    date5 datetime null,
    price5 double precision null,
    date6 datetime null,
    price6 double precision null,
    date7 datetime null,
    price7 double precision null,
    date8 datetime null,
    price8 double precision null,
    date9 datetime not null,
    price9 double precision null,
    ashi char(1) null
)
;
create unique index idx_elliottPB on elliottPB(stockCode,pb_term,date1,date9,ashi)
;

--alter table elliott add column ashi char(1) null
--;


create table technical(
  stockCode varchar(8) not null,
  date datetime not null,
  rsi double precision null,
  aroon_up double precision null,
  aroon_dn double precision null,
  aroon_osc double precision null,
  macd double precision null,
  macd_sig double precision null,
  macd_hist double precision null,
  willr double precision null,
  atr double precision null
)
;
create unique index idx_technical on technical(stockCode,date)
;



-- http://zai.diamond.jp/articles/-/134822

drop table ptnDoubleBottom
;
drop table ptnDoubleTop
;
drop table ptnDownChannel
;
drop table ptnFallingTriangle
;
drop table ptnFallingWedge
;
drop table ptnHeadAndShoulderBottom
;
drop table ptnHeadAndShoulderTop
;
drop table ptnRisingTriangle
;
drop table ptnRisingWedge
;
drop table ptnTripleBottom
;
drop table ptnTripleTop
;
drop table ptnUpChannel
;

CREATE TABLE `ptnHeadAndShoulderTop` (
  `stockCode` varchar(8) NOT NULL,
  `zigzag` double NOT NULL,
  `line1_stDate` datetime default NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date3` datetime DEFAULT NULL,
  `price3` double DEFAULT NULL,
  `date4` datetime DEFAULT NULL,
  `price4` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1) not NULL,
  UNIQUE KEY `idx_ptnHeadAndShoulderTop` (`stockCode`,`zigzag`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;

CREATE TABLE `ptnHeadAndShoulderBottom` (
  `stockCode` varchar(8) NOT NULL,
  `zigzag` double NOT NULL,
  `line1_stDate` datetime default NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date3` datetime DEFAULT NULL,
  `price3` double DEFAULT NULL,
  `date4` datetime DEFAULT NULL,
  `price4` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1) not NULL,
  UNIQUE KEY `idx_ptnHeadAndShoulderBottom` (`stockCode`,`zigzag`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;


CREATE TABLE `ptnRisingTriangle` (
  `stockCode` varchar(8) NOT NULL,
  `zigzag` double NOT NULL,
  `line1_stDate` datetime  NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `line2_stDate` datetime  NULL,
  `line2_stPrice` double DEFAULT NULL,
  `line2_edDate` datetime DEFAULT NULL,
  `line2_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date3` datetime DEFAULT NULL,
  `price3` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1)  not NULL,
  UNIQUE KEY `idx_ptnRisingTriangle` (`stockCode`,`zigzag`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;

CREATE TABLE `ptnFallingTriangle` (
  `stockCode` varchar(8) NOT NULL,
  `zigzag` double NOT NULL,
  `line1_stDate` datetime  NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `line2_stDate` datetime  NULL,
  `line2_stPrice` double DEFAULT NULL,
  `line2_edDate` datetime DEFAULT NULL,
  `line2_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date3` datetime DEFAULT NULL,
  `price3` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1)  not NULL,
  UNIQUE KEY `idx_ptnFallingTriangle` (`stockCode`,`zigzag`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;




CREATE TABLE `ptnRisingWedge` (
  `stockCode` varchar(8) NOT NULL,
  `zigzag` double NOT NULL,
  `line1_stDate` datetime  NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `line2_stDate` datetime  NULL,
  `line2_stPrice` double DEFAULT NULL,
  `line2_edDate` datetime DEFAULT NULL,
  `line2_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date3` datetime DEFAULT NULL,
  `price3` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1)  not NULL,
  UNIQUE KEY `idx_ptnRisingWedge` (`stockCode`,`zigzag`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;


CREATE TABLE `ptnFallingWedge` (
  `stockCode` varchar(8) NOT NULL,
  `zigzag` double NOT NULL,
  `line1_stDate` datetime  NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `line2_stDate` datetime  NULL,
  `line2_stPrice` double DEFAULT NULL,
  `line2_edDate` datetime DEFAULT NULL,
  `line2_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date3` datetime DEFAULT NULL,
  `price3` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1)  not NULL,
  UNIQUE KEY `idx_ptnFallingWedge` (`stockCode`,`zigzag`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;


CREATE TABLE `ptnUpChannel` (
  `stockCode` varchar(8) NOT NULL,
  `zigzag` double NOT NULL,
  `line1_stDate` datetime  NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `line2_stDate` datetime  NULL,
  `line2_stPrice` double DEFAULT NULL,
  `line2_edDate` datetime DEFAULT NULL,
  `line2_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date3` datetime DEFAULT NULL,
  `price3` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1)  not NULL,
  UNIQUE KEY `idx_ptnUpChannel` (`stockCode`,`zigzag`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;


CREATE TABLE `ptnDownChannel` (
  `stockCode` varchar(8) NOT NULL,
  `zigzag` double NOT NULL,
  `line1_stDate` datetime  NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `line2_stDate` datetime  NULL,
  `line2_stPrice` double DEFAULT NULL,
  `line2_edDate` datetime DEFAULT NULL,
  `line2_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date3` datetime DEFAULT NULL,
  `price3` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1)  not NULL,
  UNIQUE KEY `idx_ptnDownChannel` (`stockCode`,`zigzag`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;


CREATE TABLE `ptnDoubleTop` (
  `stockCode` varchar(8) NOT NULL,
  `zigzag` double NOT NULL,
  `line1_stDate` datetime  NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `line2_stDate` datetime  NULL,
  `line2_stPrice` double DEFAULT NULL,
  `line2_edDate` datetime DEFAULT NULL,
  `line2_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1)  not NULL,
  UNIQUE KEY `idx_ptnDoubleTop` (`stockCode`,`zigzag`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;


CREATE TABLE `ptnDoubleBottom` (
  `stockCode` varchar(8) NOT NULL,
  `zigzag` double NOT NULL,
  `line1_stDate` datetime  NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `line2_stDate` datetime  NULL,
  `line2_stPrice` double DEFAULT NULL,
  `line2_edDate` datetime DEFAULT NULL,
  `line2_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1)  not NULL,
  UNIQUE KEY `idx_ptnDoubleBottom` (`stockCode`,`zigzag`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;


CREATE TABLE `ptnTripleTop` (
  `stockCode` varchar(8) NOT NULL,
  `zigzag` double NOT NULL,
  `line1_stDate` datetime  NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `line2_stDate` datetime  NULL,
  `line2_stPrice` double DEFAULT NULL,
  `line2_edDate` datetime DEFAULT NULL,
  `line2_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date3` datetime DEFAULT NULL,
  `price3` double DEFAULT NULL,
  `date4` datetime DEFAULT NULL,
  `price4` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1)  not NULL,
  UNIQUE KEY `idx_ptnTripleTop` (`stockCode`,`zigzag`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;


CREATE TABLE `ptnTripleBottom` (
  `stockCode` varchar(8) NOT NULL,
  `zigzag` double NOT NULL,
  `line1_stDate` datetime  NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `line2_stDate` datetime  NULL,
  `line2_stPrice` double DEFAULT NULL,
  `line2_edDate` datetime DEFAULT NULL,
  `line2_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date3` datetime DEFAULT NULL,
  `price3` double DEFAULT NULL,
  `date4` datetime DEFAULT NULL,
  `price4` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1)  not NULL,
  UNIQUE KEY `idx_ptnTripleBottom` (`stockCode`,`zigzag`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;




create view ptnListCntView as 
select  "ptnDoubleBottom" as ptn,ashi,count(*) as cnt from ptnDoubleBottom group by ashi union
select  "ptnDoubleTop",ashi,count(*) from ptnDoubleTop group by ashi union
select  "ptnDownChannel",ashi,count(*) from ptnDownChannel group by ashi union
select  "ptnFallingTriangle",ashi,count(*) from ptnFallingTriangle group by ashi union
select  "ptnFallingWedge",ashi,count(*) from ptnFallingWedge group by ashi union
select  "ptnHeadAndShoulderBottom",ashi,count(*) from ptnHeadAndShoulderBottom group by ashi union
select  "ptnHeadAndShoulderTop",ashi,count(*) from ptnHeadAndShoulderTop group by ashi union
select  "ptnRisingTriangle",ashi,count(*) from ptnRisingTriangle group by ashi union
select  "ptnRisingWedge",ashi,count(*) from ptnRisingWedge group by ashi union
select  "ptnTripleBottom",ashi,count(*) from ptnTripleBottom group by ashi union
select  "ptnTripleTop",ashi,count(*) from ptnTripleTop group by ashi union
select  "ptnUpChannel",ashi,count(*) from ptnUpChannel group by ashi
;


/*
create view ptnListView as
select  "ptnDoubleBottom" as ptn,stockCode,zigzag,ashi,date_from,date_to as cnt from ptnDoubleBottom union
select  "ptnDoubleTop" as ptn,stockCode,zigzag,ashi,date_from,date_to from ptnDoubleTop union
select  "ptnDownChannel" as ptn,stockCode,zigzag,ashi,date_from,date_to from ptnDownChannel union
select  "ptnFallingTriangle" as ptn,stockCode,zigzag,ashi,date_from,date_to from ptnFallingTriangle union
select  "ptnFallingWedge" as ptn,stockCode,zigzag,ashi,date_from,date_to from ptnFallingWedge union
select  "ptnHeadAndShoulderBottom" as ptn,stockCode,zigzag,ashi,date_from,date_to from ptnHeadAndShoulderBottom union
select  "ptnHeadAndShoulderTop" as ptn,stockCode,zigzag,ashi,date_from,date_to from ptnHeadAndShoulderTop union
select  "ptnRisingTriangle" as ptn,stockCode,zigzag,ashi,date_from,date_to from ptnRisingTriangle union
select  "ptnRisingWedge" as ptn,stockCode,zigzag,ashi,date_from,date_to from ptnRisingWedge union
select  "ptnTripleBottom" as ptn,stockCode,zigzag,ashi,date_from,date_to from ptnTripleBottom union
select  "ptnTripleTop" as ptn,stockCode,zigzag,ashi,date_from,date_to from ptnTripleTop union
select  "ptnUpChannel" as ptn,stockCode,zigzag,ashi,date_from,date_to from ptnUpChannel
;

*/



create table ptnCheckRatio(
  `ptn` varchar(32) NOT NULL,
  `stockCode` varchar(8) NOT NULL,
  `zigzag` double NOT NULL,
  `date_from` datetime not NULL,
  `date_to` datetime not NULL,
  `ashi` char(1)  not NULL,
  upper_ratio double precision null,
  lower_ratio double precision null,
  UNIQUE KEY `idx_ptnCheckRatio` (ptn,`stockCode`,`zigzag`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;


create table ptnCheckArea(
  `ptn` varchar(32) NOT NULL,
  `stockCode` varchar(8) NOT NULL,
  `zigzag` double NOT NULL,
  `date_from` datetime not NULL,
  `date_to` datetime not NULL,
  `ashi` char(1)  not NULL,
  candle_area double precision null,
  line_area double precision null,
  UNIQUE KEY `idx_ptnCheckArea` (ptn,`stockCode`,`zigzag`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;






------


drop table ptnPBDoubleBottom;
drop table ptnPBDoubleTop;
drop table ptnPBDownChannel;
drop table ptnPBFallingTriangle;
drop table ptnPBFallingWedge;
drop table ptnPBHeadAndShoulderBottom;
drop table ptnPBPBHeadAndShoulderTop;
drop table ptnPBRisingTriangle ;
drop table ptnPBRisingWedge;
drop table ptnPBTripleBottom;
drop table ptnPBTripleTop;
drop table ptnPBUpChannel;

CREATE TABLE `ptnPBHeadAndShoulderTop` (
  `stockCode` varchar(8) NOT NULL,
  `pb_term` int NOT NULL,
  `line1_stDate` datetime default NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date3` datetime DEFAULT NULL,
  `price3` double DEFAULT NULL,
  `date4` datetime DEFAULT NULL,
  `price4` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1) not NULL,
  UNIQUE KEY `idx_ptnPBHeadAndShoulderTop` (`stockCode`,`pb_term`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;

CREATE TABLE `ptnPBHeadAndShoulderBottom` (
  `stockCode` varchar(8) NOT NULL,
  `pb_term` int NOT NULL,
  `line1_stDate` datetime default NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date3` datetime DEFAULT NULL,
  `price3` double DEFAULT NULL,
  `date4` datetime DEFAULT NULL,
  `price4` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1) not NULL,
  UNIQUE KEY `idx_ptnPBHeadAndShoulderBottom` (`stockCode`,`pb_term`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;


CREATE TABLE `ptnPBRisingTriangle` (
  `stockCode` varchar(8) NOT NULL,
  `pb_term` int NOT NULL,
  `line1_stDate` datetime  NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `line2_stDate` datetime  NULL,
  `line2_stPrice` double DEFAULT NULL,
  `line2_edDate` datetime DEFAULT NULL,
  `line2_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date3` datetime DEFAULT NULL,
  `price3` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1)  not NULL,
  UNIQUE KEY `idx_ptnPBRisingTriangle` (`stockCode`,`pb_term`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;

CREATE TABLE `ptnPBFallingTriangle` (
  `stockCode` varchar(8) NOT NULL,
  `pb_term` int NOT NULL,
  `line1_stDate` datetime  NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `line2_stDate` datetime  NULL,
  `line2_stPrice` double DEFAULT NULL,
  `line2_edDate` datetime DEFAULT NULL,
  `line2_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date3` datetime DEFAULT NULL,
  `price3` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1)  not NULL,
  UNIQUE KEY `idx_ptnPBFallingTriangle` (`stockCode`,`pb_term`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;




CREATE TABLE `ptnPBRisingWedge` (
  `stockCode` varchar(8) NOT NULL,
  `pb_term` int NOT NULL,
  `line1_stDate` datetime  NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `line2_stDate` datetime  NULL,
  `line2_stPrice` double DEFAULT NULL,
  `line2_edDate` datetime DEFAULT NULL,
  `line2_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date3` datetime DEFAULT NULL,
  `price3` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1)  not NULL,
  UNIQUE KEY `idx_ptnPBRisingWedge` (`stockCode`,`pb_term`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;


CREATE TABLE `ptnPBFallingWedge` (
  `stockCode` varchar(8) NOT NULL,
  `pb_term` int NOT NULL,
  `line1_stDate` datetime  NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `line2_stDate` datetime  NULL,
  `line2_stPrice` double DEFAULT NULL,
  `line2_edDate` datetime DEFAULT NULL,
  `line2_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date3` datetime DEFAULT NULL,
  `price3` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1)  not NULL,
  UNIQUE KEY `idx_ptnPBFallingWedge` (`stockCode`,`pb_term`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;


CREATE TABLE `ptnPBUpChannel` (
  `stockCode` varchar(8) NOT NULL,
  `pb_term` int NOT NULL,
  `line1_stDate` datetime  NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `line2_stDate` datetime  NULL,
  `line2_stPrice` double DEFAULT NULL,
  `line2_edDate` datetime DEFAULT NULL,
  `line2_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date3` datetime DEFAULT NULL,
  `price3` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1)  not NULL,
  UNIQUE KEY `idx_ptnPBUpChannel` (`stockCode`,`pb_term`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;


CREATE TABLE `ptnPBDownChannel` (
  `stockCode` varchar(8) NOT NULL,
  `pb_term` int NOT NULL,
  `line1_stDate` datetime  NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `line2_stDate` datetime  NULL,
  `line2_stPrice` double DEFAULT NULL,
  `line2_edDate` datetime DEFAULT NULL,
  `line2_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date3` datetime DEFAULT NULL,
  `price3` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1)  not NULL,
  UNIQUE KEY `idx_ptnPBDownChannel` (`stockCode`,`pb_term`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;


CREATE TABLE `ptnPBDoubleTop` (
  `stockCode` varchar(8) NOT NULL,
  `pb_term` int NOT NULL,
  `line1_stDate` datetime  NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `line2_stDate` datetime  NULL,
  `line2_stPrice` double DEFAULT NULL,
  `line2_edDate` datetime DEFAULT NULL,
  `line2_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1)  not NULL,
  UNIQUE KEY `idx_ptnPBDoubleTop` (`stockCode`,`pb_term`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;


CREATE TABLE `ptnPBDoubleBottom` (
  `stockCode` varchar(8) NOT NULL,
  `pb_term` int NOT NULL,
  `line1_stDate` datetime  NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `line2_stDate` datetime  NULL,
  `line2_stPrice` double DEFAULT NULL,
  `line2_edDate` datetime DEFAULT NULL,
  `line2_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1)  not NULL,
  UNIQUE KEY `idx_ptnPBDoubleBottom` (`stockCode`,`pb_term`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;


CREATE TABLE `ptnPBTripleTop` (
  `stockCode` varchar(8) NOT NULL,
  `pb_term` int NOT NULL,
  `line1_stDate` datetime  NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `line2_stDate` datetime  NULL,
  `line2_stPrice` double DEFAULT NULL,
  `line2_edDate` datetime DEFAULT NULL,
  `line2_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date3` datetime DEFAULT NULL,
  `price3` double DEFAULT NULL,
  `date4` datetime DEFAULT NULL,
  `price4` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1)  not NULL,
  UNIQUE KEY `idx_ptnPBTripleTop` (`stockCode`,`pb_term`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;


CREATE TABLE `ptnPBTripleBottom` (
  `stockCode` varchar(8) NOT NULL,
  `pb_term` int NOT NULL,
  `line1_stDate` datetime  NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `line2_stDate` datetime  NULL,
  `line2_stPrice` double DEFAULT NULL,
  `line2_edDate` datetime DEFAULT NULL,
  `line2_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date3` datetime DEFAULT NULL,
  `price3` double DEFAULT NULL,
  `date4` datetime DEFAULT NULL,
  `price4` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1)  not NULL,
  UNIQUE KEY `idx_ptnPBTripleBottom` (`stockCode`,`pb_term`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;


create view ptnPBListCntView as
select  "ptnPBDoubleBottom" as ptn,ashi,count(*) as cnt from ptnPBDoubleBottom group by ashi union
select  "ptnPBDoubleTop",ashi,count(*) from ptnPBDoubleTop group by ashi union
select  "ptnPBDownChannel",ashi,count(*) from ptnPBDownChannel group by ashi union
select  "ptnPBFallingTriangle",ashi,count(*) from ptnPBFallingTriangle group by ashi union
select  "ptnPBFallingWedge",ashi,count(*) from ptnPBFallingWedge group by ashi union
select  "ptnPBHeadAndShoulderBottom",ashi,count(*) from ptnPBHeadAndShoulderBottom group by ashi union
select  "ptnPBHeadAndShoulderTop",ashi,count(*) from ptnPBHeadAndShoulderTop group by ashi union
select  "ptnPBRisingTriangle",ashi,count(*) from ptnPBRisingTriangle group by ashi union
select  "ptnPBRisingWedge",ashi,count(*) from ptnPBRisingWedge group by ashi union
select  "ptnPBTripleBottom",ashi,count(*) from ptnPBTripleBottom group by ashi union
select  "ptnPBTripleTop",ashi,count(*) from ptnPBTripleTop group by ashi union
select  "ptnPBUpChannel",ashi,count(*) from ptnPBUpChannel group by ashi
;




CREATE TABLE `ptnNowPBHeadAndShoulderTop` (
  `stockCode` varchar(8) NOT NULL,
  `pb_term` int NOT NULL,
  `line1_stDate` datetime default NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date3` datetime DEFAULT NULL,
  `price3` double DEFAULT NULL,
  `date4` datetime DEFAULT NULL,
  `price4` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1) not NULL,
  UNIQUE KEY `idx_ptnNowPBHeadAndShoulderTop` (`stockCode`,`pb_term`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;

CREATE TABLE `ptnNowPBHeadAndShoulderBottom` (
  `stockCode` varchar(8) NOT NULL,
  `pb_term` int NOT NULL,
  `line1_stDate` datetime default NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date3` datetime DEFAULT NULL,
  `price3` double DEFAULT NULL,
  `date4` datetime DEFAULT NULL,
  `price4` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1) not NULL,
  UNIQUE KEY `idx_ptnNowPBHeadAndShoulderBottom` (`stockCode`,`pb_term`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;


CREATE TABLE `ptnNowPBRisingTriangle` (
  `stockCode` varchar(8) NOT NULL,
  `pb_term` int NOT NULL,
  `line1_stDate` datetime  NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `line2_stDate` datetime  NULL,
  `line2_stPrice` double DEFAULT NULL,
  `line2_edDate` datetime DEFAULT NULL,
  `line2_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date3` datetime DEFAULT NULL,
  `price3` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1)  not NULL,
  UNIQUE KEY `idx_ptnNowPBRisingTriangle` (`stockCode`,`pb_term`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;

CREATE TABLE `ptnNowPBFallingTriangle` (
  `stockCode` varchar(8) NOT NULL,
  `pb_term` int NOT NULL,
  `line1_stDate` datetime  NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `line2_stDate` datetime  NULL,
  `line2_stPrice` double DEFAULT NULL,
  `line2_edDate` datetime DEFAULT NULL,
  `line2_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date3` datetime DEFAULT NULL,
  `price3` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1)  not NULL,
  UNIQUE KEY `idx_ptnNowPBFallingTriangle` (`stockCode`,`pb_term`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;




CREATE TABLE `ptnNowPBRisingWedge` (
  `stockCode` varchar(8) NOT NULL,
  `pb_term` int NOT NULL,
  `line1_stDate` datetime  NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `line2_stDate` datetime  NULL,
  `line2_stPrice` double DEFAULT NULL,
  `line2_edDate` datetime DEFAULT NULL,
  `line2_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date3` datetime DEFAULT NULL,
  `price3` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1)  not NULL,
  UNIQUE KEY `idx_ptnNowPBRisingWedge` (`stockCode`,`pb_term`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;


CREATE TABLE `ptnNowPBFallingWedge` (
  `stockCode` varchar(8) NOT NULL,
  `pb_term` int NOT NULL,
  `line1_stDate` datetime  NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `line2_stDate` datetime  NULL,
  `line2_stPrice` double DEFAULT NULL,
  `line2_edDate` datetime DEFAULT NULL,
  `line2_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date3` datetime DEFAULT NULL,
  `price3` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1)  not NULL,
  UNIQUE KEY `idx_ptnNowPBFallingWedge` (`stockCode`,`pb_term`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;


CREATE TABLE `ptnNowPBUpChannel` (
  `stockCode` varchar(8) NOT NULL,
  `pb_term` int NOT NULL,
  `line1_stDate` datetime  NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `line2_stDate` datetime  NULL,
  `line2_stPrice` double DEFAULT NULL,
  `line2_edDate` datetime DEFAULT NULL,
  `line2_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date3` datetime DEFAULT NULL,
  `price3` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1)  not NULL,
  UNIQUE KEY `idx_ptnNowPBUpChannel` (`stockCode`,`pb_term`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;


CREATE TABLE `ptnNowPBDownChannel` (
  `stockCode` varchar(8) NOT NULL,
  `pb_term` int NOT NULL,
  `line1_stDate` datetime  NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `line2_stDate` datetime  NULL,
  `line2_stPrice` double DEFAULT NULL,
  `line2_edDate` datetime DEFAULT NULL,
  `line2_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date3` datetime DEFAULT NULL,
  `price3` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1)  not NULL,
  UNIQUE KEY `idx_ptnNowPBDownChannel` (`stockCode`,`pb_term`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;


CREATE TABLE `ptnNowPBDoubleTop` (
  `stockCode` varchar(8) NOT NULL,
  `pb_term` int NOT NULL,
  `line1_stDate` datetime  NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `line2_stDate` datetime  NULL,
  `line2_stPrice` double DEFAULT NULL,
  `line2_edDate` datetime DEFAULT NULL,
  `line2_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1)  not NULL,
  UNIQUE KEY `idx_ptnNowPBDoubleTop` (`stockCode`,`pb_term`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;


CREATE TABLE `ptnNowPBDoubleBottom` (
  `stockCode` varchar(8) NOT NULL,
  `pb_term` int NOT NULL,
  `line1_stDate` datetime  NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `line2_stDate` datetime  NULL,
  `line2_stPrice` double DEFAULT NULL,
  `line2_edDate` datetime DEFAULT NULL,
  `line2_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1)  not NULL,
  UNIQUE KEY `idx_ptnNowPBDoubleBottom` (`stockCode`,`pb_term`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;


CREATE TABLE `ptnNowPBTripleTop` (
  `stockCode` varchar(8) NOT NULL,
  `pb_term` int NOT NULL,
  `line1_stDate` datetime  NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `line2_stDate` datetime  NULL,
  `line2_stPrice` double DEFAULT NULL,
  `line2_edDate` datetime DEFAULT NULL,
  `line2_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date3` datetime DEFAULT NULL,
  `price3` double DEFAULT NULL,
  `date4` datetime DEFAULT NULL,
  `price4` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1)  not NULL,
  UNIQUE KEY `idx_ptnNowPBTripleTop` (`stockCode`,`pb_term`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;


CREATE TABLE `ptnNowPBTripleBottom` (
  `stockCode` varchar(8) NOT NULL,
  `pb_term` int NOT NULL,
  `line1_stDate` datetime  NULL,
  `line1_stPrice` double DEFAULT NULL,
  `line1_edDate` datetime DEFAULT NULL,
  `line1_edPrice` double DEFAULT NULL,
  `line2_stDate` datetime  NULL,
  `line2_stPrice` double DEFAULT NULL,
  `line2_edDate` datetime DEFAULT NULL,
  `line2_edPrice` double DEFAULT NULL,
  `date_pre` datetime default null,
  `price_pre` double default null,
  `date_from` datetime not NULL,
  `price_from` double DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `price2` double DEFAULT NULL,
  `date3` datetime DEFAULT NULL,
  `price3` double DEFAULT NULL,
  `date4` datetime DEFAULT NULL,
  `price4` double DEFAULT NULL,
  `date_to` datetime not NULL,
  `price_to` double DEFAULT NULL,
  `date_post` datetime default null,
  `price_post` double default null,
  `ashi` char(1)  not NULL,
  UNIQUE KEY `idx_ptnNowPBTripleBottom` (`stockCode`,`pb_term`,`date_from`,`date_to`,`ashi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
;

create view ptnNowPBListCntView as
select  "ptnNowPBDoubleBottom" as ptn,ashi,count(*) as cnt from ptnNowPBDoubleBottom group by ashi union
select  "ptnNowPBDoubleTop",ashi,count(*) from ptnNowPBDoubleTop group by ashi union
select  "ptnNowPBDownChannel",ashi,count(*) from ptnNowPBDownChannel group by ashi union
select  "ptnNowPBFallingTriangle",ashi,count(*) from ptnNowPBFallingTriangle group by ashi union
select  "ptnNowPBFallingWedge",ashi,count(*) from ptnNowPBFallingWedge group by ashi union
select  "ptnNowPBHeadAndShoulderBottom",ashi,count(*) from ptnNowPBHeadAndShoulderBottom group by ashi union
select  "ptnNowPBHeadAndShoulderTop",ashi,count(*) from ptnNowPBHeadAndShoulderTop group by ashi union
select  "ptnNowPBRisingTriangle",ashi,count(*) from ptnNowPBRisingTriangle group by ashi union
select  "ptnNowPBRisingWedge",ashi,count(*) from ptnNowPBRisingWedge group by ashi union
select  "ptnNowPBTripleBottom",ashi,count(*) from ptnNowPBTripleBottom group by ashi union
select  "ptnNowPBTripleTop",ashi,count(*) from ptnNowPBTripleTop group by ashi union
select  "ptnNowPBUpChannel",ashi,count(*) from ptnNowPBUpChannel group by ashi
;

create view ptnNowPBListView as
select  "ptnNowPBDoubleBottom" as ptnNowPB,stockCode,pb_term,ashi,date_from,date_to,price_to,line1_stDate,line1_edDate from ptnNowPBDoubleBottom union
select  "ptnNowPBDoubleTop" as ptnNowPB,stockCode,pb_term,ashi,date_from,date_to,price_to,line1_stDate,line1_edDate from ptnNowPBDoubleTop union
select  "ptnNowPBDownChannel" as ptnNowPB,stockCode,pb_term,ashi,date_from,date_to,price_to,line1_stDate,line1_edDate from ptnNowPBDownChannel union
select  "ptnNowPBFallingTriangle" as ptnNowPB,stockCode,pb_term,ashi,date_from,date_to,price_to,line1_stDate,line1_edDate from ptnNowPBFallingTriangle union
select  "ptnNowPBFallingWedge" as ptnNowPB,stockCode,pb_term,ashi,date_from,date_to,price_to,line1_stDate,line1_edDate from ptnNowPBFallingWedge union
select  "ptnNowPBHeadAndShoulderBottom" as ptnNowPB,stockCode,pb_term,ashi,date_from,date_to,price_to,line1_stDate,line1_edDate from ptnNowPBHeadAndShoulderBottom union
select  "ptnNowPBHeadAndShoulderTop" as ptnNowPB,stockCode,pb_term,ashi,date_from,date_to,price_to,line1_stDate,line1_edDate from ptnNowPBHeadAndShoulderTop union
select  "ptnNowPBRisingTriangle" as ptnNowPB,stockCode,pb_term,ashi,date_from,date_to,price_to,line1_stDate,line1_edDate from ptnNowPBRisingTriangle union
select  "ptnNowPBRisingWedge" as ptnNowPB,stockCode,pb_term,ashi,date_from,date_to,price_to,line1_stDate,line1_edDate from ptnNowPBRisingWedge union
select  "ptnNowPBTripleBottom" as ptnNowPB,stockCode,pb_term,ashi,date_from,date_to,price_to,line1_stDate,line1_edDate from ptnNowPBTripleBottom union
select  "ptnNowPBTripleTop" as ptnNowPB,stockCode,pb_term,ashi,date_from,date_to,price_to,line1_stDate,line1_edDate from ptnNowPBTripleTop union
select  "ptnNowPBUpChannel" as ptnNowPB,stockCode,pb_term,ashi,date_from,date_to,price_to,line1_stDate,line1_edDate from ptnNowPBUpChannel
;


drop table ptnNowPBResult
;
drop view ptnNowPBResultView
;

create table ptnNowPBResult(
  ptnNowPB varchar(32) not null,
  `ashi` char(1)  not NULL,
  okCount int  null,
  ngCount int null,
  okAvg double precision null,
  okStd double precision null,
  ngAvg double precision null,
  ngStd double precision null
)
;
create unique index idx_ptnNowPBResult on ptnNowPBResult(ptnNowPB,ashi)
;

create view ptnNowPBResultView as
select ptnNowPB,ashi,okCount,ngCount,okCount/(okCount+ngCount) 
as okRatio,ngCount/(okCount+ngCount) 
as ngRatio,okAvg,okStd,ngAvg,ngStd from ptnNowPBResult
;
