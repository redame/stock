#!/bin/sh


date="2016-07-27"


while true ;do
  yy=`./yy.rb "$date"`
  mm=`./mm.rb "$date"`
  dd=`./dd.rb "$date"`
  echo yy=$yy,mm=$mm,dd=$dd
  bash ./hist_daily.sh $yy $mm $dd
  ndate=`ruby next.rb $date`
  if [ $ndate = "2017-01-17" ];then
    exit
  fi
done
