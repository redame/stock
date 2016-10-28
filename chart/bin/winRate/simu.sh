#!/bin/sh

stockCode=$1
if [ "$stockCode" = "" ];then
  echo "usage:$0 stockCode"
  exit 0
fi


calc_simu(){
  rikaku=$1
  songiri=$2
  stockCode=$3

  for term in 5 10 15 20;do
    echo $term
    python calcSimulation.py ascendingTriangle 2 up $rikaku $songiri $term $stockCode
    python calcSimulation.py ascendingTriangle 2 down $rikaku $songiri $term $stockCode

    python calcSimulation.py pennant 3 up $rikaku $songiri $term $stockCode
    python calcSimulation.py pennant 3 down $rikaku $songiri $term $stockCode

    python calcSimulation.py descendingTriangle 4 up $rikaku $songiri $term $stockCode
    python calcSimulation.py descendingTriangle 4 down $rikaku $songiri $term $stockCode

    python calcSimulation.py box 5 up $rikaku $songiri $term $stockCode
    python calcSimulation.py box 5 down $rikaku $songiri $term $stockCode

    python calcSimulation.py chanelUp 6 up $rikaku $songiri $term $stockCode
    python calcSimulation.py chanelUp 6 down $rikaku $songiri $term $stockCode

    python calcSimulation.py chanelDown 7 up $rikaku $songiri $term $stockCode
    python calcSimulation.py chanelDown 7 down $rikaku $songiri $term $stockCode

    python calcSimulation.py ascendingWedge 9 up $rikaku $songiri $term $stockCode
    python calcSimulation.py ascendingWedge 9 down $rikaku $songiri $term $stockCode

    python calcSimulation.py descendingWedge 10 up $rikaku $songiri $term $stockCode
    python calcSimulation.py descendingWedge 10 down $rikaku $songiri $term $stockCode

    python calcSimulation.py headAndShoulder 11 up $rikaku $songiri $term $stockCode
    python calcSimulation.py headAndShoulder 11 down $rikaku $songiri $term $stockCode

    python calcSimulation.py headAndShoulderBottom 12 up $rikaku $songiri $term $stockCode
    python calcSimulation.py headAndShoulderBottom 12 down $rikaku $songiri $term $stockCode
  done
}
calc_simu 0.05 0.05 $stockCode
calc_simu 0.10 0.10 $stockCode
calc_simu 99999 99999 $stockCode
