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
  mysql -uroot -hlocalhost fintech --local-infile=1 << EOF
load data local infile "txt/$tbl.txt" into table $tbl
;
EOF

done



