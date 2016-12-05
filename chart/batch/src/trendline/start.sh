#!/bin/sh

#cd /home/ec2-user/chartPatternBatch/batch/src/trendline

echo "ascendingTriangle"
python createTrendLine.py "ascendingTriangle" 2 True False
echo "pennant"
python createTrendLine.py "pennant" 3 True False
echo "descendingTriangle" 
python createTrendLine.py "descendingTriangle" 4 True False
echo "box" 
python createTrendLine.py "box" 5 False False
echo "chanelUp"
python createTrendLine.py "chanelUp" 6 False False
echo "chanelDown"
python createTrendLine.py "chanelDown" 7 False False
echo "ascendingWedge"
python createTrendLine.py "ascendingWedge" 9 True False
echo "descendingWedge"
python createTrendLine.py "descendingWedge" 10 True False
echo "headAndShoulder"
python createTrendLine.py "headAndShoulder" 11 None None
echo "headAndShoulderBottom"
python createTrendLine.py "headAndShoulderBottom" 12 None None
