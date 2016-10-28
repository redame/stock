#!/bin/sh


tables="
ptnDoubleBottom
ptnDoubleTop
ptnDownChannel
ptnFallingTriangle
ptnFallingWedge
ptnHeadAndShoulderBottom
ptnHeadAndShoulderTop
ptnRisingTriangle
ptnRisingWedge
ptnTripleBottom
ptnTripleTop
ptnUpChannel
"

for tbl in $tables;do
  mysql -uroot -hlocalhost << Eof
use fintech
;
truncate table $tbl
;
Eof
done



