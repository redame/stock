#!/bin/sh


ndate="2015-11-07"


while true ;do
  yy=`./yy.rb "$ndate"`
  mm=`./mm.rb "$ndate"`
  dd=`./dd.rb "$ndate"`
  echo yy=$yy,mm=$mm,dd=$dd
  bash ./hist_daily.sh $yy $mm $dd
  ndate=`ruby next.rb $ndate`
  echo ndate=$ndate
  if [ $ndate = "2017-01-24" ];then
    exit
  fi
done
