#!/bin/bash


export TERM=xterm-256color
export SHELL=/bin/bash
export MAIL=/var/mail/pi
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games
export EDITOR=vi
export LANG=ja_JP.UTF-8
export HOME=/home/pi

yy=2015
mm=01
dds="
09
"
#echo "/usr/bin/python master.py"
codes=`cat daily/master.txt|awk '{print $1}'`
for dd in $dds;do
cd /home/pi/stock/hist
/usr/bin/python master.py
rm -rf daily/[1-9]*.txt
date



for code in $codes;do
  echo "python hist_daily.py $code $yy $mm $dd"
  python hist_daily.py $code $yy $mm $dd
done


codes=`ls daily/*.txt|grep -v master`
for code in $codes;do
  echo $code
#  python hist_import.py $code
  sqlite3 stock.db << Eof
.separator \t
.import $code histDaily
Eof
done
done

#echo "stockmaster"
##sqlite3 stock.db << Eof
#delete from stockMaster;
#.separator \t
#.import daily/master.txt stockMaster
#Eof
date
