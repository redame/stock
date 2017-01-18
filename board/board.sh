#!/bin/sh


codes=`cat codes.txt`

for code in $codes;do
  url=`ruby boardurl.rb $code`
  for i in `seq 2 100`;do
    echo "  ruby board.rb /var/lib/news/board $code $url/$i"
    ruby board.rb ../../data/board $code $url/$i
    if [ $? = 1 ];then
      break
    fi
    sleep 1
  done
done

