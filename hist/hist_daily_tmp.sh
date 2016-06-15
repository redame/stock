#!/bin/bash


export TERM=xterm-256color
export SHELL=/bin/bash
export MAIL=/var/mail/pi
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games
export EDITOR=vi
export LANG=ja_JP.UTF-8
export HOME=/home/pi


cd /home/pi/stock/hist
date



codes=`ls daily/*.txt|grep -v master`
for code in $codes;do
  echo $code
  mysql -ustock -hlocalhost --local-infile=1 stock << Eof
load data local infile "/home/pi/stock/data/${code}" into table histDaily
;
Eof
done



echo "stockmaster"

mysql -ustock -hlocalhost --local-infile=1 stock << Eof
delete from stockMaster
;
set names utf8
;
load data local infile "/home/pi/stock/data/daily/master.txt" into table stockMaster
;
Eof

date
