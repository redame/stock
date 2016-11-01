#!/bin/sh


get_code(){
ruby << Eof
print "$1".split("/")[4][3..6]
Eof
}

urls=`cat board_file.txt`

for url in $urls;do
  code=`get_code $url`
  for i in `seq 1 100`;do
    echo "ruby board.rb /home/admin/data/board $code $url/$i"
    ruby board.rb /home/admin/data/board $code $url/$i
    if [ $? = 1 ];then
      break
    fi
exit
    sleep 1
  done
done

