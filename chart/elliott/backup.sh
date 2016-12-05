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
 /home/admin/bin/myout_new/myout_new -u root -h zaaa16d -p "" -t $tbl -d fintech > txt/$tbl.txt
done



