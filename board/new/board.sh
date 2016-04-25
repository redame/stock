#!/bin/sh


codes=`cat codes.txt`

for code in $codes;do
  url=`ruby boardurl.rb $code`
  num=`ruby boardnum.rb $url`
  for i in `seq $num -1 2`;do
    mkdir -p data/textream/$code/$i
    ruby board.rb $code $url/$i data/textream/$code/$i 
    if [ $? = 1 ];then
      break
    fi
    sleep 1
  done
done

exit 0
