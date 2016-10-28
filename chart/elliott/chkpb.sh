#!/bin/sh


tables="
ptnPBDoubleBottom
ptnPBDoubleTop
ptnPBDownChannel
ptnPBFallingTriangle
ptnPBFallingWedge
ptnPBHeadAndShoulderBottom
ptnPBHeadAndShoulderTop
ptnPBRisingTriangle
ptnPBRisingWedge
ptnPBTripleBottom
ptnPBTripleTop
ptnPBUpChannel
"

for tbl in $tables;do
  mysql -uroot -hlocalhost << Eof
use fintech
;
select count(*) as $tbl from $tbl
;
Eof
done



