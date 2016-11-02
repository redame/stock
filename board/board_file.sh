#!/bin/sh


get_code(){
ruby << Eof
print "$1".split("/")[4][3..6]
Eof
}

urls=`cat board_file.dat`

for url in $urls;do
  code=`get_code $url`
  for i in `seq 1 100`;do
    echo "python board.py /home/admin/data/board $code $url/$i"
    python board.py /Volumes/admin/data $code $url/$i
    if [ $? = 1 ];then
      break
    fi
exit
    sleep 1
  done
done

