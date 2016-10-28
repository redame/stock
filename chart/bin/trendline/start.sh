#!/bin/sh

#cd /home/ec2-user/chartPatternBatch/batch/src/trendline

stockCode=$1
if [ "$stockCode" = "" ];then
  echo "usage:$0 stockCode"
  exit 0
fi

echo "ascendingTriangle"
python createTrendLine.py "ascendingTriangle" 2 True False $stockCode
echo "pennant"
python createTrendLine.py "pennant" 3 True False $stockCode
echo "descendingTriangle" 
python createTrendLine.py "descendingTriangle" 4 True False $stockCode
echo "box" 
python createTrendLine.py "box" 5 False False $stockCode
echo "chanelUp"
python createTrendLine.py "chanelUp" 6 False False $stockCode
echo "chanelDown"
python createTrendLine.py "chanelDown" 7 False False $stockCode
echo "ascendingWedge"
python createTrendLine.py "ascendingWedge" 9 True False $stockCode
echo "descendingWedge"
python createTrendLine.py "descendingWedge" 10 True False $stockCode
echo "headAndShoulder"
python createTrendLine.py "headAndShoulder" 11 None None $stockCode
echo "headAndShoulderBottom"
python createTrendLine.py "headAndShoulderBottom" 12 None None $stockCode
