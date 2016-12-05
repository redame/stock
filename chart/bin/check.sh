#!/bin/sh

stockCode=$1
if [ "$stockCode" = "" ];then
  echo "usage:$0 stockCode"
  exit 0
fi

mysql -uroot -hlive.c8t088zeyxow.ap-northeast-1.rds.amazonaws.com -pfintechlabo << Eof
use fintech
;
select count(*) as chartLine from chartLine where stockCode="$stockCode"
;
select count(*) as chartSignal from chartSignal where stockCode="$stockCode"
;
select count(*) as chartWinRate from chartWinRate where stockCode="$stockCode"
;
select count(*) as chartSimulation from chartSimulation where stockCode="$stockCode"
;
Eof
