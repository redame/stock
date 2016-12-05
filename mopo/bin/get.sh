#!/bin/sh

mkdir -p pdf
cd pdf
for yyyy in `seq 2008 2015`;do
  yy=${yyyy:2:2}
  for mm in `seq -f %02g 1 12`;do
    wget  http://www.boj.or.jp/mopo/gp_${yyyy}/data/gp${yy}${mm}.pdf
    sleep 10
  done
done
