#!/bin/sh


tables="
ptnNowPBDoubleBottom
ptnNowPBDoubleTop
ptnNowPBDownChannel
ptnNowPBFallingTriangle
ptnNowPBFallingWedge
ptnNowPBHeadAndShoulderBottom
ptnNowPBHeadAndShoulderTop
ptnNowPBRisingTriangle
ptnNowPBRisingWedge
ptnNowPBTripleBottom
ptnNowPBTripleTop
ptnNowPBUpChannel
"

for tbl in $tables;do
  mysql -uroot -hlocalhost << Eof
use fintech
;
select count(*) as $tbl from $tbl
;
Eof
done



