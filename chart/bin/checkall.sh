#!/bin/sh


mysql -uroot -hlive.c8t088zeyxow.ap-northeast-1.rds.amazonaws.com -pfintechlabo << Eof
use fintech
;
select count(*) as chartLine from chartLine 
;
select count(*) as chartSignal from chartSignal 
;
select count(*) as chartWinRate from chartWinRate 
;
select count(*) as chartSimulation from chartSimulation 
;
select count(distinct(stockCode)) from chartSignal
;
Eof
