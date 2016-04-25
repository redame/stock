#!/bin/sh

dd="
09
10
11
"
for i in $dd;do
echo $i
bash tmp.sh $i
done 
