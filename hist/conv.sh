#!/bin/sh

for f in `ls /home/pi/data/data/*.txt|grep -v master`;do
  echo $f
  ruby conv.rb $f > /tmp/log.txt
  mv /tmp/log.txt $f
done
