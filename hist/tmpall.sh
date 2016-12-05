#!/bin/sh

mms="
7
8
9
10
11
"
for mm in $mms;do
  echo $mm
  for dd in `seq -f%02g 31`;do
    bash tmp.sh $mm $dd
  done
done 
