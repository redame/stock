#!/bin/sh

export PATH=/home/pi/.dnx/runtimes/dnx-mono.1.0.0-beta4/bin:/usr/local/rbenv/shims:/usr/local/rbenv/bin:/usr/local/nvm/versions/node/v0.12.4/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games


cd /home/pi/stock/news/board


psql -Upostgres stock << Eof |grep -v "^$"|grep -v '('|grep -v '-'|grep -v "code"> codes.txt
select code from stockmaster
;
Eof
