#!/bin/bash


export TERM=xterm-256color
export SHELL=/bin/bash
export MAIL=/var/mail/pi
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games
export EDITOR=vi
export LANG=ja_JP.UTF-8
export HOME=/home/pi


cd /home/pi/stock/hist
rm -rf daily/*.txt
date

yy=`date +%Y`
mm=`date +%m`
dd=`date +%d`

echo "/usr/bin/python master.py"
/usr/bin/python master.py
codes=`cat daily/master.txt|awk '{print $1}'`

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

#  psql -Upostgres stock << Eof
#copy histDaily from '/home/pi/stock/data/daily/${code}' with csv;
#Eof
done



echo "stockmaster"
sqlite3 stock.db << Eof
delete from stockMaster;
.separator \t
.import daily/master.txt stockMaster
Eof

#psql -Upostgres stock << Eof
#delete from stockMaster;
#copy stockMaster from '/home/pi/stock/data/daily/master.txt' with csv;
#Eof

date
