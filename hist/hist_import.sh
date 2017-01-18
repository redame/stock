#!/bin/sh

codes=`ls data/*.txt|grep -v master`
for code in $codes;do
  echo $code
#  python hist_import.py $code
  sqlite3 stock.db << Eof
.separator \t
.import $code histDaily
Eof
done
