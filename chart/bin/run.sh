#!/bin/sh


calc_code(){
  codeClass=$1
stockCodes=`mysql -uroot -hlive.c8t088zeyxow.ap-northeast-1.rds.amazonaws.com -pfintechlabo << Eof
use live
;
select stockCode as "" from stockMasterFull where stockCode like '${codeClass}%' 
;
Eof
`

for stockCode in $stockCodes;do
  echo $stockCode
  cnt=`mysql -uroot -hlive.c8t088zeyxow.ap-northeast-1.rds.amazonaws.com -pfintechlabo<< Eof
 select count(*) as "" from  fintech.chartSignal where stockCode="$stockCode"
Eof
`

  if [ $cnt -gt 0 ];then
    echo "skip:$cnt"
  else
    python getAllStockPrice.py $stockCode
    cd trendline
    bash ./start.sh $stockCode
    cd ../winRate
    bash ./simu.sh $stockCode
    cd ..
  fi
done
}

calc_all(){
  h=$1
  lst="0 1 2 3 4"
  if [ "$TYPE" = 1 ];then
    lst="5 6 7 8 9"
  fi
  for i in $lst;do
    echo "calc_code ${h}${i}"
    calc_code ${h}${i}
  done
}

TYPE=$1

calc_all 1 &
calc_all 2 &
calc_all 3 &
calc_all 4 &
calc_all 5 &
calc_all 6 &
calc_all 7 &
calc_all 8 &
calc_all 9 &
