#!/bin/sh

codes=`cat data/master.txt|awk '{print $1}'`

for code in $codes;do
  python hist_code.py $code
done
